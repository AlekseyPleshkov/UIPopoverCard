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
  var isShowBackground: Bool { get }
  /// Hide popover if tap on background
  var isHideCardTapToBackground: Bool { get }
  var visibleAnimationDuration: TimeInterval { get }
  var changeStateAnimationDuration: TimeInterval { get }
  /// Available states of card sizes
  var availableStates: [UIPopoverCardState] { get }
}

public struct UIPopoverCardConfiguration: UIPopoverCardConfigurationProtocol {
  public var overlayColor: UIColor = UIColor.lightGray
  public var overlayAlpha: CGFloat = 0.5
  public var cardBackgroundColor: UIColor = UIColor.white
  public var headerCardLineColor: UIColor = UIColor.lightGray
  public var isShowBackground: Bool = true
  public var isHideCardTapToBackground: Bool = true
  public var visibleAnimationDuration: TimeInterval = 0.5
  public var changeStateAnimationDuration: TimeInterval = 0.3
  public var availableStates: [UIPopoverCardState] = [.small, .middle, .large]

  public init() {
    //
  }
}
