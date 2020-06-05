//
//  TestCell.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/5.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

class TestCell: UITableViewCell {

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  private var hasRegist = false
  private var action: ((TestCell) -> Void)?
  func registButtonAction(action: @escaping (TestCell) -> Void) {
    guard !hasRegist else { return }
    self.action = action
  }
  @IBAction func clicked(_ sender: Any) {
    if let action = action {
      action(self)
    }
  }
}
