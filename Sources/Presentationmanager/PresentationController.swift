//
//  PresentationController.swift
//  PresentationManager
//
//  Created by sai on 05/04/2017.
//

import UIKit
import Combine

public protocol PresentationControllerDelegate: UIAdaptivePresentationControllerDelegate {
    func presentationController(_ controller: PresentationController, didTapDimmingView dimmingView: UIView)
}

let isiPhoneXMore: Bool = {
    var isMore:Bool = false
    if #available(iOS 11.0, *) {
        isMore = UIApplication.shared.windows[0].safeAreaInsets.bottom > CGFloat(0)
    }
    return isMore
}()

open class PresentationController: UIPresentationController {
    override open var frameOfPresentedViewInContainerView: CGRect {
        let containerViewSize = self.containerView?.bounds.size ?? .zero
        var frame: CGRect = .zero
        frame.size = self.size(forChildContentContainer: self.presentedViewController, withParentContainerSize: containerViewSize)

        switch self.direction {
        case .right:
            if #available(iOS 11.0, *) {
                if frame.size.width < containerViewSize.width {
                    let width = frame.size.width + self.presentedViewController.view.safeAreaInsets.right
                    frame.size.width = min(width, containerViewSize.width)
                }
            }
            frame.origin.x = containerViewSize.width - frame.size.width
        case .bottom:
            if #available(iOS 11.0, *) {
                if frame.size.height < containerViewSize.height {
                    let height = frame.size.height + self.presentedViewController.view.safeAreaInsets.bottom
                    frame.size.height = min(height, containerViewSize.height)
                }
            }
            frame.origin.y = containerViewSize.height - frame.size.height
            
            let isLandscape = UIWindow.orientation == .landscapeLeft || UIWindow.orientation == .landscapeRight
            let statusBarHeight = (isiPhoneXMore && isLandscape) ? 44.0 : 0.0
            let offsetx: CGFloat = CGFloat(statusBarHeight * 2.0)
            let width = min(self.presentingViewController.view.bounds.width - offsetx, frame.size.width)
            frame.origin.x = (self.presentingViewController.view.bounds.width - width) * 0.5
            frame.size.width = width
        case .center:
            let expectY = (containerViewSize.height - frame.height) / 2
            let adjustHeight: CGFloat = max(keyboardHeight - expectY, 0)
            frame.origin = CGPoint(x: (containerViewSize.width - frame.width) / 2,
                                   y: (containerViewSize.height - frame.height) / 2 - adjustHeight)
        case .top:
            if #available(iOS 11.0, *) {
                if frame.size.height < containerViewSize.height {
                    let height = frame.size.height + self.presentedViewController.view.safeAreaInsets.top
                    frame.size.height = min(height, containerViewSize.height)
                }
            }
            frame.origin = .zero
        case .left:
            if #available(iOS 11.0, *) {
                if frame.size.width < containerViewSize.width {
                    let width = frame.size.width + self.presentedViewController.view.safeAreaInsets.left
                    frame.size.width = min(width, containerViewSize.width)
                }
            }
            frame.origin = .zero
        }
        return frame
    }
    fileprivate var keyboardHeight: CGFloat = 0 {
        didSet {
            containerViewWillLayoutSubviews()
        }
    }
    fileprivate var dimmingView: UIView!
    public let direction: PresentationDirection
    public let presentationSize: PresentationSizeProtocol
    public let cornerRadius: CGFloat
    public let alphaValue: CGFloat
    public init(presentedViewController: UIViewController,
                presenting presentingViewController: UIViewController?,
                direction: PresentationDirection,
                presentationSize: PresentationSizeProtocol,
                cornerRadius: CGFloat,
                alphaValue: CGFloat) {
        self.direction = direction
        self.presentationSize = presentationSize
        self.cornerRadius = cornerRadius
        self.alphaValue = alphaValue
        
        super.init(presentedViewController: presentedViewController,
                   presenting: presentingViewController)
        
        setupDimmingView()
    }
    
    override open func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return self.presentationSize.size(forChildContentContainer: container, withParentContainerSize: parentSize)
    }
    
    open override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if self.containerView != nil {
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
    }
    
    override open func containerViewWillLayoutSubviews() {
        self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        
        switch self.direction {
        case .center:
            if self.cornerRadius > 0 {
                self.presentedView?.layer.cornerRadius = self.cornerRadius
                self.presentedView?.clipsToBounds = true
            }
        case .bottom:
            if #available(iOS 11.0, *) {
                self.presentedView?.layer.cornerRadius = 17
                self.presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                self.presentedView?.clipsToBounds = true
            }
        case .top, .left, .right: ()
        }
    }
    
    override open func presentationTransitionWillBegin() {
        self.containerView?.insertSubview(dimmingView, at: 0)
        
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dimmingView]|", options: [], metrics: nil, views: ["dimmingView": dimmingView]))
        
        guard let coordinator = self.presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 1.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 1.0
        })
    }
    
    override open func dismissalTransitionWillBegin() {
        guard let coordinator = self.presentedViewController.transitionCoordinator else {
            self.dimmingView.alpha = 0.0
            return
        }
        
        coordinator.animate(alongsideTransition: { _ in
            self.dimmingView.alpha = 0.0
        })
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}

// MARK: - Private

private extension PresentationController {
    func setupDimmingView() {
        self.dimmingView = UIView()
        self.dimmingView.translatesAutoresizingMaskIntoConstraints = false
        self.dimmingView.backgroundColor = UIColor(white: 0.0, alpha: self.alphaValue)
        self.dimmingView.alpha = 0.0
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        self.dimmingView.addGestureRecognizer(recognizer)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardValue.cgRectValue
        if notification.name == UIResponder.keyboardWillHideNotification {
            keyboardHeight = 0
        } else {
            keyboardHeight = keyboardFrame.height
        }
    }
    
    @objc dynamic func handleTap(recognizer: UITapGestureRecognizer) {
        guard let delegate = self.delegate as? PresentationControllerDelegate else {
            self.presentingViewController.dismiss(animated: true)
            return
        }
        delegate.presentationController(self, didTapDimmingView: dimmingView)
    }
}
