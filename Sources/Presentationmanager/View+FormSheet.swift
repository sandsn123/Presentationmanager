//
//  View+FormSheet.swift
//  C30NRender
//
//  Created by 李赛 on 2023/6/1.
//

import SwiftUI
import Combine

@available(iOS 13.0, *)
class ModalUIHostingController<Content>: UIHostingController<Content> where Content : View {
    var onDismiss: (() -> Void)
    
    required init?(coder: NSCoder) { fatalError("") }
    
    init(presentationManager: PresentationManager, onDismiss: @escaping () -> Void, rootView: Content) {
        self.onDismiss = onDismiss
        super.init(rootView: rootView)
        
        view.sizeToFit()
        
        preferredContentSize = view.bounds.size
        modalPresentationStyle = .custom
        transitioningDelegate = presentationManager
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    deinit {
        print("ModalUIHostingController deinit")
    }
}

@available(iOS 13.0, *)
class ModalUIViewController<Content: View>: UIViewController, PresentationManagerDelegate {
    var isPresented: Bool
    var presentationManager: PresentationManager
    var content: () -> Content
    var onDismiss: (() -> Void)
    private weak var hostVC: ModalUIHostingController<Content>?
    
    private var isViewDidAppear = false
    
    required init?(coder: NSCoder) { fatalError("") }
    
    init(presentationManager: PresentationManager, isPresented: Bool = false, onDismiss: @escaping () -> Void, content: @escaping () -> Content) {
        self.isPresented = isPresented
        self.onDismiss = onDismiss
        self.presentationManager = presentationManager
        self.content = content
        
        super.init(nibName: nil, bundle: nil)
        presentationManager.delegate = self
        
        let hostVc = ModalUIHostingController(presentationManager: presentationManager, onDismiss: onDismiss, rootView: content())
        self.hostVC = hostVc
        self.addChild(hostVc)
    }
    
    func show() {
        guard let hostVC, isViewDidAppear, self.presentedViewController == nil else { return }
        present(hostVC, animated: true)
    }
    
    func hide() {
        guard let hostVC else { return }
        guard !hostVC.isBeingDismissed else { return }
        hostVC.dismiss(animated: true)
        hostVC.removeFromParent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        isViewDidAppear = true
        if isPresented {
            show()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isViewDidAppear = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        show()
    }
    
    func presentationManager(_ manager: PresentationManager, presentationController: PresentationController, didTapDimmingView dimmingView: UIView) {
        onDismiss()
    }
}


@available(iOS 13.0, *)
struct FormSheet<Content: View> : UIViewControllerRepresentable {
    @Binding var show: Bool
    let presentationManager: PresentationManager
    let content: () -> Content
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<FormSheet<Content>>) -> ModalUIViewController<Content> {
    
        
        let onDismiss = {
            self.show = false
        }
        
        let vc = ModalUIViewController(presentationManager: presentationManager, isPresented: show, onDismiss: onDismiss, content: content)
        vc.view.backgroundColor = .clear
        return vc
    }
    
    func updateUIViewController(_ uiViewController: ModalUIViewController<Content>,
                                context: UIViewControllerRepresentableContext<FormSheet<Content>>) {
        if show {
            uiViewController.show()
        }
        else {
            uiViewController.hide()
        }
    }
    
}

@available(iOS 13.0, *)
extension View {
    public func lspresent<Content: View>(isPresented: Binding<Bool>,
                                         presentationManager: PresentationManager,
                                         @ViewBuilder content: @escaping () -> Content) -> some View {
        self.background(
            FormSheet(show: isPresented, presentationManager: presentationManager,
                              content: content)
         )
    }
}
