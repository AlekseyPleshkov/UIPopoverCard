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

    popoverCard.toggle()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let config = UIPopoverCardConfiguration()
    let body = UIPopoverCardBody(xibName: "Test")

    popoverCard = UIPopoverCard(self, configure: config, body: body)
  }
}

