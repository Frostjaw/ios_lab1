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
    @IBOutlet weak var bestScoreTextField: UITextField!
    @IBOutlet weak var curScoreTextField: UITextField!
    @IBOutlet weak var curLevelTextField: UITextField!
    @IBOutlet weak var deathLabelButton: UIButton!
    
    
    // global
    let screenRefreshRate: Double = 1/60
    var timer: Timer?
    var game = Game(curLevel: 0, curScore: 0, bestScore: 0)
    
    // enemies
    var enemiesImageViews = [[UIImageView]]()
    var enemiesBulletsImageViews = [UIImageView]()
    var aliveEnemies: Int = 0
    var enemiesAttackCoolDown: Int = 0
    var enemiesFireRate: Int = 0
    var enemiesXOffset: CGFloat = 1
    var enemiesYOffset: CGFloat = 0
    let killPoints = 10
    
    // player
    var playerBulletsImageViews = [UIImageView]()
    var playerMovementSpeed: CGFloat = 5
    var playerAttackCoolDown: Int = 0
    var playerFireRate: Int = 0
    var playerXOffset: CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        launchGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startTimer()
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
    
    @IBAction func deathLabelButtonTouchDown(_ sender: Any) {
        deathLabelButton.isHidden = true
        restartGame()
        startTimer()
    }
    
    func cancelTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: screenRefreshRate, target: self, selector: #selector(drawObjects), userInfo: nil, repeats: true)
    }
    
    func clearScreen(){
        
        for i in 0...2{
            for j in 0...5{
                enemiesImageViews[i][j].removeFromSuperview()
            }
        }
        
        enemiesImageViews.removeAll()
    }
    
    func launchGame(){
        loadGameData()
        startGame()
    }
    
    func restartGame(){
        clearScreen()
        startGame()
    }
    
    func startGame() {
        loadPlayer()
        loadEnemies()
    }
    
    func increaseLevel(){
        cancelTimer()
        game.curLevel += 1
        curLevelTextField.text = String(game.curLevel)
        game.save()
        clearScreen()
        startGame()
        startTimer()
    }
    
    func loadGameData() {
        // get data from user defaults
        let defaults = UserDefaults.standard
        // check for first launch
        let curLevel = defaults.integer(forKey: "level")
        if (curLevel == 0){
            game.curLevel = 1
        }else{
            game.curLevel = curLevel
        }
        curLevelTextField.text = String(game.curLevel)
        game.curScore = defaults.integer(forKey: "score")
        game.bestScore = defaults.integer(forKey: "bestScore")
        bestScoreTextField.text = String(defaults.integer(forKey: "bestScore"))
    }
    
    func loadPlayer(){
        // position
        playerImageView.frame = CGRect(x: view.frame.width * 0.45 , y: view.frame.height - 100, width: 50 , height:  50)
        
        // player settings
        playerAttackCoolDown = Int(screenRefreshRate * 60.0 / 2.0)
        playerFireRate = 30
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
        enemiesAttackCoolDown += 1

        if (enemiesAttackCoolDown >= 60) {
            // choose random alive enemy
            var randomYIndex = Int.random(in: 0...2)
            var randomXIndex = Int.random(in: 0...5)
            var randomEnemy = enemiesImageViews[randomYIndex][randomXIndex]
            while (randomEnemy.isHidden) {
                randomYIndex = Int.random(in: 0...2)
                randomXIndex = Int.random(in: 0...5)
                randomEnemy = enemiesImageViews[randomYIndex][randomXIndex]
            }
            
            // create bullet
            let enemyBulletCGRect = CGRect(x: randomEnemy.frame.origin.x + randomEnemy.frame.width * 0.45, y: randomEnemy.frame.origin.y + randomEnemy.frame.height, width: randomEnemy.frame.width * 0.5, height: randomEnemy.frame.height * 0.5)
            let enemyBullet = UIImageView(frame: enemyBulletCGRect)
            enemyBullet.image = #imageLiteral(resourceName: "enemyBullet")
            view.addSubview(enemyBullet)
            enemiesBulletsImageViews.append(enemyBullet)
            enemiesAttackCoolDown = 0
        }

        // bullets movements
        for (index, bullet) in enemiesBulletsImageViews.enumerated() {
            bullet.frame.origin.y += 5
            if (bullet.frame.origin.y > view.frame.height + bullet.frame.height) {
                enemiesBulletsImageViews[index].removeFromSuperview()
                enemiesBulletsImageViews.remove(at: index)
            }
        }
        
        checkForPlayerDeath()
        
    }
    
    func playerAttack() {
        if (playerAttackCoolDown > playerFireRate) {
            let playerBulletCGRect = CGRect(x: playerImageView.frame.origin.x + playerImageView.frame.width * 0.3, y: playerImageView.frame.origin.y - playerImageView.frame.height * 0.3, width: playerImageView.frame.width * 0.5, height: playerImageView.frame.height * 0.5)
            let newPlayerBullet = UIImageView(frame: playerBulletCGRect)
            newPlayerBullet.image = #imageLiteral(resourceName: "playerBullet")
            view.addSubview(newPlayerBullet)
            playerBulletsImageViews.append(newPlayerBullet)
            playerAttackCoolDown = 0
        }
        
        checkForEnemyDeath()
    }
    
    func checkForEnemyDeath(){
        let bottomEnemyRowPosition = enemiesImageViews[2][0].frame.origin.y + enemiesImageViews[2][0].frame.height
        
        outer: for (index, bullet) in playerBulletsImageViews.enumerated(){
            bullet.frame.origin.y -= 10
            if (bullet.frame.origin.y < -100) {
                playerBulletsImageViews[index].removeFromSuperview()
                playerBulletsImageViews.remove(at: index)
            } else if (bullet.frame.origin.y <= bottomEnemyRowPosition){
                inner : for i in 0...2 {
                    for j in 0...5 {
                        if (bullet.frame.intersects(enemiesImageViews[i][j].frame) && enemiesImageViews[i][j].isHidden == false) {
                            playerBulletsImageViews[index].removeFromSuperview()
                            playerBulletsImageViews.remove(at: index)
                            enemiesImageViews[i][j].isHidden = true
                            game.curScore += game.curLevel * killPoints
                            curScoreTextField.text = String(game.curScore)
                            aliveEnemies -= 1
                            
                            if aliveEnemies == 0 {
                                increaseLevel()
                                break outer
                            }
                            break inner
                        }
                    }
                }
            }
        }
        
    }
    
    func checkForPlayerDeath() {
         
        // player and bottom enemy row intersect
        if (enemiesImageViews[2][0].frame.origin.y + enemiesImageViews[2][0].frame.height > playerImageView.frame.origin.y) {
            die()
        }

        for (index, bullet) in enemiesBulletsImageViews.enumerated() {
            // check for intersect only near player
            if (bullet.frame.origin.y + bullet.frame.height - 8 > playerImageView.frame.origin.y){
                if (bullet.frame.intersects(playerImageView.frame)) {
                    enemiesBulletsImageViews[index].removeFromSuperview()
                    enemiesBulletsImageViews.remove(at: index)
                    die()
                }
            }
        }
     }
    
    func die() {
        game.killPlayer()
        bestScoreTextField.text = String(game.bestScore)
        deathLabelButton.isHidden = false
        cancelTimer()
     }
    
}

