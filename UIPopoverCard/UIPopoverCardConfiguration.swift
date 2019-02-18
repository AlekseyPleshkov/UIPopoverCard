//
//  UIPopoverCardConfiguration.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 18/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import Foundation
import UIKit

/// Configuration popover views
public protocol UIPopoverCardConfigurationProtocol {
  var backgroundColor: UIColor { get set }
  var backgroundBaseAlpha: CGFloat { get set }
  var cardColor: UIColor { get set }
  var isShowBackground: Bool { get set }
  /// Hide popover if tap/swift on background
  var isHideCardBackgroundTap: Bool { get set }
  var animationDuration: TimeInterval { get set }

}

public struct UIPopoverCardConfiguration: UIPopoverCardConfigurationProtocol {

  public var backgroundColor: UIColor = UIColor.lightGray
  public var backgroundBaseAlpha: CGFloat = 0.5
  public var cardColor: UIColor = UIColor.white
  public var isShowBackground: Bool = true
  public var isHideCardBackgroundTap: Bool = true
  public var animationDuration: TimeInterval = 0.3

  public init() {
    //
  }
}
