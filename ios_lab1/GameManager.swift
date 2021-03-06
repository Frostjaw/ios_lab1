//
//  Game.swift
//  ios_lab1
//
//  Created by Frostjaw on 16/03/2020.
//  Copyright © 2020 Разработчик. All rights reserved.
//

import Foundation

class GameManager {
    
    var curLevel: Int
    var curScore: Int
    var bestScore: Int
    
    init(curLevel: Int, curScore: Int, bestScore: Int) {
        self.curLevel = curLevel
        self.curScore = curScore
        self.bestScore = bestScore
    }
    
    func loadGameData(){
        let defaults = UserDefaults.standard
        // check for first launch
        let curLevel = defaults.integer(forKey: "curLevel")
        if (curLevel == 0){
            self.curLevel = 1
        }else{
            self.curLevel = curLevel
        }
        self.curScore = defaults.integer(forKey: "curScore")
        self.bestScore = defaults.integer(forKey: "bestScore")
    }
    
    func save(){
        UserDefaults.standard.set(curScore, forKey: "curScore")
        UserDefaults.standard.set(curLevel, forKey: "curLevel")
    }
    
    func saveBestScore(){
        let bestScore = UserDefaults.standard.integer(forKey: "bestScore")
        if (self.bestScore > bestScore){
            UserDefaults.standard.set(self.bestScore, forKey: "bestScore")
        }
    }
    
    func restartGame(){
        if (self.curScore > self.bestScore){
            self.bestScore = self.curScore
        }
        saveBestScore()
        self.curLevel = 1
        self.curScore = 0
        save()
    }
}
