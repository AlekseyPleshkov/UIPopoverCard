//
//  UIPopoverCardConfiguration.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 18/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import UIKit

/// Configuration popover views
public protocol UIPopoverCardConfigurationProtocol {
  var overlayColor: UIColor { get }
  var overlayAlpha: CGFloat { get }
  var cardBackgroundColor: UIColor { get }
  var headerCardLineColor: UIColor { get }
  /// Height for header card line
  var headerCardHeight: CGFloat { get }
  var isShowBackground: Bool { get }
  /// Hide popover if tap on background
  var isHideCardTapToBackground: Bool { get }
  var visibleAnimationDuration: TimeInterval { get }
  var changeStateAnimationDuration: TimeInterval { get }
  /// Available states of card sizes
  var availableStates: [UIPopoverCardState] { get }
  /// Adaptive by content. Ignoring availableStates
  var isAdaptiveByContent: Bool { get }
  /// Hide or show header on card
  var isShowHeader: Bool { get }
  /// Change height card by swipe
  var isChangeSizeBySwipe: Bool { get }
}

public struct UIPopoverCardConfiguration: UIPopoverCardConfigurationProtocol {
  public var overlayColor: UIColor = UIColor.lightGray
  public var overlayAlpha: CGFloat = 0.5
  public var cardBackgroundColor: UIColor = UIColor.white
  public var headerCardHeight: CGFloat = 20
  public var headerCardLineColor: UIColor = UIColor.lightGray
  public var isShowBackground: Bool = true
  public var isHideCardTapToBackground: Bool = true
  public var visibleAnimationDuration: TimeInterval = 0.35
  public var changeStateAnimationDuration: TimeInterval = 0.5
  public var availableStates: [UIPopoverCardState] = [.small, .middle, .large]
  public var isAdaptiveByContent: Bool = false
  public var isShowHeader: Bool = true
  public var isChangeSizeBySwipe: Bool = true

  public init() {
    //
  }
}
