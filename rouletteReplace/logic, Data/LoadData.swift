//
//  Load.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/23.
//

import Foundation
import RealmSwift

struct LoadData {
    static let shared = LoadData()
    private var realm = try! Realm()
    private var resultsData: Results<RouletteData>?
    
    init() {
        resultsData = realm.objects(RouletteData.self)
    }
    var dataCount: Int { resultsData?.count ?? 0 }
    func sortData() -> Results<RouletteData>? {
        resultsData?.sorted(byKeyPath: "date", ascending: false)
    }
    func deleteData(indexPath: IndexPath) {
        guard let resultsData = resultsData else { return }
        try! realm.write {
            realm.delete(resultsData[indexPath.row])
        }
    }
    func lastSetData() -> RouletteData? {
        let sortData = resultsData?.sorted(byKeyPath: "lastDate", ascending: true)
        return sortData?.last
    }
}
