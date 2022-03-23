//
//  Load.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/23.
//

import Foundation
import RealmSwift

struct LoadData {
    private var realm = try! Realm()
    var resultsData: Results<RouletteData>!
    
    init() {
        resultsData = realm.objects(RouletteData.self)
    }
    func sortData(key: String) -> Results<RouletteData> {
        resultsData.sorted(byKeyPath: key, ascending: false)
    }
    func deleteData(indexPath: IndexPath) {
        try! realm.write{
            realm.delete(resultsData[indexPath.row])
        }
    }
}
