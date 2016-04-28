/*
  Copyright © 23/04/2016 Shaps

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
 */

import UIKit

/// This accessory view is used in Peek to show a 'switch' representing the underlying Bool value
final class BoolAccessoryView: UIView {
  
  private let size = CGSizeMake(26, 16)
  private let value: Bool
  
  init(value: Bool) {
    self.value = value
    super.init(frame: CGRectMake(0, 0, size.width, size.height))
    self.backgroundColor = UIColor.clearColor()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func drawRect(rect: CGRect) {
    super.drawRect(rect)
    
    let rect = rect.insetBy(dx: 1, dy: 1)
    
    var bgColor: UIColor
    let bgPath = UIBezierPath(roundedRect: rect, cornerRadius: rect.height / 2)
    
    var fgColor: UIColor
    var fgPath: UIBezierPath
    
    if value {
      bgColor = UIColor(white: 1, alpha: 1)
      fgColor = UIColor.secondaryColor()
      fgPath = UIBezierPath(ovalInRect: CGRectMake(rect.maxX - rect.height, rect.minY, rect.height, rect.height))
    } else {
      bgColor = UIColor(white: 1, alpha: 0.3)
      fgColor = UIColor(white: 1, alpha: 0.5)
      fgPath = UIBezierPath(ovalInRect: CGRectMake(rect.minX, rect.minY, rect.height, rect.height))
    }
    
    bgColor.setFill()
    bgPath.fill()
    
    fgColor.setFill()
    fgPath.fill()
  }
  
  override func intrinsicContentSize() -> CGSize {
    return CGSizeMake(size.width, size.height)
  }
  
}