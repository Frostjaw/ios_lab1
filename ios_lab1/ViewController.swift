//
//  ViewController.swift
//  ios_lab1
//
//  Created by Разработчик on 13/03/2020.
//  Copyright © 2020 Разработчик. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var leftControlButton: UIButton!
    @IBOutlet weak var rightControlButton: UIButton!
    @IBOutlet weak var curScoreTextField: UITextField!
    @IBOutlet weak var curLevelTextField: UITextField!
    
    // global
    let screenRefreshRate: Double = 1/60
    var timer: Timer?
    var game = Game(curLevel: 0, curScore: 0, bestScore: 0)
    
    // enemies
    var enemiesImageViews: [[UIImageView]] = [[UIImageView]]()
    var enemiesBulletImageViews = [UIImageView]()
    var aliveEnemies: Int = 0
    var enemiesAttackCoolDown: Int = 0
    var enemiesFireRate: Int = 0
    var enemiesXOffset: CGFloat = 1
    var enemiesYOffset: CGFloat = 0
    
    // player
    var playerBulletsImageViews = [UIImageView]()
    var playerMovementSpeed: CGFloat = 5
    var playerAttackCoolDown: Int = 0
    var playerFireRate: Int = 0
    var playerXOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: screenRefreshRate, target: self, selector: #selector(drawObjects), userInfo: nil, repeats: true)
    }
    
    @objc func drawObjects(){
        drawPlayer()
        drawEnemies()
    }
    
    @IBAction func leftButtonTouchDown(_ sender: Any) {
        playerXOffset = -1 * playerMovementSpeed
    }
    
    @IBAction func leftButtonTouchUp(_ sender: Any) {
        playerXOffset = 0
    }
    
    @IBAction func rightButtonTouchDown(_ sender: Any) {
        playerXOffset = 1 * playerMovementSpeed
    }
    
    @IBAction func rightButtonTouchUp(_ sender: Any) {
        playerXOffset = 0
    }
    
    func startGame() {
        loadGame()
        loadPlayer()
        loadEnemies()
    }
    
    func loadPlayer(){
        // position
        playerImageView.frame = CGRect(x: view.frame.width * 0.45 , y: view.frame.height - 100, width: 50 , height:  50)
        
        // player settings
        playerAttackCoolDown = Int(screenRefreshRate * 60.0 / 2.0)
        playerFireRate = 30
    }
    
    func loadGame() {
        // get data from user defaults and create Game instance
        let defaults = UserDefaults.standard
        let bestScore = defaults.integer(forKey: "bestScore")
        let score = defaults.integer(forKey: "score")
        let level = defaults.integer(forKey: "level")
        game = Game(curLevel: level, curScore: score, bestScore: bestScore)
    }
    
    func loadEnemies() {
        for i in 0...2 {
            var enemiesRow = [UIImageView]()
            for j in 0...5{
                let enemy = UIImageView(image: #imageLiteral(resourceName: "enemy"))
                let enemyCGRect = CGRect(x: view.frame.width * (1/6) + CGFloat(j*50), y: view.frame.width * (1/7) + CGFloat(i*50) + CGFloat(50), width: view.frame.width * (1/10), height: view.frame.width * (1/10))
                enemy.frame = enemyCGRect
                enemiesRow.append(enemy)
                view.addSubview(enemy)
            }
            enemiesImageViews.append(enemiesRow)
        }
        
        enemiesAttackCoolDown = 50
        aliveEnemies = enemiesImageViews[0].count * enemiesImageViews.count
    }
    
    func drawPlayer(){
        // movement
        if ((playerImageView.frame.origin.x + playerXOffset > 8) && (playerImageView.frame.origin.x + playerXOffset + playerImageView.frame.width < view.frame.width - 8)){
            playerImageView.frame.origin.x += playerXOffset
        }
        
        // attack
        playerAttack()
        playerAttackCoolDown += 1
    }
    
    func drawEnemies() {
        
        // here should be logic for enemy(game) levels if their ms and fire rate will increase
        
        enemyAttack()
        
        // enemies movements (!!!hardcoded indexes)
        
        // x axis
        for i in 0...2 {
            for j in 0...5 {
                enemiesImageViews[i][j].frame.origin.x += enemiesXOffset
            }
        }
        
        // checks
        if (enemiesImageViews[0][5].frame.origin.x + enemiesImageViews[0][5].frame.width >= view.frame.width - 8) {
            enemiesXOffset = -1
            enemiesYOffset += view.frame.height * (1/300)
        }else if (enemiesImageViews[0][0].frame.origin.x  <= 8) {
            enemiesXOffset = 1
            enemiesYOffset += view.frame.height * (1/300)
        }
        
        // y axis
        for i in 0...2 {
            for j in 0...5 {
                enemiesImageViews[i][j].frame.origin.y += enemiesYOffset
                //enemiesImageViews[i][j].transform = CGAffineTransform(scaleX: enemiesXOffset, y: 1)
            }
        }
        
        enemiesYOffset = 0
    }
    
    func enemyAttack(){
//        enemiesAttackCoolDown += 1
//
//        if enemiesAttackCoolDown >= 60 {
//            let randx = Int.random(in: 0...4)
//            let randy = Int.random(in: 0...2)
//            let selectedEnemy = enemies[randx][randy]
//            if selectedEnemy.isHidden==false {
//                let myView = CGRect(x: selectedEnemy.frame.origin.x + selectedEnemy.frame.width * 0.45, y: selectedEnemy.frame.origin.y + selectedEnemy.frame.height * 0.3, width: selectedEnemy.frame.width * 0.5, height: selectedEnemy.frame.height * 0.5)
//                let newEnemyBullet = UIImageView(frame: myView)
//                newEnemyBullet.image = #imageLiteral(resourceName: "220-2205494_space-invaders-ship-clipart")
//                view.addSubview(newEnemyBullet)
//                enemyBullets.append(newEnemyBullet)
//                enemiesAttackCoolDown = 0
//            }
//        }
//
//        for (number, item) in enemyBullets.enumerated() {
//            item.frame.origin.y += 5
//            if item.frame.origin.y > item.frame.height + view.frame.height {
//                enemyBullets[number].removeFromSuperview()
//                enemyBullets.remove(at: number)
//            }
//        }
        
    }
    
    func playerAttack() {
        if playerAttackCoolDown > playerFireRate {
            let myView = CGRect(x: playerImageView.frame.origin.x + playerImageView.frame.width * 0.45, y: playerImageView.frame.origin.y - playerImageView.frame.height * 0.3, width: playerImageView.frame.width * 0.1, height: playerImageView.frame.height * 0.5)
            let newPlayerBullet = UIImageView(frame: myView)
            newPlayerBullet.image = #imageLiteral(resourceName: "playerBullet")
            view.addSubview(newPlayerBullet)
            playerBulletsImageViews.append(newPlayerBullet)
            playerAttackCoolDown = 0
        }
        
        checkForIntersect()
    }
    
    func checkForIntersect(){
        let bottomEnemyRowPosition = enemiesImageViews[2][0].frame.origin.y + enemiesImageViews[2][0].frame.height
        
        outer: for (index, item) in playerBulletsImageViews.enumerated(){
            item.frame.origin.y -= 10
            if item.frame.origin.y < -100 {
                playerBulletsImageViews[index].removeFromSuperview()
                playerBulletsImageViews.remove(at: index)
            } else if (item.frame.origin.y <= bottomEnemyRowPosition){
                inner : for i in 0...2 {
                    for j in 0...5 {
                        if (item.frame.intersects(enemiesImageViews[i][j].frame) && enemiesImageViews[i][j].isHidden == false) {
                            playerBulletsImageViews[index].removeFromSuperview()
                            playerBulletsImageViews.remove(at: index)                            
                            enemiesImageViews[i][j].isHidden = true
                            game.curScore += game.curLevel
                            curScoreTextField.text = String(game.curScore)
                            aliveEnemies -= 1
                            
                            if aliveEnemies == 0 {
//                                timer?.invalidate()
//                                game.curLevel += 1
//                                game.save()
//                                restart()
                                break outer
                            }
                            break inner
                        }
                    }
                }
            }
        }
    }
    
//    func restart() {
//        player.resurrect()
//        enemyAttackCD = Double(50*pow(0.8, Double(player.level)))
//        hp.text = String(player.health)
//        score.text = String(player.score)
//        level.text = String(player.level)
//
//        for i in 0...4 {
//            for j in 0...2 {
//                enemies[i][j].frame.origin.x = view.frame.width * CGFloat((i+1)*2-1) * (1/11)
//                enemies[i][j].frame.origin.y = view.frame.width * (1.5/11) * CGFloat(j+1)
//                enemies[i][j].isHidden = false
//            }
//        }
//        aliveEnemies = 15
//
//        t = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
//    }
    
}

