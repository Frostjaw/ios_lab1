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
    var gameManager = GameManager(curLevel: 0, curScore: 0, bestScore: 0)
    
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
    
    // timer
    // !!! rendering without gameloop (hardcoded refresh rate)
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: screenRefreshRate, target: self, selector: #selector(drawObjects), userInfo: nil, repeats: true)
    }
    
    func cancelTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    @objc func drawObjects(){
        drawPlayer()
        drawEnemies()
    }
    
    // game
    func launchGame(){
        loadGameData()
        startGame()
    }
    
    func startGame() {
        updateLabels()
        loadPlayer()
        loadEnemies()
    }
    
    func restartGame(){
        clearScreen()
        startGame()
    }
    
    func loadGameData() {
        // get data from user defaults
        let defaults = UserDefaults.standard
        // check for first launch
        let curLevel = defaults.integer(forKey: "curLevel")
        if (curLevel == 0){
            gameManager.curLevel = 1
        }else{
            gameManager.curLevel = curLevel
        }
        gameManager.curScore = defaults.integer(forKey: "curScore")
        gameManager.bestScore = defaults.integer(forKey: "bestScore")
    }
    
    func clearScreen(){
        for i in 0...enemiesImageViews.count - 1{
            for j in 0...enemiesImageViews[0].count - 1{
                enemiesImageViews[i][j].removeFromSuperview()
            }
        }
        enemiesImageViews.removeAll()
    }
    
    func updateLabels(){
        curScoreTextField.text = String(gameManager.curScore)
        curLevelTextField.text = String(gameManager.curLevel)
        bestScoreTextField.text = String(gameManager.bestScore)
    }
    
    func increaseLevel(){
        cancelTimer()
        gameManager.curLevel += 1
        gameManager.save()
        clearScreen()
        startGame()
        startTimer()
    }
    
    // player
    func loadPlayer(){
        // position
        playerImageView.frame = CGRect(x: view.frame.width / 2 - playerImageView.frame.width / 2 , y: view.frame.height - 75, width: 50 , height:  50)
        
        // properties
        playerFireRate = Int ((1 / screenRefreshRate) / 2)
    }
    
    func drawPlayer(){
        // movement
        if ((playerImageView.frame.origin.x + playerXOffset > 8) && (playerImageView.frame.origin.x + playerImageView.frame.width + playerXOffset < view.frame.width - 8)){
            playerImageView.frame.origin.x += playerXOffset
        }
        
        // attack
        playerAttack()
    }
    
    func playerAttack() {
        playerAttackCoolDown += 1
        
        if (playerAttackCoolDown >= playerFireRate) {
            let playerBulletCGRect = CGRect(x: playerImageView.frame.origin.x + playerImageView.frame.width / 4, y: playerImageView.frame.origin.y, width: playerImageView.frame.width / 2, height: playerImageView.frame.height / 2)
            let newPlayerBullet = UIImageView(frame: playerBulletCGRect)
            newPlayerBullet.image = #imageLiteral(resourceName: "playerBullet")
            view.addSubview(newPlayerBullet)
            playerBulletsImageViews.append(newPlayerBullet)
            playerAttackCoolDown = 0
        }
        
        checkForEnemyDeath()
    }
    
    func checkForEnemyDeath(){
        let bottomEnemyRowPosition = enemiesImageViews[enemiesImageViews.count - 1][0].frame.origin.y + enemiesImageViews[enemiesImageViews.count - 1][0].frame.height
        
        outer: for (index, bullet) in playerBulletsImageViews.enumerated(){
            bullet.frame.origin.y -= 10
            if (bullet.frame.origin.y + bullet.frame.height < 0) {
                playerBulletsImageViews[index].removeFromSuperview()
                playerBulletsImageViews.remove(at: index)
            } else if (bullet.frame.origin.y <= bottomEnemyRowPosition){
                inner : for i in 0...enemiesImageViews.count - 1 {
                    for j in 0...enemiesImageViews[0].count - 1 {
                        if (bullet.frame.intersects(enemiesImageViews[i][j].frame) && enemiesImageViews[i][j].isHidden == false) {
                            playerBulletsImageViews[index].removeFromSuperview()
                            playerBulletsImageViews.remove(at: index)
                            enemiesImageViews[i][j].isHidden = true
                            gameManager.curScore += gameManager.curLevel * killPoints
                            curScoreTextField.text = String(gameManager.curScore)
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
    
    func killPlayer() {
        deathLabelButton.isHidden = false
        gameManager.restartGame()
        cancelTimer()
    }
    
    // enemies
    func loadEnemies() {
        // !!! hardcoded size of array
        for i in 0...2 {
            var enemiesRow = [UIImageView]()
            for j in 0...5{
                let enemy = UIImageView(image: #imageLiteral(resourceName: "enemy"))
                let enemyCGRect = CGRect(x: view.frame.width / 6 + CGFloat(j*50), y: view.frame.width / 7 + CGFloat(i*50) + CGFloat(25), width: view.frame.width / 10, height: view.frame.width / 10)
                enemy.frame = enemyCGRect
                enemiesRow.append(enemy)
                view.addSubview(enemy)
            }
            enemiesImageViews.append(enemiesRow)
        }
        
        // properties
        enemiesFireRate = Int((1 / screenRefreshRate) / 2 + 20)
        aliveEnemies = enemiesImageViews[0].count * enemiesImageViews.count
    }
    
    func drawEnemies() {
        // enemies movements
        
        // x axis
        for enemyRow in enemiesImageViews{
            for enemy in enemyRow{
                enemy.frame.origin.x += enemiesXOffset
            }
        }
        
        // constraints
        if (enemiesImageViews[0][enemiesImageViews[0].count - 1].frame.origin.x + enemiesImageViews[0][enemiesImageViews[0].count - 1].frame.width >= view.frame.width - 8) {
            enemiesXOffset = -1
            enemiesYOffset = view.frame.height / CGFloat(80 - 10 * gameManager.curLevel)
        }else if (enemiesImageViews[0][0].frame.origin.x  <= 8) {
            enemiesXOffset = 1
            enemiesYOffset = view.frame.height / CGFloat(80 - 10 * gameManager.curLevel)
        }
        
        // y axis
        for enemyRow in enemiesImageViews{
            for enemy in enemyRow{
                enemy.frame.origin.y += enemiesYOffset
            }
        }
        enemiesYOffset = 0
        
        // attack
        enemyAttack()
    }
    
    func enemyAttack(){
        enemiesAttackCoolDown += 1

        if (enemiesAttackCoolDown >= enemiesFireRate) {
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
            let enemyBulletCGRect = CGRect(x: randomEnemy.frame.origin.x + randomEnemy.frame.width / 4, y: randomEnemy.frame.origin.y + randomEnemy.frame.height, width: randomEnemy.frame.width / 2, height: randomEnemy.frame.height / 2)
            let enemyBullet = UIImageView(frame: enemyBulletCGRect)
            enemyBullet.image = #imageLiteral(resourceName: "enemyBullet")
            view.addSubview(enemyBullet)
            enemiesBulletsImageViews.append(enemyBullet)
            enemiesAttackCoolDown = 0
        }

        // bullets movements
        for (index, bullet) in enemiesBulletsImageViews.enumerated() {
            bullet.frame.origin.y += 5
            if (bullet.frame.origin.y + bullet.frame.height > view.frame.height) {
                enemiesBulletsImageViews[index].removeFromSuperview()
                enemiesBulletsImageViews.remove(at: index)
            }
        }
        
        checkForPlayerDeath()
        
    }
    
    func checkForPlayerDeath() {
        
       // player and bottom enemy row intersect
       if (enemiesImageViews[enemiesImageViews.count - 1][0].frame.origin.y + enemiesImageViews[enemiesImageViews.count - 1][0].frame.height > playerImageView.frame.origin.y) {
           killPlayer()
       }

       for (index, bullet) in enemiesBulletsImageViews.enumerated() {
           // check for intersect only near player
           if (bullet.frame.origin.y + bullet.frame.height > playerImageView.frame.origin.y - 8){
               if (bullet.frame.intersects(playerImageView.frame)) {
                   enemiesBulletsImageViews[index].removeFromSuperview()
                   enemiesBulletsImageViews.remove(at: index)
                   killPlayer()
               }
           }
       }
    }
    
}

