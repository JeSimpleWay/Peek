//
//  Button.swift
//  Track
//
//  Created by Shaps Mohsenin on 09/02/2016.
//  Copyright © 2016 Snippex. All rights reserved.
//

import UIKit
import pop

protocol ButtonDelegate: class {
  func button(button: Button, didChangeValue value: Double?)
}

@IBDesignable
class Button: UIControl, UITextFieldDelegate {
  
  weak var delegate: ButtonDelegate?
  
  var tapGesture: UITapGestureRecognizer!
  @IBOutlet var textField: UITextField! {
    didSet {
      textField.delegate = self
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    textField.enabled = false
    
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(Button.handleTap(_:)))
    addGestureRecognizer(tapGesture)
    
    tintColor = UIColor.clearColor()
  }

  func handleTap(gesture: UITapGestureRecognizer) {
    switch gesture.state {
    case .Ended:
      textField.enabled = true
      textField.becomeFirstResponder()
      
      let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
      animation.springBounciness = 20
      animation.toValue = NSValue(CGPoint: CGPointMake(1, 1))
      pop_addAnimation(animation, forKey: "pop")
    default:
      break
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesBegan(touches, withEvent: event)
    
    if textField.isFirstResponder() {
      return
    }
    
    let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    animation.springBounciness = 20
    animation.toValue = NSValue(CGPoint: CGPointMake(0.8, 0.8))
    pop_addAnimation(animation, forKey: "pop")
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    super.touchesEnded(touches, withEvent: event)
    
    let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    animation.springBounciness = 20
    animation.toValue = NSValue(CGPoint: CGPointMake(1, 1))
    pop_addAnimation(animation, forKey: "pop")
  }
  
  override var tintColor: UIColor! {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var borderWidth: CGFloat = 2 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  @IBInspectable var borderSpacing: CGFloat = 3 {
    didSet {
      setNeedsDisplay()
    }
  }
  
  func textFieldDidEndEditing(textField: UITextField) {
    textField.enabled = false
    
    if textField.text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
      delegate?.button(self, didChangeValue: nil)
    } else {
      delegate?.button(self, didChangeValue: NSString(string: textField.text!).doubleValue)
    }
  }
  
  static let formatter = NSNumberFormatter()
  
  func setValue(value: Double?, animated: Bool) {
    
    Button.formatter.minimumFractionDigits = 0
    Button.formatter.maximumFractionDigits = 1

    let fade = CATransition()
    fade.type = kCATransitionFade
    fade.duration = animated ? 0.2 : 0
    
    textField.layer.addAnimation(fade, forKey: "fade")
    
    if let value = value {
      let animation = POPBasicAnimation(propertyNamed: kPOPViewTintColor)
      
      animation.duration = animated ? 0.3 : 0
      animation.toValue = UIColor(red: 0.302, green: 0.922, blue: 0.169, alpha: 1.00)
      pop_addAnimation(animation, forKey: "color")
      
      textField.text = Button.formatter.stringFromNumber(value)
    } else {
      let animation = POPBasicAnimation(propertyNamed: kPOPViewTintColor)
      
      animation.duration = animated ? 0.3 : 0
      animation.toValue = UIColor(red: 1.000, green: 0.224, blue: 0.624, alpha: 1.00)
      pop_addAnimation(animation, forKey: "color")
      
      textField.text = nil
    }

    let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
    
    animation.springBounciness = 15
    animation.springSpeed = 10
    animation.toValue = NSValue(CGPoint: CGPointMake(1.1, 1.1))
    
    if !animated {
      return
    }
    
    pop_addAnimation(animation, forKey: "pop")
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
      let animation = POPSpringAnimation(propertyNamed: kPOPViewScaleXY)
      
      animation.springBounciness = 15
      animation.springSpeed = 20
      animation.toValue = NSValue(CGPoint: CGPointMake(1, 1))
      
      self.pop_addAnimation(animation, forKey: "pop")
    }
  }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    tintColor.set()
    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), borderWidth)
    
    var frame = rect.insetBy(dx: 2, dy: 2)
    var path = UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2)
    path.lineWidth = borderWidth
    path.stroke()
    
    frame = rect.insetBy(dx: borderWidth + borderSpacing, dy: borderWidth + borderSpacing)
    path = UIBezierPath(roundedRect: frame, cornerRadius: frame.width / 2)
    path.fill()
  }

}
