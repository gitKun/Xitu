//
//  TestRoloadViewController.swift
//  Xitu
//
//  Created by DR_Kun on 2020/6/5.
//  Copyright © 2020 kun. All rights reserved.
//

import UIKit

class TestModel {
  var height: CGFloat = 44
}

class TestRoloadViewController: UIViewController {

  let dataSource: [TestModel] = (0...99).map {_ in TestModel()}

  @IBOutlet weak var tableView: UITableView!
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.estimatedRowHeight = 0
  }
}

extension TestRoloadViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CellID", for: indexPath)
    if let cCell = cell as? TestCell {
      cCell.registButtonAction { [weak self] selectedCell in
        guard let `self` = self else { return }
        let indexP = self.tableView.indexPath(for: selectedCell)
        guard let idxPath = indexP else { return }
        let model = self.dataSource[idxPath.row]
        model.height = model.height < 100 ? 100 : 44
        self.tableView.reloadRows(at: [idxPath], with: .none)
      }
    }
    return cell
  }
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return dataSource.count
  }
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
}

extension TestRoloadViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return dataSource[indexPath.row].height
  }
}
