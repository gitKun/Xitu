//
//  MJRefresh+Rx.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/1.
//  Copyright © 2020 kun. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


public enum RefreshStatus {
  case none, begainHeaderRefresh, endHeaderRefresh
  case hiddendFooter, showFooter, endFooterRefresh, endFooterRefreshWithNoData
}

public protocol Refreshable {
  var refreshStauts: BehaviorRelay<RefreshStatus> { get }
}

public extension Refreshable {
  func refreshStatusBind(to scrollView: UIScrollView) -> Disposable {
    return refreshStauts.subscribe(onNext: { [weak scrollV = scrollView] status in
      switch status {
      case .none:
        break
      case .begainHeaderRefresh:
        scrollV?.mj_header?.beginRefreshing()
      case .endHeaderRefresh:
        scrollV?.mj_header?.endRefreshing()
      case .hiddendFooter:
        scrollV?.mj_footer?.isHidden = true
      case .showFooter:
        scrollV?.mj_footer?.isHidden = false
      case .endFooterRefresh:
        scrollV?.mj_footer?.endRefreshing()
      case .endFooterRefreshWithNoData:
        scrollV?.mj_footer?.endRefreshingWithNoMoreData()
      }
    })
  }
}

private var kRxRefreshCommentKey: UInt8 = 0

public extension Reactive where Base: MJRefreshComponent {
  var refreshing: ControlEvent<Void> {
    let source: Observable<Void> = lazyInstanceObservable(&kRxRefreshCommentKey) { () -> Observable<()> in
      Observable.create { [weak control = self.base] observer in
        if let control = control {
          control.refreshingBlock = {
            observer.on(.next(()))
          }
        } else {
          observer.on(.completed)
        }
        return Disposables.create()
      }
      .takeUntil(self.deallocated)
      .share(replay: 1)
    }
    return ControlEvent(events: source)
  }
  
  private func lazyInstanceObservable<T: AnyObject>(_ key: UnsafeRawPointer, createCachedObservable: () -> T) -> T {
    if let value = objc_getAssociatedObject(self.base, key) as? T {
      return value
    }
    let observable = createCachedObservable()
    objc_setAssociatedObject(self.base, key, observable, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return observable
  }
}
