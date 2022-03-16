//
//  DataModel.swift
//  rouletteReplace
//
//  Created by USER on 2022/03/16.
//

import Foundation

struct DataModel {
    let title: String
    let dataId: String
    let colorIndex: Int
    let randomFlag: Bool
    let date: Date
    let lastDate: Date
    let index: Int
    let list: [ListModel]
    
    init(in: RouletteData) {
        title = in.title
        dataId = in.dataId
        colorIndex = in.colorIndex
        randomFlag = in.randomFlag
        date = in.date
        lastDate = in.lastDate
        index = in.index
        list = in.list
    }
}
struct ListModel {
    let text: String
    let r: Int
    let g: Int
    let b: Int
    let ratio: Float
    
    init(text: String,
        r: Int,
        g: Int,
        b: Int,
        ratio: Float
        ){
        self.text = text
        self.r = r
        self.g = g
        self.b = b
        self.ratio = ratio
    }
}
struct Temporary {
    let textTemporary: String
    let rgbTemporary: [String: Int]
    let ratioTemporary: Float
    
    init(in: ) {
        textTemporary = dir["textTemporary"]as
        rgbTemporary = dir["rgbTemporary"]as
        ratioTemporary = dir["ratioTemporary"]as
    }
}
