
//
//  OverlayViewController.swift
//  Pods
//
//  Created by Shaps Mohsenin on 06/02/2016.
//
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

final class PeekViewController: UIViewController, UIViewControllerTransitioningDelegate {
  
  unowned var peek: Peek
  
  init(peek: Peek) {
    self.peek = peek
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private var models = [UIView]()
  private var isDragging: Bool = false {
    didSet {
      self.overlayView.isDragging = isDragging
    }
  }
  
  lazy var overlayView: OverlayView = {
    let view = OverlayView(peek: self.peek)
    view.backgroundColor = UIColor.clearColor()
    return view
  }()
  
  lazy var panGesture: UIPanGestureRecognizer = {
    return UIPanGestureRecognizer(target: self, action: #selector(PeekViewController.handlePan(_:)))
  }()
  
  lazy var tapGesture: UITapGestureRecognizer = {
    return UITapGestureRecognizer(target: self, action: #selector(PeekViewController.handleTap(_:)))
  }()
  
  lazy var doubleTapGesture: PeekTapGestureRecognizer = {
    let gesture = PeekTapGestureRecognizer(target: self, action: #selector(PeekViewController.handleTap(_:)))
    gesture.numberOfTapsRequired = 2
    return gesture
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "" // this is to remove the back button title
    view.addSubview(overlayView)
    overlayView.pin(.All, toView: view)
    
    parseView(peek.peekingWindow)
    updateBackgroundColor(alpha: 0.5)
    
    overlayView.addGestureRecognizer(panGesture)
    overlayView.addGestureRecognizer(tapGesture)
    overlayView.addGestureRecognizer(doubleTapGesture)
    tapGesture.requireGestureRecognizerToFail(doubleTapGesture)
  }
  
  private func addModelForView(view: UIView) {
    if !view.shouldIgnore {
      models.append(view)
    }
  }
  
  func updateSelectedModels(gesture: UIGestureRecognizer) {
    let location = gesture.locationInView(gesture.view)
    
    for model in models {
      let rect = model.frameInPeek(view)
      
      if rect.contains(location) {
        if let models = overlayView.selectedModels {
          if !models.contains(model) {
            if isDragging {
              overlayView.selectedModels = [model]
            } else {
              if let previous = models.last {
                overlayView.selectedModels = [previous, model]
              } else {
                overlayView.selectedModels = [model]
              }
            }
          }
        }
        
        overlayView.selectedModels = [model]
      }
    }
  }
  
  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animateAlongsideTransitionInView(view, animation: { (context) -> Void in
      self.overlayView.reload()
    }, completion: nil)
  }
  
  private func parseView(view: UIView) {
    for view in view.subviews {
      addModelForView(view)
      
      if view.subviews.count > 0 {
        parseView(view)
      }
    }
  }
  
  private func updateBackgroundColor(alpha alpha: CGFloat) {
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(alpha)
    
    let animation = CATransition()
    animation.type = kCATransitionFade
    animation.duration = 0.1
    view.layer.addAnimation(animation, forKey: "fade")
  }
  
  private func presentInspectorsForModel(model: Model) {
    if let model = model as? UIView {
      let controller = InspectorsTabBarController(peek: peek, model: model)
      
      controller.view.frame = view.bounds // this is to ensure status bar changes are supported
      controller.popoverPresentationController?.sourceView = overlayView.primaryView
      controller.popoverPresentationController?.backgroundColor = UIColor(white: 0, alpha: 0.5)
      controller.transitioningDelegate = self
      
      let bounds = overlayView.primaryView.bounds
      let rect = CGRect(x: bounds.midX - 1, y: bounds.midY - 1, width: 2, height: 2)
      
      controller.popoverPresentationController?.sourceRect = rect
      
      presentViewController(controller, animated: true, completion: nil)
    }
  }
  
  @objc private func handleTap(gesture: UITapGestureRecognizer) {
    if gesture.state == .Ended {
      if gesture === doubleTapGesture {
        if let model = overlayView.selectedModels?.last {
          presentInspectorsForModel(model)
        }
      } else {
        updateSelectedModels(gesture)
      }
    }
  }
  
  @objc private func handlePan(gesture: UIPanGestureRecognizer) {
    switch gesture.state {
    case .Began:
      updateBackgroundColor(alpha: 0.3)
      isDragging = true
      break
    case .Changed:
      updateSelectedModels(gesture)
      break
    default:
      updateBackgroundColor(alpha: 0.5)
      isDragging = false
    }
  }
  
  override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
    return peek.supportedOrientations
  }
  
  override func prefersStatusBarHidden() -> Bool {
    return peek.previousStatusBarHidden
  }
  
  override func preferredStatusBarStyle() -> UIStatusBarStyle {
    return peek.previousStatusBarStyle
  }
  
  // MARK: Transitions
  
  func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TransitionFadeAnimator(peek: peek, operation: .Push)
  }
  
  func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return TransitionFadeAnimator(peek: peek, operation: .Pop)
  }
  
}

