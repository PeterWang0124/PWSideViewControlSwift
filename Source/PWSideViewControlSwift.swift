//
//  PWSideViewControlSwift.swift
//  PWSideViewControlSwift
//
//  Created by PeterWang on 7/16/15.
//  Copyright (c) 2015 PeterWang. All rights reserved.
//

import UIKit

//
// MARK: - PWSideViewCoverMode
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
public class PWSideViewControlSwift: UIView {
  
  // MARK: Public Variables
  var embeddedViewController: UIViewController?
  var leftViewController: UIViewController?
  var coverMode: PWSideViewCoverMode = .FullInSuperView
  var maskColor: UIColor = UIColor(white: 0, alpha: 0.5) {
    didSet {
      configView()
    }
  }
  var leftSideViewWidthSizeMode: PWSideViewSizeMode = .Scale
  var leftSideViewWidthValue: CGFloat = 0.75
  private(set) var leftSideViewHidden: Bool = true
  
  // MARK: Private Variables
  private var canShowHideLeftSideView: Bool = true
  private var leftSideViewWidthConstraint: NSLayoutConstraint?
  private var leftSideViewSlideConstraint: NSLayoutConstraint?
  
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
  public func showLeftView() {
    if self.canShowHideLeftSideView {
      self.canShowHideLeftSideView = false
      self.leftSideViewHidden = false
      if let leftVC = self.leftViewController {
        if let constraint = self.leftSideViewSlideConstraint {
          self.removeConstraint(constraint)
        }
        self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftVC.view, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        addConstraint(self.leftSideViewSlideConstraint!)
      }
      
      self.hidden = false
      UIView.animateWithDuration(1, animations: { _ in
        self.alpha = 1
        self.layoutIfNeeded()
        }, completion: { _ in
          self.canShowHideLeftSideView = true
      })
    }
  }
  
  public func hideLeftView() {
    if self.canShowHideLeftSideView {
      self.canShowHideLeftSideView = false
      self.leftSideViewHidden = true
      if let leftVC = self.leftViewController {
        if let constraint = self.leftSideViewSlideConstraint {
          removeConstraint(constraint)
        }
        self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftVC.view, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
        addConstraint(self.leftSideViewSlideConstraint!)
      }
      
      UIView.animateWithDuration(1, animations: { _ in
        self.alpha = 0
        self.layoutIfNeeded()
        }, completion: { _ in
          self.hidden = false
          self.canShowHideLeftSideView = true
      })
    }
  }
  
  // MARK: - Private functions
  private func setupView() {
    self.hidden = true
    self.alpha = 0
    configView()
    
    // Add view to
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
    
    // Add side controller view
    if let leftVC = self.leftViewController {
      addSubview(leftVC.view)
      setupLeftSideHiddenLayoutConstraints(leftVC.view)
    }
  }
  
  private func removeView() {
    removeFromSuperview()
    self.leftViewController?.view.removeFromSuperview()
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
    leftSideView.setTranslatesAutoresizingMaskIntoConstraints(false)
    let topConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1, constant: 0)
    addConstraint(topConstraint)
    
    let bottomConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1, constant: 0)
    addConstraint(bottomConstraint)
    
    self.leftSideViewSlideConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1, constant: 0)
    addConstraint(self.leftSideViewSlideConstraint!)
    
    switch self.leftSideViewWidthSizeMode {
    case .Constant:
      self.leftSideViewWidthConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: self.leftSideViewWidthValue)
      
    default:
      self.leftSideViewWidthConstraint = NSLayoutConstraint(item: leftSideView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: self.leftSideViewWidthValue, constant: 0)
    }
    addConstraint(self.leftSideViewWidthConstraint!)
  }
  
  // MARK: - Configure
  private func configView() {
    self.backgroundColor = self.maskColor
    setNeedsDisplay()
  }
}
