//
//  PresentationAnimator.swift
//  PresentationManager
//
//  Created by sai on 05/04/2017.
//

import UIKit

final public class PresentationAnimator: NSObject {
    
    // MARK: - Properties
    
    public let direction: PresentationDirection
    public let isPresentation: Bool
    public let transitionDuration: TimeInterval
    
    // MARK: - Initializers
    
    public init(direction: PresentationDirection, isPresentation: Bool, transitionDuration: TimeInterval = 0.3) {
        self.direction = direction
        self.isPresentation = isPresentation
        self.transitionDuration = transitionDuration
        
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension PresentationAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let controller = transitionContext.viewController(forKey: self.isPresentation ? .to : .from) else {
            return
        }
        
        if self.isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }
        
        let presentedFrame = transitionContext.finalFrame(for: controller)
        let presentedAlpha: CGFloat = 1
        var dismissedFrame = presentedFrame
        var dismissedAlpha = presentedAlpha
        switch self.direction {
        case .left:
            dismissedFrame.origin.x = -presentedFrame.width
        case .right:
            dismissedFrame.origin.x = transitionContext.containerView.frame.size.width
        case .top:
            dismissedFrame.origin.y = -presentedFrame.height
        case .bottom:
            dismissedFrame.origin.y = transitionContext.containerView.frame.size.height
        case .center:
            dismissedAlpha = 0
        }
        
        let initialFrame = self.isPresentation ? dismissedFrame : presentedFrame
        let initialAlpha = self.isPresentation ? dismissedAlpha : presentedAlpha
        let finalFrame = self.isPresentation ? presentedFrame : dismissedFrame
        let finalAlpha = self.isPresentation ? presentedAlpha : dismissedAlpha
        
        let animationDuration = self.transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        controller.view.alpha = initialAlpha
        UIView.animate(withDuration: animationDuration, animations: {
            controller.view.frame = finalFrame
            controller.view.alpha = finalAlpha
        }) { finished in
            transitionContext.completeTransition(finished)
        }
    }
}
