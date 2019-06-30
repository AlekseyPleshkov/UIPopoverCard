//
//  UIPopoverCardController.swift
//  UIPopoverCard
//
//  Created by Aleksey Pleshkov on 17/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import UIKit

private enum UIPopoverCardDelegateType {
  case willChangeVisible
  case didChangeVisible
  case didChangeState
}

public protocol UIPopoverCardDelegate {
  /// Will change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, willChangeShow isVisible: Bool)

  /// Did change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, didChangeShow isVisible: Bool)

  /// Did change state of size card
  func popoverCard(_ popoverCard: UIPopoverCard, didChangeSize state: UIPopoverCardState)
}

public final class UIPopoverCard: UIView {

  // MARK: - Public Properties

  /// Delegate for notify about change state
  public var delegate: UIPopoverCardDelegate?

  public let overlayView: UIView
  public let cardView: UIView
  public let headerCardView: UIView
  public let headerLineView: UIView

  /// Visibility of card
  public private(set) var isCardVisible: Bool = false

  /// State of show card
  public private(set) var cardState: UIPopoverCardState

  public private(set) var constraintCardHeight: NSLayoutConstraint?
  public private(set) var constraintCardButton: NSLayoutConstraint?

  // MARK: - Private Properties

  /// Link to parent controller for add popover card to view
  private weak var parentController: UIViewController?

  /// Configurator for popover card
  private let configure: UIPopoverCardConfigurationProtocol

  /// Struct for setup container body view
  private let body: UIPopoverCardBodyProtocol

  /// Height of parent controller view
  private var parentViewHeight: CGFloat {
    guard let parent = parentController else {
      return 0
    }

    return parent.view.frame.height
  }

  private var minCardHeight: CGFloat = 0
  private var maxCardHeight: CGFloat = 0

  // MARK: - Init

  public init(
    _ parent: UIViewController,
    configure: UIPopoverCardConfigurationProtocol,
    body: UIPopoverCardBodyProtocol) {

    self.configure = configure
    self.body = body

    parentController = parent

    overlayView = UIView(frame: CGRect.zero)
    cardView = UIView(frame: CGRect.zero)
    headerCardView = UIView(frame: CGRect.zero)
    headerLineView = UIView(frame: .zero)

    cardState = configure.availableStates.first ?? .small

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
    setupSizes()
    setupViews()
    setupConstraints()
    setupActions()
  }

  private func setupSizes() {
    if let firstState = configure.availableStates.first {
      minCardHeight = parentViewHeight / 2 * firstState.rawValue
    }

    if let lastState = configure.availableStates.last {
      maxCardHeight = parentViewHeight * lastState.rawValue
    }
  }

  private func setupViews() {
    guard let parentController = parentController else {
      return
    }

    isUserInteractionEnabled = false
    translatesAutoresizingMaskIntoConstraints = false

    overlayView.translatesAutoresizingMaskIntoConstraints = false
    overlayView.alpha = 0
    overlayView.backgroundColor = configure.overlayColor
    overlayView.isHidden = !configure.isShowBackground

    cardView.translatesAutoresizingMaskIntoConstraints = false
    cardView.backgroundColor = configure.cardBackgroundColor
    cardView.layer.masksToBounds = true
    cardView.layer.cornerRadius = 6.0

    headerCardView.translatesAutoresizingMaskIntoConstraints = false
    headerCardView.backgroundColor = UIColor.clear

    headerLineView.translatesAutoresizingMaskIntoConstraints = false
    headerLineView.backgroundColor = configure.headerCardLineColor
    headerLineView.layer.masksToBounds = true
    headerLineView.layer.cornerRadius = 4.0

    addSubview(overlayView)
    addSubview(cardView)

    cardView.addSubview(body.view)
    cardView.addSubview(headerCardView)

    headerCardView.addSubview(headerLineView)

    parentController.view.addSubview(self)
  }

  private func setupConstraints() {
    guard let parentController = parentController else {
      return
    }

    let constraintCardHeight = cardView.heightAnchor.constraint(equalToConstant: parentViewHeight)
    let constraintCardButton = cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: parentViewHeight)

    let constraints: [NSLayoutConstraint] = [
      topAnchor.constraint(equalTo: parentController.view.topAnchor),
      leadingAnchor.constraint(equalTo: parentController.view.leadingAnchor),
      trailingAnchor.constraint(equalTo: parentController.view.trailingAnchor),
      bottomAnchor.constraint(equalTo: parentController.view.bottomAnchor),
      //
      overlayView.topAnchor.constraint(equalTo: topAnchor),
      overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
      overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
      overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
      //
      constraintCardHeight,
      cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
      cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
      constraintCardButton,
      //
      headerCardView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0),
      headerCardView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
      headerCardView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
      headerCardView.bottomAnchor.constraint(equalTo: body.view.topAnchor, constant: 0),
      //
      headerLineView.widthAnchor.constraint(equalToConstant: 60),
      headerLineView.heightAnchor.constraint(equalToConstant: 6),
      headerLineView.topAnchor.constraint(equalTo: headerCardView.topAnchor, constant: 7),
      headerLineView.centerXAnchor.constraint(equalTo: headerCardView.centerXAnchor, constant: 0),
      //
      body.view.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
      body.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
      body.view.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
      body.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
    ]

    self.constraintCardHeight = constraintCardHeight
    self.constraintCardButton = constraintCardButton

    NSLayoutConstraint.activate(constraints)
  }

  private func setupActions() {
    // Send notification if device rotated
    NotificationCenter.default.addObserver(
      self, selector: #selector(actionDeviceRotated),
      name: UIDevice.orientationDidChangeNotification, object: nil)

    // Change card height if swift on line
    let panChangeCardHeight = UIPanGestureRecognizer(target: self, action: #selector(actionTapForChangeStateCard(action:)))
    headerCardView.addGestureRecognizer(panChangeCardHeight)

    // Close card if tap to background
    if configure.isHideCardTapToBackground {
      let tapBackgroundView = UITapGestureRecognizer(target: self, action: #selector(actionSingleTapForHideCard))

      tapBackgroundView.numberOfTapsRequired = 1
      overlayView.addGestureRecognizer(tapBackgroundView)
    }
  }

  // MARK: - Public Methods

  public func show() {
    guard !isCardVisible else { return }

    isCardVisible = true
    updateCardVisibilityConstraint()
  }

  public func hide() {
    guard isCardVisible else { return }

    isCardVisible = false
    updateCardVisibilityConstraint()

    // Set initial state
    if let initialState = configure.availableStates.first, cardState != initialState {
      cardState = initialState
    }
  }

  // MARK: - Private methods

  /// Change constraints and params in card and animate them
  private func updateCardVisibilityConstraint() {
    guard
      let constraintCardButton = constraintCardButton,
      let constraintCardHeight = constraintCardHeight
      else { return }

    let overlayAlpha = isCardVisible ? configure.overlayAlpha : 0
    let constantCardButton = isCardVisible ? 0 : parentViewHeight

    let animateStart = { [unowned self] in
      self.notifyDelegate(type: .willChangeVisible)
      self.overlayView.alpha = overlayAlpha
      self.layoutIfNeeded()
    }

    let animateEnd: (Bool) -> Void = { _ in
      self.notifyDelegate(type: .didChangeVisible)
    }

    isUserInteractionEnabled = isCardVisible
    constraintCardHeight.constant = parentViewHeight * cardState.rawValue
    constraintCardButton.constant = constantCardButton

    UIView.animate(
      withDuration: configure.visibleAnimationDuration,
      delay: 0,
      options: .curveEaseInOut,
      animations: animateStart,
      completion: animateEnd)
  }

  /// Update card height constraint by state
  private func updateCardHeight(state: UIPopoverCardState) {
    guard
      isCardVisible,
      let constraintCardHeight = constraintCardHeight
      else { return }

    let animateStart = { [unowned self] in
      self.layoutIfNeeded()
    }

    let animateEnd: (Bool) -> Void = { [unowned self] _ in
      self.notifyDelegate(type: .didChangeState)
    }

    constraintCardHeight.constant = parentViewHeight * cardState.rawValue

    UIView.animate(
      withDuration: configure.changeStateAnimationDuration,
      delay: 0,
      options: .curveEaseInOut,
      animations: animateStart,
      completion: animateEnd)
  }

  /// Update card view height constraint
  private func updateCardHeight(height: CGFloat) {
    guard let constraintCardHeight = constraintCardHeight else {
      return
    }

    guard height <= maxCardHeight else {
      constraintCardHeight.constant = maxCardHeight
      return
    }

    guard height >= minCardHeight else {
      hide()
      return
    }

    constraintCardHeight.constant = height
  }

  /// Update card state by frame height
  private func updateStateByCardHeight() {
    let cardHeight = cardView.frame.height
    var distances: [UIPopoverCardState: CGFloat] = [:]

    for state in configure.availableStates {
      let stateHeight = parentViewHeight * state.rawValue
      var distance: CGFloat = 0

      if stateHeight > cardHeight {
        distance = stateHeight - cardHeight
      } else {
        distance = cardHeight - stateHeight
      }

      distances[state] = distance
    }

    let sortedDistances = distances.sorted { first, second in
      return first.value < second.value
    }

    if let firstState = sortedDistances.first?.key, cardState != firstState {
      cardState = firstState
    }
  }

  /// Send params to delegate by type
  private func notifyDelegate(type: UIPopoverCardDelegateType) {
    guard let delegate = delegate else {
      return
    }

    switch type {
    case .willChangeVisible:
      delegate.popoverCard(self, willChangeShow: isCardVisible)
    case .didChangeVisible:
      delegate.popoverCard(self, didChangeShow: isCardVisible)
    case .didChangeState:
      delegate.popoverCard(self, didChangeSize: cardState)
    }
  }
}

// MARK: - Actions

private extension UIPopoverCard {

  /// Event for device rotated
  @objc private func actionDeviceRotated() {
    if isCardVisible {
      updateCardHeight(state: cardState)
    }
  }

  /// Action for hide view by tap
  @objc private func actionSingleTapForHideCard() {
    hide()
  }

  /// Action for change state by swipe
  @objc private func actionTapForChangeStateCard(action: UIGestureRecognizer) {
    let tapLocation = action.location(in: self)
    let updatedCardHeight = self.frame.height - tapLocation.y

    switch action.state {
    case .changed:
      updateCardHeight(height: updatedCardHeight)
      updateStateByCardHeight()
    case .ended:
      updateCardHeight(state: cardState)
    default:
      break
    }
  }
}
