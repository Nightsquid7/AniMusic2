//
//  SlideInPresentationManager.swift
//  iOS
//
//  Created by Steven Berkowitz on R 2/03/26.
//  Copyright © Reiwa 2 nightsquid. All rights reserved.
//

import UIKit

final class SlideInPresentationManager: NSObject {}

extension SlideInPresentationManager: UIViewControllerTransitioningDelegate {
    func presentationController(
        forPresented presented: UIViewController,
        presenting: UIViewController?,
        source: UIViewController) -> UIPresentationController? {
        let presentationController = SlideInPresentationController(presentedViewController: presented, presenting: presenting)
        presentationController.delegate = self
        return presentationController
    }

    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(isPresentation: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideInPresentationAnimator(isPresentation: false)
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate
extension SlideInPresentationManager: UIAdaptivePresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController,
                                   traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }

    func presentationController(_ controller: UIPresentationController,
                                viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        guard case(.overFullScreen) = style else { return nil }
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shit)")
    }
}
