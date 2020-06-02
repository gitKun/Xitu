//
//  ViewController.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources
import JXPhotoBrowser

class ViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  let disposeBag = DisposeBag()
  let viewModel = XTRecommendViemModel()
  override func viewDidLoad() {
    super.viewDidLoad()
    initialUI()
    bindViewModel()
    viewModel.viewDidload()
  }

  deinit {
    print("\(Self.self) \(#function) ____#")
    var view = self.view
    self.view = nil
    DispatchQueue.global(qos: .background).async {
      #if DEBUG
      print("放到后台线程释放: \(view?.description ?? "⚠️已经释放!")")
      #endif
      view = nil
    }
  }
}

// MARK: initial UI
extension ViewController {

  private func initialUI() {
    view.backgroundColor = .white
    title = "数据请求"
    initialTableView()
  }

  private func initialTableView() {
    // 预估行高 会造成 cell 的重复创建和销毁 例如 本来应该创建 6个,
    // 预估行高会创建 7 到 8 个然后在你下划或者上划到头后就开始销毁多余的, 再次滑动又会创建新的
    // 测试机为 6, iOS12.4 和  XR iOS13.5
    tableView.rowHeight = UITableView.automaticDimension
    tableView.estimatedRowHeight = 260
  }
}

// MARK: iniatal rx
extension ViewController {

  func bindViewModel() {
    // 配置下拉刷新
    let tableHeader = MJRefreshNormalHeader()
    tableHeader.isAutomaticallyChangeAlpha = true
    tableHeader.lastUpdatedTimeLabel?.isHidden = true
    tableView.mj_header = tableHeader
    tableView.mj_footer = MJRefreshBackNormalFooter()
    // 绑定数据
    tableHeader.rx.refreshing
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.loadData(true)
      })
      .disposed(by: disposeBag)
    tableView.mj_footer?.rx.refreshing
      .asDriver()
      .drive(onNext: { [weak self] _ in
        self?.viewModel.loadData(false)
      })
      .disposed(by: disposeBag)
    // 刷新状态管理
    viewModel.inputs.refreshStatusBind(to: self.tableView).disposed(by: disposeBag)
    let dataSource = self.tableViewCellDataSourc
    // 获取数据
    self.viewModel.outputs.dataSource
      .drive(tableView.rx.items(dataSource: dataSource))
      .disposed(by: disposeBag)

    //tableView.rx.setDelegate(dataSource).disposed(by: disposeBag)
    // WARINING: 这里是为了使数据源仅保存一份
    //tableView.rx.setDataSource(dataSource).disposed(by: disposeBag)
  }
}

/// 配置 tableViewCell 的数据源
extension ViewController {
  var tableViewCellDataSourc: RxTableViewSectionedReloadDataSource<SectionModel<String, UserActivity>> {
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, UserActivity>>(
    configureCell: { [weak self] (_, tabView, indexPath, model) -> UITableViewCell in
      let sCell = tabView.dequeueReusableCell(withIdentifier: "XTCell", for: indexPath)
      guard let cell = sCell as? XTCell else { return sCell}
      cell.confirgueCell(model: model)
      if !cell.hasBindStream {
        guard let self = self else { return cell }
        cell.updaBindState()
        let imageTapObserver: Binder<ImageViewTapInfo> = Binder(self, scheduler: MainScheduler.instance) { viewController, info in
          viewController.showPhotoBrowser(info: info)
        }
        cell.bindImageTapStream(observer: imageTapObserver)
      }
      return cell
    })
    return dataSource
  }
}

// MARK: 显示相册
private extension ViewController {
  func showPhotoBrowser(info: ImageViewTapInfo) {
    guard let items = info.models, !items.isEmpty else {
      //self.toast.showCenter(message: "无效操作!")
      print("无效操作!")
      return
    }
    let orgImageUrlArray = items.compactMap {  $0.url }
    let selectIndex = info.selsctIndex ?? 0
    self.showXTPhotoBrowser(from: info.sourceView, imagesUrl: orgImageUrlArray, selsctIndex: selectIndex)
  }

  func showXTPhotoBrowser(from sourceView: UIImageView, imagesUrl: [String], selsctIndex: Int) {
    guard !imagesUrl.isEmpty else { return }
    let orgImageUrlArray = imagesUrl
    let imageView = sourceView
    let browser = JXPhotoBrowser()
    browser.numberOfItems = {
      orgImageUrlArray.count
    }
    browser.reloadCellAtIndex = { context in
      let name = orgImageUrlArray[context.index]
      let browserCell = context.cell as? JXPhotoBrowserImageCell
      browserCell?.imageView.image = UIImage(named: name)
    }
    // Zoom动画
    browser.transitionAnimator = JXPhotoBrowserSmoothZoomAnimator(transitionViewAndFrame: { (index, destinationView) -> JXPhotoBrowserSmoothZoomAnimator.TransitionViewAndFrame? in
      guard let imageViewArray = imageView.superview?.subviews,
        index < imageViewArray.count,
        let imgView = imageViewArray[index] as? UIImageView else {
          return nil
      }
      let image = imgView.image
      let transitionView = UIImageView(image: image)
      transitionView.contentMode = imageView.contentMode
      transitionView.clipsToBounds = true
      let thumbnailFrame = imgView.convert(imgView.bounds, to: destinationView)
      return (transitionView, thumbnailFrame)
    })
    browser.pageIndex = selsctIndex
    browser.show()
  }
}

/*
// MARK: 测试网络请求
extension ViewController {
  private func tesQueryNetworkeData() -> Observable<[SectionModel<String, UserActivity>]> {
    let recommendProvider = MoyaProvider<JueJinGraphqlAPI>()
    let result = recommendProvider.rx.request(.recommendNew)
      .filterSuccessfulStatusCodes()
      .flatMap { resData -> Single<[SectionModel<String, UserActivity>]> in
        let wrappedArray = UserActivity.modelsForm(data: resData.data)
        let sectionModel: SectionModel<String, UserActivity> = SectionModel(model: "name", items: wrappedArray.items)
        return Single<[SectionModel<String, UserActivity>]>.just([sectionModel])
      }
      .asObservable()
      .catchError { error in
        print("转换网络请求失败: error = \n\(error)")
        return Observable<[SectionModel<String, UserActivity>]>.empty()
      }
    return result
  }
}
*/
