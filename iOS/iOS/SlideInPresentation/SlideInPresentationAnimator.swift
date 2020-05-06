//
//  SlideInPresentationAnimator.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/26.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

//initially copied from
// https://www.raywenderlich.com/3636807-uipresentationcontroller-tutorial-getting-started
final class SlideInPresentationAnimator: NSObject {
    // MARK: - Properties
    let isPresentation: Bool

    // MARK: - Initializers
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        // super.init()?
    }
}

// MARK: - UIViewControllerAnimatedTransition
extension SlideInPresentationAnimator: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = isPresentation ? .to : .from
        guard let controller = transitionContext.viewController(forKey: key) else { return }

        if isPresentation {
            transitionContext.containerView.addSubview(controller.view)
        }

        let presentedFrame = transitionContext.finalFrame(for: controller)
        var dismissedFrame = presentedFrame
        dismissedFrame.origin.x = -presentedFrame.width

        let initialFrame = isPresentation ? dismissedFrame : presentedFrame
        let finalFrame = isPresentation ? presentedFrame : dismissedFrame

        let animationDuration = transitionDuration(using: transitionContext)
        controller.view.frame = initialFrame
        UIView.animate(
            withDuration: animationDuration,
            animations: {
                controller.view.frame = finalFrame
        }, completion: { finished in
            if !self.isPresentation {
                controller.view.removeFromSuperview()
            }
            transitionContext.completeTransition(finished)
        })
    }
}
