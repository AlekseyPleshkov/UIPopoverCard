//
//  UIPopoverCardController.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 17/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import UIKit

public protocol UIPopoverCardDelegate {
  /// Will change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, willChangeVisible isShow: Bool)

  /// Did change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, didChangeVisible isShow: Bool)
}

public final class UIPopoverCard: UIView {

  /// Configurator for popover card
  private let configure: UIPopoverCardConfigurationProtocol

  /// Struct for setup container body view
  public let body: UIPopoverCardBodyProtocol

  /// Link to parent controller for add popover card to view
  private weak var parentController: UIViewController?

  public var delegate: UIPopoverCardDelegate?

  public let backgroundView: UIView
  public let cardView: UIView

  public var constraintCardHeight: NSLayoutConstraint?
  public var constraintCardButton: NSLayoutConstraint?

  /// Height of parent controller view
  private var parentViewHeight: CGFloat {
    guard let parent = parentController else {
      return 0
    }

    return parent.view.frame.height
  }

  /// Show state of popover card
  public var isShow: Bool = false {
    didSet {
      updateVisibilityState()
    }
  }

  // MARK: - Init

  public init(_ parent: UIViewController,
              configure: UIPopoverCardConfigurationProtocol,
              body: UIPopoverCardBodyProtocol) {
    self.configure = configure
    self.body = body

    parentController = parent
    backgroundView = UIView(frame: CGRect.zero)
    cardView = UIView(frame: CGRect.zero)

    super.init(frame: CGRect.zero)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
  }

  // MARK: - Setups

  /// Default setup views, constraints and notifications
  private func setup() {
    setupViews()
    setupConstraints()
    setupActions()
  }

  private func setupViews() {
    guard let parent = parentController else { return }

    isUserInteractionEnabled = false
    translatesAutoresizingMaskIntoConstraints = false

    backgroundView.translatesAutoresizingMaskIntoConstraints = false
    backgroundView.alpha = 0
    backgroundView.backgroundColor = configure.backgroundColor
    backgroundView.isHidden = !configure.isShowBackground

    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.layer.masksToBounds = true
    cardView.layer.cornerRadius = 6.0
    cardView.backgroundColor = configure.cardColor

    addSubview(backgroundView)
    addSubview(cardView)
    cardView.addSubview(body.view)
    parent.view.addSubview(self)
  }

  private func setupConstraints() {
    guard let parent = parentController else { return }

    let constraintCardHeight = cardView.heightAnchor.constraint(equalToConstant: parentViewHeight / 2)
    let constraintCardButton = cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: parentViewHeight)
    let constraints: [NSLayoutConstraint] = [
      topAnchor.constraint(equalTo: parent.view.topAnchor),
      leadingAnchor.constraint(equalTo: parent.view.leadingAnchor),
      trailingAnchor.constraint(equalTo: parent.view.trailingAnchor),
      bottomAnchor.constraint(equalTo: parent.view.bottomAnchor),
      //
      backgroundView.topAnchor.constraint(equalTo: topAnchor),
      backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
      backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
      backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
      //
      constraintCardHeight,
      cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
      constraintCardButton,
      //
      body.view.topAnchor.constraint(equalTo: cardView.topAnchor),
      body.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
      body.view.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
      body.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
      ]

    self.constraintCardHeight = constraintCardHeight
    self.constraintCardButton = constraintCardButton
    NSLayoutConstraint.activate(constraints)
  }

  private func setupActions() {
    NotificationCenter.default.addObserver(
      self, selector: #selector(deviceRotated),
      name: UIDevice.orientationDidChangeNotification, object: nil)

    // Close popover card if swipe or tap to background
    if configure.isHideCardBackgroundTap {
      let swipeButtonBackgroundView = UISwipeGestureRecognizer(target: self, action: #selector(gestureHideView))
      let tapBackgroundView = UITapGestureRecognizer(target: self, action: #selector(gestureHideView))

      swipeButtonBackgroundView.direction = .down
      tapBackgroundView.numberOfTapsRequired = 1
      backgroundView.addGestureRecognizer(swipeButtonBackgroundView)
      backgroundView.addGestureRecognizer(tapBackgroundView)
    }
  }

  // MARK: - Controls
  
  /// Change constraints and params in views and animate them
  private func updateVisibilityState() {
    guard
      let constraintCardButton = constraintCardButton,
      let constraintCardHeight = constraintCardHeight
      else { return }
    let backgroundViewAlpha = isShow ? configure.backgroundBaseAlpha : 0
    let cardButton = isShow ? 0 : parentViewHeight

    isUserInteractionEnabled = isShow
    constraintCardHeight.constant = parentViewHeight / 2
    constraintCardButton.constant = cardButton

    UIView.animate(withDuration: configure.animationDuration, animations: {
      self.delegate?.popoverCard(self, willChangeVisible: self.isShow)
      self.backgroundView.alpha = CGFloat(backgroundViewAlpha)
      self.layoutIfNeeded()
    }) { isEnd in
      self.delegate?.popoverCard(self, didChangeVisible: self.isShow)
    }
  }

  public func show() {
    isShow = true
  }

  public func hide() {
    isShow = false
  }

  public func toggle() {
    isShow = !isShow
  }

  // MARK: - Notifications and actions

  /// Event for device rotated
  @objc private func deviceRotated() {
    if isShow {
      updateVisibilityState()
    }
  }

  @objc private func gestureHideView() {
    hide()
  }
}
