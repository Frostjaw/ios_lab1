//
//  Game.swift
//  ios_lab1
//
//  Created by Frostjaw on 16/03/2020.
//  Copyright © 2020 Разработчик. All rights reserved.
//

import Foundation

class Game {
    
    var curLevel: Int
    var curScore: Int
    var bestScore: Int
    
    init(curLevel: Int, curScore: Int, bestScore: Int) {
        self.curLevel = curLevel
        self.curScore = curScore
        self.bestScore = bestScore
    }
    
    func save(){
        UserDefaults.standard.set(curScore, forKey: "score")
        UserDefaults.standard.set(curLevel, forKey: "level")
    }
}
