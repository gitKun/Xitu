//
//  XTRecommendViemModel.swift
//  AppWithRxSwift
//
//  Created by DR_Kun on 2020/5/29.
//  Copyright © 2020 kun. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import RxDataSources

/**
 *
 * Inputs 只提供方法
 * Outputs 提供 Observable
 *
 */

protocol XTRecommendViemModelInputs {

  /// 加载数据
  /// - Parameter isRefreshing: 是否为刷新,**true**就加入到头部,**false**加入尾部
  func loadData(_ isRefreshing: Bool)
  /// 界面已经加载
  func viewDidload()
}

protocol XTRecommendViemModelOutPuts {
  /// 数据源数组
  var dataSource: Driver<[SectionModel<String, UserActivity>]> { get }
}

protocol XTRecommendViemModelType {
  var inputs: XTRecommendViemModelInputs { get }
  var outputs: XTRecommendViemModelOutPuts { get }
}

class XTRecommendViemModel: XTRecommendViemModelType, XTRecommendViemModelInputs, XTRecommendViemModelOutPuts {

  let refreshStauts = BehaviorRelay<RefreshStatus>(value: .none)
  // 协议
  var inputs: XTRecommendViemModelInputs { return self }
  var outputs: XTRecommendViemModelOutPuts { return self }
  // inputs
  func loadData(_ isRefreshing: Bool) {
    // 结束上次的刷新状态
    refreshStauts.accept(isRefreshing ? .endFooterRefresh : .endHeaderRefresh)
    loadDataProperty.onNext(isRefreshing)
  }
  func viewDidload() {
    refreshStauts.accept(.hiddendFooter)
    refreshStauts.accept(.begainHeaderRefresh)
  }
  // outputs
  var dataSource: Driver<[SectionModel<String, UserActivity>]> {
    let loadNewCommand = loadDataProperty
      .filter { $0 }
      .asDriver { _ -> Driver<Bool> in
        return Driver.just(true)
      }
      .flatMap { [weak self] _ -> Driver<[UserActivity]> in
        guard let `self` = self else { return Driver<[UserActivity]>.just([]) }
        return self.queryNewData()
      }
      .flatMap { [weak self] items -> Driver<XTRecommendViemModel.EditeDataCommand> in
        self?.refreshStauts.accept(.endHeaderRefresh)
        self?.refreshStauts.accept(.showFooter)
        return Driver.just(EditeDataCommand.loadNewData(items: items))
      }
    let loadMoreCommand = loadDataProperty
      .filter { !$0 }
      .asDriver { _ in Driver.just(true) }
      .flatMap { [weak self] _ -> Driver<[UserActivity]> in
        guard let `self` = self else { return Driver<[UserActivity]>.just([]) }
        return self.queryNextPageData()
      }
      .flatMap { [weak self] items -> Driver<XTRecommendViemModel.EditeDataCommand> in
        // 判断 items 和 noNext 字段
        // 选择 hiddendFooter, endFooterRefresh, endFooterRefreshWithNoData
        self?.refreshStauts.accept(.endFooterRefresh)
        return Driver.just(EditeDataCommand.loadOldData(items: items))
      }
    let initialWrappedModel = RecommendWrappedModel()
    let dataSource = Driver.of(loadNewCommand, loadMoreCommand)
      .merge()
      .scan(initialWrappedModel) { (resultWrapped: RecommendWrappedModel, command: EditeDataCommand) -> RecommendWrappedModel in
        return resultWrapped.execute(command: command)
      }
      .map { wrappedModel -> [SectionModel<String, UserActivity>] in
        return [SectionModel(model: "XTRemSectionModel", items: wrappedModel.items)]
      }
    return dataSource
  }

  // private
  private let loadDataProperty: PublishSubject<Bool> = PublishSubject()
  // 网络请求
  //private lazy var recommendProvider = { MoyaProvider<JueJinGraphqlAPI>() }()
}

extension XTRecommendViemModel: Refreshable {}

extension XTRecommendViemModel {
  struct Input {
    /// 加载新数据
    let loadNewAction: Driver<Void>
    /// 加载过去的数据
    let loadOldAction: Driver<Void>
  }

  struct Output {
    let dataSource: Driver<[SectionModel<String, UserActivity>]>
    let endRefreshing: Driver<RefreshStatus>
  }
}

// MARK: 真实网路请求
private extension XTRecommendViemModel {
  func queryNewData() -> Driver<[UserActivity]> {
    /*let result = recommendProvider.rx.request(.recommendNew)
      .filterSuccessfulStatusCodes()
      .map { [weak self] resposen -> [UserActivity] in
        let wrappedResult = UserActivity.modelsForm(data: resposen.data)
        // 更新key
        self?.xxx = wrappedResult.xxx
        return wrappedResult.items
      }
      .asDriver(onErrorRecover: { _ in
        return Driver<[UserActivity]>.empty()
      })*/
    let items = readerLoadData()
    let result = Driver<[UserActivity]>.just(items).delay(.milliseconds(1500))
    return result
  }
  func queryNextPageData() -> Driver<[UserActivity]> {
    let items = readerLoadData()
    let result = Driver<[UserActivity]>.just(items).delay(.milliseconds(1500))
    return result
  }
}

// MARK: 生成指定形式的数据
private extension XTRecommendViemModel {
  // 加载本地数据
  func readerLoadData() -> [UserActivity] {
    let model = UserActivity.modelFromLocal()
    let result = model.shuffled().suffix(10)
    return Array(result)
  }
}

// MARK: 定义数据的转换方式
private extension XTRecommendViemModel {
  enum EditeDataCommand {
    /// instert 到头部
    case loadNewData(items: [UserActivity])
    /// append 到尾部
    case loadOldData(items: [UserActivity])
  }

  /// 内部数据存储的数据结构
  struct RecommendWrappedModel {
    fileprivate var items: [UserActivity]
    init(items: [UserActivity] = []) {
      self.items = items
    }
    /// 核心
    func execute(command: EditeDataCommand) -> RecommendWrappedModel {
      switch command {
      case let .loadNewData(insertItems):
        //var tmpArray = self.items
        //tmpArray.insert(contentsOf: insertItems, at: 0)
        return RecommendWrappedModel(items: insertItems)
      case let .loadOldData(appedItems):
        var tmpArray = self.items
        tmpArray.append(contentsOf: appedItems)
        return RecommendWrappedModel(items: tmpArray)
      }
    }
  }
// The end
}
