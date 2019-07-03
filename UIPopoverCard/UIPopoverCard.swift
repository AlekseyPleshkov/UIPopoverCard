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

public protocol UIPopoverCardDelegate: class {
  /// Will change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, willChangeShow isVisible: Bool)

  /// Did change visibility state of popover card
  func popoverCard(_ popoverCard: UIPopoverCard, didChangeShow isVisible: Bool)

  /// Did change state of size card
  func popoverCard(_ popoverCard: UIPopoverCard, didChangeSize state: UIPopoverCardState)
}

public final class UIPopoverCard: UIView {

  // MARK: - Public Properties

  public let overlayView: UIView
  public let cardView: UIView
  public let headerCardView: UIView
  public let headerLineView: UIView

  /// Delegate for notify about change state
  public weak var delegate: UIPopoverCardDelegate?

  /// Constraint for card height
  public private(set) var constraintCardHeight: NSLayoutConstraint?

  /// Constraint for card bottom
  public private(set) var constraintCardBottom: NSLayoutConstraint?

  /// Visibility of card
  public private(set) var isCardVisible: Bool = false

  /// State of show card
  public private(set) var cardState: UIPopoverCardState

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

  /// Get height for card by state or adaptive
  private var cardViewHeight: CGFloat {
    if configure.isAdaptiveByContent {
      return maxCardHeight
    }

    return parentViewHeight * cardState.rawValue
  }

  /// Min size of card for resizing
  private var minCardHeight: CGFloat = 0

  /// Max size of card for resizing
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

  // MARK: - Lifecycle

  public override func layoutSubviews() {
    super.layoutSubviews()

    if configure.isAdaptiveByContent {
      setupSizesByAdaptive()
    } else {
      setupSizesByState()
    }
  }

  // MARK: - Setups

  /// Default setup views, constraints and notifications
  private func setup() {
    setupViews()
    setupConstraints()
    setupActions()
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

    if #available(iOS 11.0, *) {
      cardView.layer.cornerRadius = 6.0
      cardView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    } else {
      cardView.layer.cornerRadius = 0
    }

    headerCardView.translatesAutoresizingMaskIntoConstraints = false
    headerCardView.backgroundColor = UIColor.clear
    headerCardView.isHidden = configure.isAdaptiveByContent

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
    let constraintCardBottom = cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: parentViewHeight)
    let bodyTopAnchorConstant: CGFloat = configure.isAdaptiveByContent ? 0 : 20

    let mainConstraints: [NSLayoutConstraint] = [
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
      constraintCardBottom,
      //
      body.view.topAnchor.constraint(equalTo: cardView.topAnchor, constant: bodyTopAnchorConstant),
      body.view.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
      body.view.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
      body.view.bottomAnchor.constraint(equalTo: cardView.bottomAnchor)
    ]

    /// Setting constraints for header line if not active adaptive mode
    if !configure.isAdaptiveByContent {
      let cardHeaderConstraints: [NSLayoutConstraint] = [
        headerCardView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 0),
        headerCardView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
        headerCardView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
        headerCardView.bottomAnchor.constraint(equalTo: body.view.topAnchor, constant: 0),
        //
        headerLineView.widthAnchor.constraint(equalToConstant: 60),
        headerLineView.heightAnchor.constraint(equalToConstant: 6),
        headerLineView.topAnchor.constraint(equalTo: headerCardView.topAnchor, constant: 7),
        headerLineView.centerXAnchor.constraint(equalTo: headerCardView.centerXAnchor, constant: 0)
      ]

      NSLayoutConstraint.activate(cardHeaderConstraints)
    }

    /// Change height priority for adaptive mode
    if configure.isAdaptiveByContent {
      constraintCardHeight.priority = .defaultLow
    }

    self.constraintCardHeight = constraintCardHeight
    self.constraintCardBottom = constraintCardBottom

    NSLayoutConstraint.activate(mainConstraints)
  }

  private func setupActions() {
    // Send notification if device rotated
    NotificationCenter.default.addObserver(
      self, selector: #selector(actionDeviceRotated),
      name: UIDevice.orientationDidChangeNotification, object: nil)

    /// Hide card by swipe down at content
    if configure.isAdaptiveByContent {
      let swipeDownCardHide = UISwipeGestureRecognizer(
        target: self,
        action: #selector(actionSingleTapForHideCard))

      swipeDownCardHide.direction = .down
      cardView.addGestureRecognizer(swipeDownCardHide)
    }

    /// Resize card height by swipe on card header
    if !configure.isAdaptiveByContent {
      let panChangeCardHeight = UIPanGestureRecognizer(
        target: self,
        action: #selector(actionTapForChangeStateCard(action:)))

      headerCardView.addGestureRecognizer(panChangeCardHeight)
    }

    // Close card if tap to background
    if configure.isHideCardTapToBackground {
      let tapBackgroundView = UITapGestureRecognizer(target: self, action: #selector(actionSingleTapForHideCard))

      tapBackgroundView.numberOfTapsRequired = 1
      overlayView.addGestureRecognizer(tapBackgroundView)
    }
  }

  private func setupSizesByState() {
    if let firstState = configure.availableStates.first {
      minCardHeight = parentViewHeight / 2 * firstState.rawValue
    }

    if let lastState = configure.availableStates.last {
      maxCardHeight = parentViewHeight * lastState.rawValue
    }
  }

  private func setupSizesByAdaptive() {
    guard let bodyContainer = body.containerView else {
      return
    }
    let bodyContainerHeight = bodyContainer.bounds.height

    minCardHeight = bodyContainerHeight / 2
    maxCardHeight = bodyContainerHeight
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
      let constraintCardButton = constraintCardBottom,
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
    constraintCardHeight.constant = cardViewHeight
    constraintCardButton.constant = constantCardButton

    UIView.animate(
      withDuration: configure.visibleAnimationDuration,
      delay: 0,
      options: .curveEaseInOut,
      animations: animateStart,
      completion: animateEnd)
  }

  /// Update card height constraint by state if resize
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

    constraintCardHeight.constant = cardViewHeight

    UIView.animate(
      withDuration: configure.changeStateAnimationDuration,
      delay: 0,
      usingSpringWithDamping: 0.6,
      initialSpringVelocity: 1,
      options: [],
      animations: animateStart,
      completion: animateEnd)
  }

  /// Update height constraint for card if resize
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

  /// Update card state by card height
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
