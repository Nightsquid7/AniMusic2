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
    override var frameOfPresentedViewInContainerView: CGRect {
        var frame: CGRect = .zero
        frame.size = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)

        guard let parentViewLayoutGuide = containerView?.safeAreaLayoutGuide else { return frame }
        
        frame.size.height = parentViewLayoutGuide.layoutFrame.height
        frame.origin.y = (containerView!.bounds.height - parentViewLayoutGuide.layoutFrame.height + 10e6)

        return frame
    }
    override var shouldRemovePresentersView: Bool { return false }

    // MARK: - Initializers
    override init(presentedViewController: UIViewController,
         presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }

    override func containerViewWillLayoutSubviews() {
      presentedView?.frame = frameOfPresentedViewInContainerView
    }

    override func size(forChildContentContainer container: UIContentContainer,
                       withParentContainerSize parentSize: CGSize) -> CGSize {

        return CGSize(width: parentSize.width*(2.0/3.0), height: parentSize.height)
  }

}
