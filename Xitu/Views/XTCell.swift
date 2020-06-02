//
//  XTCell.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/2.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

class XTCell: UITableViewCell {

  @IBOutlet weak var topSplitView: UIView!
  @IBOutlet weak var avatarImgView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userInfoLabel: UILabel!
  @IBOutlet weak var moreActionBtn: UIButton!
  @IBOutlet weak var flowButton: CornerBorderButton!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var activityImage1: UIImageView!
  @IBOutlet weak var activityImage2: UIImageView!
  @IBOutlet weak var activityImage3: UIImageView!
  @IBOutlet weak var zanBtn: UIButton!
  @IBOutlet weak var commentBtn: UIButton!
  @IBOutlet weak var shanreBtn: UIButton!
  override func awakeFromNib() {
    super.awakeFromNib()
    selectionStyle = .none
  }
}
