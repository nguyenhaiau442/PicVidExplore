//
//  VideoPlayerView.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu   on 23/12/2023.
//

import SwiftUI
import AVKit

struct VideoPlayerView: UIViewRepresentable {
    typealias UIViewType = VideoPlayerUIView
    var video: Model
    let videoCacheManager: VideoCacheManager
    @ObservedObject var videoStateManager: VideoStateManager
    
    func makeUIView(context: Context) -> VideoPlayerUIView {
        return VideoPlayerUIView(frame: .zero, video: video, videoCacheManager: videoCacheManager)
    }
    
    func updateUIView(_ uiView: VideoPlayerUIView, context: Context) {
        if videoStateManager.isPlaying(for: video) {
            uiView.playVideo()
        } else {
            uiView.pauseVideo()
        }
    }
}

class VideoPlayerUIView: UIView {
    var video: Model
    var videoCacheManager: VideoCacheManager
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    
    private let timeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    init(frame: CGRect, video: Model, videoCacheManager: VideoCacheManager) {
        self.video = video
        self.videoCacheManager = videoCacheManager
        super.init(frame: frame)
        Task {
            try await setupViews()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = self.bounds
    }
    
    private func setupViews() async throws {
        guard let videoURL = Bundle.main.url(forResource: video.name, withExtension: video.type) else { return }
        Task {
            let asset = try await videoCacheManager.getVideoAsset(for: videoURL)
            layer.cornerRadius = 16
            layer.masksToBounds = true
            try await setupPlayer(asset: asset)
            if let timeDisplay = try await getVideoDuration(asset: asset) {
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 15, weight: .medium)]
                let timeSize = (timeDisplay as NSString).size(withAttributes: attributes)
                addSubview(timeView)
                timeView.addSubview(timeLabel)
                timeLabel.text = timeDisplay
                NSLayoutConstraint.activate([
                    timeView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
                    timeView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
                    timeView.widthAnchor.constraint(equalToConstant: timeSize.width + 16),
                    timeView.heightAnchor.constraint(equalToConstant: timeSize.height + 8),
                    timeLabel.centerXAnchor.constraint(equalTo: timeView.centerXAnchor),
                    timeLabel.centerYAnchor.constraint(equalTo: timeView.centerYAnchor)
                ])
            }
        }
    }
    
    private func getVideoDuration(asset: AVAsset) async throws -> String? {
        let duration = try await asset.load(.duration)
        let seconds = CMTimeGetSeconds(duration)
        let minutes = Int(seconds / 60)
        let secondsRemainder = Int(seconds.truncatingRemainder(dividingBy: 60))
        return "\(minutes):\(String(format: "%02d", secondsRemainder))"
    }
    
    private func setupPlayer(asset: AVAsset) async throws {
        player = AVPlayer(playerItem: AVPlayerItem(asset: asset))
        player?.isMuted = true
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        self.layer.addSublayer(playerLayer!)
        
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem,
            queue: nil) { [weak self] notification in
                guard let self = self,
                      let currentItem = notification.object as? AVPlayerItem
                else {
                    return
                }
                Task {
                    await self.videoDidFinishPlaying(currentItem: currentItem)
                }
            }
    }
    
    @MainActor
    private func videoDidFinishPlaying(currentItem: AVPlayerItem) {
        guard let player = player, player.currentItem == currentItem else {
            return
        }
        player.seek(to: CMTime.zero)
        player.play()
    }
    
    @MainActor
    func playVideo() {
        self.player?.play()
    }
    
    @MainActor
    func pauseVideo() {
        self.player?.pause()
    }
}
