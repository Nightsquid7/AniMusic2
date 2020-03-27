//
//  PresentationController.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/26.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

class SlideInPresentationController: UIPresentationController {
    // MARK: - Properties
    private var dismissView: UIView!

    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)

        // align top of frame to top of navBar of presentedViewController
        guard let parentViewLayoutGuide = containerView?.safeAreaLayoutGuide else { return frame }
        frame.size.height = parentViewLayoutGuide.layoutFrame.height
        frame.origin.y = (containerView!.bounds.height - parentViewLayoutGuide.layoutFrame.height + 10)

        return frame
    }

    // MARK: - Initializers
    override init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        setUpDismissView()
    }

    override func presentationTransitionWillBegin() {
        guard let dismissView = dismissView else { return }
        containerView?.insertSubview(dismissView, at: 0)

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "V:|[dismissView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["dismissView": dismissView]))

        NSLayoutConstraint.activate(NSLayoutConstraint.constraints(withVisualFormat: "H:|[dismissView]|",
                                                                   options: [],
                                                                   metrics: nil,
                                                                   views: ["dismissView": dismissView]))

        guard let coordinator = presentedViewController.transitionCoordinator else {
          dismissView.alpha = 0.0
          return
        }

        coordinator.animate(alongsideTransition: { _ in
          self.dismissView.alpha = 0.1
        })
    }

    override func containerViewWillLayoutSubviews() {
        presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {

        return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
  }

}

// MARK: - Private
private extension SlideInPresentationController {
    func setUpDismissView() {
        dismissView = UIView()
        dismissView.translatesAutoresizingMaskIntoConstraints = false
        dismissView.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
        dismissView.alpha = 0.0

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        dismissView.addGestureRecognizer(recognizer)
    }

    @objc func handleTap(recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true)
    }
}
