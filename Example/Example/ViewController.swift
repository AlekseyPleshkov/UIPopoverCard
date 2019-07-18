//
//  ViewController.swift
//  Example
//
//  Created by Aleksey Pleshkov on 17/02/2019.
//  Copyright © 2019 Aleksey Pleshkov. All rights reserved.
//

import UIKit
import UIPopoverCard

class ViewController: UIViewController {

  private var popoverCard: UIPopoverCard?

  @IBAction func buttonPopover(_ sender: Any) {
    guard let popoverCard = popoverCard else { return }

    popoverCard.show()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    var config = UIPopoverCardConfiguration()
//    config.isAdaptiveByContent = true
//    config.isShowBackground = false
//    config.isShowHeader = false
//    config.isChangeSizeBySwipe = false

    let body = UIPopoverCardBody(xibName: "Test")

    popoverCard = UIPopoverCard(self, configure: config, body: body)
    popoverCard?.delegate = self

    DispatchQueue.global().async {
      sleep(4)

      DispatchQueue.main.async {
        let body2 = UIPopoverCardBody(xibName: "Test2")

        self.popoverCard?.updateBody(updatedBody: body2)
      }
    }
  }
}

extension ViewController: UIPopoverCardDelegate {
  func popoverCard(_ popoverCard: UIPopoverCard, willChangeShow isVisible: Bool) {
    print("Will change visible \(isVisible)")
  }

  func popoverCard(_ popoverCard: UIPopoverCard, didChangeShow isVisible: Bool) {
    print("Did change visible \(isVisible)")
  }

  func popoverCard(_ popoverCard: UIPopoverCard, didChangeSize state: UIPopoverCardState) {
    print("Did change state \(state)")
  }
}
