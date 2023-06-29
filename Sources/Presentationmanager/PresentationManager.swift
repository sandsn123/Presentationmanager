//
//  PresentationManager.swift
//  PresentationManager
//
//  Created by sai on 05/04/2017.
//

import UIKit

public protocol PresentationManagerDelegate: AnyObject {
    func presentationManager(_ manager: PresentationManager, presentationController: PresentationController, didTapDimmingView dimmingView: UIView)
}

open class PresentationManager: NSObject {
    public var direction: PresentationDirection
    public var presentationSize: PresentationSizeProtocol
    public var cornerRadius: CGFloat
    public var disableCompactHeight: Bool
    public var transitionDuration: TimeInterval
    public var dimmingViewAlpha: CGFloat
    
    public weak var delegate: PresentationManagerDelegate?
    
    public init(direction: PresentationDirection, presentationSize: PresentationSizeProtocol, cornerRadius: CGFloat = 5, disableCompactHeight: Bool = false, transitionDuration: TimeInterval = 0.3, dimmingViewAlpha: CGFloat = 0.3) {
        self.direction = direction
        self.presentationSize = presentationSize
        self.cornerRadius = cornerRadius
        self.disableCompactHeight = disableCompactHeight
        self.transitionDuration = transitionDuration
        self.dimmingViewAlpha = dimmingViewAlpha
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension PresentationManager: UIViewControllerTransitioningDelegate {
    open func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let presentationController = PresentationController(presentedViewController: presented,
                                                            presenting: presenting,
                                                            direction: self.direction,
                                                            presentationSize: self.presentationSize,
                                                            cornerRadius: self.cornerRadius, alphaValue: self.dimmingViewAlpha)
        presentationController.delegate = self
        return presentationController
    }
    
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(direction: self.direction, isPresentation: true, transitionDuration: self.transitionDuration)
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(direction: self.direction, isPresentation: false, transitionDuration: self.transitionDuration)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension PresentationManager: UIAdaptivePresentationControllerDelegate {
    open func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        if traitCollection.verticalSizeClass == .compact && disableCompactHeight {
            return .overFullScreen
        } else {
            return .none
        }
    }
}

// MARK: - PresentationControllerDelegate

extension PresentationManager: PresentationControllerDelegate {
    public func presentationController(_ controller: PresentationController, didTapDimmingView dimmingView: UIView) {
        delegate?.presentationManager(self, presentationController: controller, didTapDimmingView: dimmingView)
    }
}
