//
//  UserActivityModel.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/2.
//  Copyright © 2020 kun. All rights reserved.
//

import Foundation

struct UserActivity: Decodable {
  /// 唯一标识符(掘金iOS使用的是Texture!)
  private var id: String
  private var action: String
  /// 取第一个
  private var pins: [Pin]

  private var firstPin: Pin {
    return pins.first!
  }
  private var attributeContent: NSAttributedString?

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DecodeKey.self)
    do {
      id = try container.decode(String.self, forKey: .id)
      action = try container.decode(String.self, forKey: .action)
      pins = try container.decode([Pin].self, forKey: .pins)
      let firstPin = pins[0]
      attributeContent = UserActivity.provideAttribute(content: firstPin.content)
    } catch {
      throw error
    }
  }
  enum DecodeKey: String, CodingKey {
    case id, action, pins, attributeContent
  }
}

// MARK: 外部能够调用的方法
extension UserActivity {
  static func modelsForm(data: Data) -> [UserActivity] {
    let decoder = JSONDecoder()
    do {
     return []
    } catch {
      fatalError("解析Model失败!error:\n\(error) ____#")
    }
    //return JueJinGraphqlRecommendOutputModel([]).activities
  }

  static private func provideAttribute(content: String) -> NSAttributedString {
    let arrtibutes = kJueJinProvideAttribute
    return NSAttributedString.init(string: content, attributes: arrtibutes)
  }
}

// MARK: 外部获取的属性
extension UserActivity {
  /// 用户所发沸点的ID
  var activityID: String {
    return id
  }
  /// 暂时无用
  var avtivityAction: String {
    return action
  }
  /// 标识符
  var pinID: String {
    return firstPin.id
  }
  /// 内容
  var content: String {
    return firstPin.content
  }
  /// 属性字符串
  var attributesStringContent: NSAttributedString {
    if attributeContent == nil {
      fatalError("缺失!!!!___!")
    }
    return attributeContent!
  }
  /// 图片
  var pictures: [PictureItem] {
    return firstPin.pictures
  }
  /// 点赞数
  var likeCount: Int {
    return firstPin.likeCount
  }
  /// 创建时间
  var createdAt: String {
    return firstPin.createdAt
  }
  /// 评论数
  var commentCount: Int {
    return firstPin.commentCount
  }
  /// 是否点赞
  var viewerHasLiked: Bool {
    return firstPin.viewerHasLiked
  }
  /// 是否标记为话题(eg:#树洞一下, #代码秀)
  var hasTopic: Bool {
    return firstPin.topic != nil
  }
  /// 话题的ID
  var topicID: String {
    guard hasTopic else { fatalError("没有被标记为话题") }
    return firstPin.topic!.id
  }
  /// 话题的ID
  var topicTitle: String {
    guard hasTopic else { fatalError("没有被标记为话题!") }
    return firstPin.topic!.title
  }
  /// 作者id
  var usreId: String {
    return firstPin.user.id
  }
  /// 作者姓名
  var username: String {
    return firstPin.user.username
  }
  /// 作者的自我描述
  var selfDescription: String {
    return firstPin.user.wrappedSelfDescription
  }
  /// 作者的头像链接
  var avatarLarge: String {
    return firstPin.user.avatarLarge
  }
  /// 作者的工作
  var jobTitle: String {
    return firstPin.user.wrappedJobTitle
  }
  /// 作者的公司
  var company: String {
    return firstPin.user.wrappedCompany
  }
  /// 是否正在关注作者
  var viewerIsFollowing: Bool {
    firstPin.user.viewerIsFollowing
  }
}

/// 掘金沸点使用的属性字符
public typealias JueJinProvideAttributes = [NSAttributedString.Key: Any]

/// 属性
public var kJueJinProvideAttribute: JueJinProvideAttributes {
  let paragraphStyle = NSMutableParagraphStyle()
  paragraphStyle.lineSpacing = 5 // 行间隔
  paragraphStyle.alignment = .justified // 两端对齐
  let font: UIFont = UIFont.init(name: "PingFangSC-Regular", size: 16) ?? .systemFont(ofSize: 16)
  let arrtibutes: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: UIColor.xtContent,
    .paragraphStyle: paragraphStyle
  ]
  return arrtibutes
}

private struct Topic: Decodable {
  var id: String
  var title: String
}

private struct User: Decodable {
  var id: String
  var username: String
  var selfDescription: String?
  var avatarLarge: String
  var jobTitle: String?
  var company: String?
  var viewerIsFollowing: Bool

  var wrappedCompany: String {
    return company ?? ""
  }
  var wrappedSelfDescription: String {
    return selfDescription ?? ""
  }
  var wrappedJobTitle: String {
    return jobTitle ?? ""
  }
}

private struct Pin: Decodable {
  /// 沸点id
  var id: String
  /// 内容
  var content: String
  /// 图片
  var pictures: [PictureItem]
  /// 点赞数
  var likeCount: Int
  /// 创建时间
  var createdAt: String
  /// 评论数
  var commentCount: Int
  /// 是否点赞
  var viewerHasLiked: Bool
  /// 话题
  var topic: Topic?
  /// 作者
  var user: User
}

struct PictureItem: Decodable {

  //var type: PicType
  var width: CGFloat
  var height: CGFloat
  /// 图片浏览界面使用原图
  var url: String
  /// 列表界面使用小图片
  var actUrl: String
  /// 本队存储的名称
  var loaclName: String

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: DecodeKey.self)
    do {
      width = try container.decode(CGFloat.self, forKey: .width)
      height = try container.decode(CGFloat.self, forKey: .height)
      loaclName = try container.decode(String.self, forKey: .loaclName)
      url = try container.decode(String.self, forKey: .loaclName)
      actUrl = try container.decode(String.self, forKey: .loaclName)
      actUrl = "act_" + actUrl
    } catch {
      throw error
    }
  }
  enum DecodeKey: String, CodingKey {
    case width, height, loaclName, url, actUrl
  }
}
