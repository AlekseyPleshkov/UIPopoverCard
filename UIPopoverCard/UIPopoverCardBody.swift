//
//  UIPopoverCardBody.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 17/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import UIKit

/// Popover card body with content view from UIView or XIB
public protocol UIPopoverCardBodyProtocol {
  /// Main body view
  var view: UIView { get }

  /// Content view from view or xib
  var containerView: UIView? { get }

  /// Init from view
  init(view: UIView)

  /// Init from xib name
  init(xibName: String)
}

public final class UIPopoverCardBody: UIPopoverCardBodyProtocol {

  // MARK: - Public Properties

  public let view: UIView = UIView(frame: CGRect.zero)
  public private(set) var containerView: UIView?

  // MARK: - Init

  public init(view: UIView) {
    setupBodyView()
    addContentView(view: view)
  }

  public init(xibName: String) {
    setupBodyView()
    addContentView(xibName: xibName)
  }

  // MARK: - Private methods

  private func setupBodyView() {
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
  }

  private func addContentView(view contentView: UIView) {
    contentView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(contentView)

    let constraints: [NSLayoutConstraint] = [
      contentView.topAnchor.constraint(equalTo: view.topAnchor),
      contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ]

    NSLayoutConstraint.activate(constraints)
    containerView = contentView
  }

  private func addContentView(xibName name: String) {
    guard let xib = UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? UIView else {
      fatalError("Xib file \(name) don't cast to UIView!")
    }

    addContentView(view: xib)
  }
}
