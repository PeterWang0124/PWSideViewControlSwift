//
//  PWSideViewControlSwift.swift
//  PWSideViewControlSwift
//
//  Created by PeterWang on 7/16/15.
//  Copyright (c) 2015 PeterWang. All rights reserved.
//

import UIKit

//
// MARK: - Private Key Words
//
private let kPWSlideConstraint = "kPWSlideConstraint"
private let kPWTopConstraint = "kPWTopConstraint"
private let kPWBottomConstraint = "kPWBottomConstraint"
private let kPWWidthConstraint = "kPWWidthConstraint"

//
// MARK: - Public Enum
//
public enum PWSideViewCoverMode {
  case FullInSuperView
  case CoverNavigationBarView
}

public enum PWSideViewSizeMode {
  case Scale
  case Constant
}

//
// MARK: - PWSideViewControlSwift
//
public class PWSideViewControlSwift: UIView, UIGestureRecognizerDelegate {
  // MARK: Public Variables
  var coverMode: PWSideViewCoverMode = .FullInSuperView {
    didSet {
      addToView()
    }
  }
  var maskColor: UIColor = UIColor(white: 0, alpha: 0.5) {
    didSet {
      configView()
    }
  }
  var leftSideViewWidthSizeMode: PWSideViewSizeMode = .Scale {
    didSet {
      if let leftSideView = self.leftViewController?.view {
        setupLeftSideHiddenLayoutConstraints(leftSideView)
      }
    }
  }
  var leftSideViewWidthValue: CGFloat = 0.75 {
    didSet {
      if let leftSideView = self.leftViewController?.view {
        setupLeftSideHiddenLayoutConstraints(leftSideView)
      }
    }
  }
  var maskViewDidTapped: (() -> Void)?
  private(set) var leftSideViewHidden: Bool = true
  
  // MARK: Private Variables
  private var embeddedViewController: UIViewController?
  private var leftViewController: UIViewController?
  private var canShowHideLeftSideView: Bool = true
  private var leftSideViewWidthConstraint: NSLayoutConstraint?
  private var leftSideViewSlideConstraint: NSLayoutConstraint?
  private var leftSideViewConstraints = [String: NSLayoutConstraint]()
  
  // MARK: - Initializer
  public init(embeddedViewController: UIViewController, leftViewController: UIViewController) {
    super.init(frame: embeddedViewController.view.frame)
    self.embeddedViewController = embeddedViewController
    self.leftViewController = leftViewController
    
    setupView()
  }
  
  public required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  // MARK: - Public functioins
  public func showLeftView(#duration: NSTimeInterval, animated: Bool) {
    if self.canShowHideLeftSideView {
      self.canShowHideLeftSideView = false
      self.leftSideViewHidden = false
      if let leftVC = self.leftViewController {
        if let constraint = self.leftSideViewSlideConstraint {
          removeConstraint(constraint)
        }
        self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftVC.view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        addConstraint(self.leftSideViewSlideConstraint!)
        self.leftSideViewConstraints[kPWSlideConstraint] = self.leftSideViewSlideConstraint
      }
      
      self.hidden = false
      if animated {
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseOut,
          animations: { _ in
            self.alpha = 1
            self.layoutIfNeeded()
          }, completion: { _ in
            self.canShowHideLeftSideView = true
        })
      } else {
        self.alpha = 1
        self.canShowHideLeftSideView = true
        layoutIfNeeded()
      }
    }
  }
  
  public func hideLeftView(#duration: NSTimeInterval, animated: Bool) {
    if self.canShowHideLeftSideView {
      self.canShowHideLeftSideView = false
      self.leftSideViewHidden = true
      if let leftVC = self.leftViewController {
        if let constraint = self.leftSideViewSlideConstraint {
          removeConstraint(constraint)
        }
        self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftVC.view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        addConstraint(self.leftSideViewSlideConstraint!)
        self.leftSideViewConstraints[kPWSlideConstraint] = self.leftSideViewSlideConstraint
      }
      
      if animated {
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseIn,
          animations: { _ in
            self.alpha = 0
            self.layoutIfNeeded()
          }, completion: { _ in
            self.hidden = false
            self.canShowHideLeftSideView = true
        })
      } else {
        self.alpha = 0
        self.hidden = false
        self.canShowHideLeftSideView = true
        layoutIfNeeded()
      }
    }
  }
  
  // MARK: - Private functions
  private func setupView() {
    self.hidden = true
    self.alpha = 0
    let tapGR = UITapGestureRecognizer(target: self, action: "maskViewTapped:")
    tapGR.delegate = self
    addGestureRecognizer(tapGR)
    configView()
    
    // Add view to
    addToView()
    
    // Add side controller view
    if let leftVC = self.leftViewController {
      addSubview(leftVC.view)
      setupLeftSideHiddenLayoutConstraints(leftVC.view)
    }
  }
  
  private func addToView() {
    switch self.coverMode {
    case .CoverNavigationBarView:
      if let currendtWindow = UIApplication.sharedApplication().delegate?.window ?? nil {
        currendtWindow.addSubview(self)
        setupViewLayoutConstraints()
      }
      
    default:
      if let embeddedVC = self.embeddedViewController {
        embeddedVC.view.addSubview(self)
        setupViewLayoutConstraints()
      }
    }
  }
  
  private func setupViewLayoutConstraints() {
    if let superView = self.superview {
      self.setTranslatesAutoresizingMaskIntoConstraints(false)
      let topConstraint = NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superView, attribute: .Top, multiplier: 1, constant: 0)
      superView.addConstraint(topConstraint)
      
      let bottomConstraint = NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superView, attribute: .Bottom, multiplier: 1, constant: 0)
      superView.addConstraint(bottomConstraint)
      
      let leadingConstraint = NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: superView, attribute: .Leading, multiplier: 1, constant: 0)
      superView.addConstraint(leadingConstraint)
      
      let trailingConstraint = NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: superView, attribute: .Trailing, multiplier: 1, constant: 0)
      superView.addConstraint(trailingConstraint)
    }
  }
  
  private func setupLeftSideHiddenLayoutConstraints(leftSideView: UIView) {
    removeConstraints(self.leftSideViewConstraints.values.array)
    self.leftSideViewConstraints.removeAll(keepCapacity: true)
    leftSideView.setTranslatesAutoresizingMaskIntoConstraints(false)
    let topConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
    addConstraint(topConstraint)
    self.leftSideViewConstraints[kPWTopConstraint] = topConstraint
    
    let bottomConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
    addConstraint(bottomConstraint)
    self.leftSideViewConstraints[kPWBottomConstraint] = bottomConstraint
    
    self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
    addConstraint(self.leftSideViewSlideConstraint!)
    self.leftSideViewConstraints[kPWSlideConstraint] = self.leftSideViewSlideConstraint
    
    switch self.leftSideViewWidthSizeMode {
    case .Constant:
      self.leftSideViewWidthConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.leftSideViewWidthValue)
      
    default:
      self.leftSideViewWidthConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: self.leftSideViewWidthValue, constant: 0)
    }
    addConstraint(self.leftSideViewWidthConstraint!)
    self.leftSideViewConstraints[kPWWidthConstraint] = self.leftSideViewWidthConstraint
  }
  
  // MARK: - Configure
  private func configView() {
    self.backgroundColor = self.maskColor
    setNeedsDisplay()
  }
  
  // MARK: - Gesture Recognizer Action
  func maskViewTapped(recognizer: UITapGestureRecognizer) {
    if self.maskViewDidTapped != nil {
      self.maskViewDidTapped!()
    }
  }
  
  public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
    if touch.view.isDescendantOfView(self) && touch.view != self {
      return false
    }
    
    return true
  }
}
