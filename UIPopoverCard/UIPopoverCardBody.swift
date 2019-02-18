//
//  UIPopoverCardBody.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 17/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import Foundation
import UIKit

/// Popover card body with content view from UIView or XIB
public protocol UIPopoverCardBodyProtocol {
  var view: UIView { get }
  var contentView: UIView? { get }
  init(view: UIView)
  init(xibName: String)
}

public final class UIPopoverCardBody: UIPopoverCardBodyProtocol {

  public let view: UIView = UIView(frame: CGRect.zero)
  public private(set) var contentView: UIView?

  public init(view: UIView) {
    setupBodyView()
    setContentView(view: view)
  }

  public init(xibName: String) {
    setupBodyView()
    setContentView(xibName: xibName)
  }

  private func setupBodyView() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
  }

  private func setContentView(view contentView: UIView) {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)

    let constraints: [NSLayoutConstraint] = [
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      ]

    NSLayoutConstraint.activate(constraints)
    self.contentView = contentView
  }

  private func setContentView(xibName name: String) {
    guard let xib = UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView else {
      fatalError("Xib \(name) don't cast to UIView!")
    }

    setContentView(view: xib)
  }
}
