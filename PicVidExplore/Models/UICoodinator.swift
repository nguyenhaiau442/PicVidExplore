//
//  UICoodinator.swift
//  PicVidExplore
//
//  Created by Nguyễn Hải Âu on 12/05/2024.
//

import SwiftUI

@Observable
class UICoordinator {
    /// Shared View Properties between Home and Detail View
    var scrollView: UIScrollView = .init(frame: .zero)
    var rect: CGRect = .zero
    var selectedItem: Model?
    
    /// Animation Layer Properties
    var animationLayer: UIImage?
    var animateView: Bool = false
    var hideLayer: Bool = false
    
    /// Root View Properties
    var hideRootView: Bool = false
    
    func createVisibleAreaSnapshot() {
        let renderer = UIGraphicsImageRenderer(size: scrollView.bounds.size)
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: -scrollView.contentOffset.x, y: -scrollView.contentOffset.y)
            scrollView.layer.render(in: ctx.cgContext)
        }
        animationLayer = image
    }
    
    func toogleView(show: Bool, frame: CGRect, model: Model) {
        if show {
            selectedItem = model
            /// Storing View's Rect
            rect = frame
            /// Generating ScrollView's Visible area Snapshot
            createVisibleAreaSnapshot()
            hideRootView = true
            /// Animating View
            withAnimation(.easeInOut(duration: 0.3), completionCriteria: .removed) {
                animateView = true
            } completion: {
                self.hideLayer = true
            }
        } else {
            /// Closing View
            hideLayer = false
            withAnimation(.easeInOut(duration: 0.3), completionCriteria: .logicallyComplete) {
                animateView = false
            } completion: {
                /// Resetting Properties
                self.resetAnimationProperties()
            }

        }
    }
    
    private func resetAnimationProperties() {
        hideRootView = false
        rect = .zero
        selectedItem = nil
        animationLayer = nil
    }
}

struct ScrollViewExtractor: UIViewRepresentable {
    var result: (UIScrollView) -> ()
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        DispatchQueue.main.async {
            if let scrollView = view.superview?.superview?.superview as? UIScrollView {
                result(scrollView)
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
