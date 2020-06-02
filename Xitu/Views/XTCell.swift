//
//  XTCell.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/2.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class XTCell: UITableViewCell {

  @IBOutlet weak var topSplitView: UIView!
  @IBOutlet weak var avatarImgView: UIImageView!
  @IBOutlet weak var userNameLabel: UILabel!
  @IBOutlet weak var userInfoLabel: UILabel!
  @IBOutlet weak var moreActionBtn: UIButton!
  @IBOutlet weak var flowButton: CornerBorderButton!
  @IBOutlet weak var contentLabel: UILabel!
  @IBOutlet weak var imageContainer: XTImageContentView!
  @IBOutlet weak var zanBtn: UIButton!
  @IBOutlet weak var commentBtn: UIButton!
  @IBOutlet weak var shanreBtn: UIButton!

  /** action属性 */
  private(set) lazy var hasBindStream: Bool = { false }()
  private lazy var disposeBag: DisposeBag = { DisposeBag() }()

  /** Model */
  private var currentModel: UserActivity?

  override func awakeFromNib() {
    super.awakeFromNib()
    flowButton.borderColor = .xtFlowBtn
    flowButton.cornerRaius = 4
    flowButton.borderWidth = 1
    flowButton.setTitleColor(.xtFlowBtn, for: .normal)
    selectionStyle = .none
  }
}

extension XTCell {
  func confirgueCell(model: UserActivity) {
    currentModel = model
    updateAvatar(url: model.avatarLarge)
    userNameLabel.text = model.username
    updateInfoLabel(job: model.jobTitle, company: model.company, time: model.createdAt)
    updateContentInfo(model)
    updateActivityImages(pics: model.pictures)
    updateBottomInfo(model)
  }
  /// 更新绑定状态
  func updaBindState() {
    hasBindStream = true
  }
  /// 绑定 imageViewContainer 的点击事件
  func bindImageTapStream(observer: Binder<ImageViewTapInfo>) {
    // 绑定流
    imageContainer.imageViewTapStream.drive(observer).disposed(by: disposeBag)
  }
}

private extension XTCell {
  func updateAvatar(url: String) {
    avatarImgView.image = UIImage(named: url)
  }
  func updateInfoLabel(job: String, company: String, time: String) {
    let userInfo: String = {
      var result = job
      result += (result.isEmpty || company.isEmpty) ? company : " @ " + company
      let time = (time as NSString).substring(with: NSRange(location: 5, length: 5))
      result +=  result.isEmpty ? time : " • " + time
      return result
    }()
    userInfoLabel.text = userInfo
  }
  func updateContentInfo(_ model: UserActivity) {
    // 沸点内容描述
    //contentLabel.numberOfLines = 0
    contentLabel.attributedText = model.attributesStringContent
  }
  func updateActivityImages(pics: [PictureItem]) {
    imageContainer.reloadImages(picItems: pics)
  }
  func updateBottomInfo(_ model: UserActivity) {
    zanBtn.setTitle(model.likeCount > 0 ? "\(model.likeCount)" : "赞", for: .normal)
    commentBtn.setTitle(model.commentCount > 0 ? "\(model.commentCount)" : "评论", for: .normal)
  }
}
