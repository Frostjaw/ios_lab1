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
    var enemiesImageViews: [[UIImageView]] = [[UIImageView]]()
    
    var timer : Timer?
    var game: Game?
    
    var enemiesXOffset: CGFloat = 1
    var enemiesYOffset: CGFloat = 0
    var playerXOffset: CGFloat = 0
    var playerMovementSpeed: CGFloat = 5
    
    var playerBulletsImageViews = [UIImageView]()
    var playerAttackCD = 30

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startGame()
        
        //test
        let const = CGRect(x: view.frame.width * 0.4 , y: view.frame.height - 0.2 * view.frame.width - (1/11) * view.frame.width, width: 0.2 * view.frame.width , height:  0.2 * view.frame.width)
        
        playerImageView.frame = const
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(drawObjects), userInfo: nil, repeats: true)
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
        createEnemies()
    }
    
    func loadGame() {
        // get data from user defaults and create Game instance
        //game = Game(curLevel: <#T##Int#>, curScore: <#T##Int#>, bestScore: <#T##Int#>)
    }
    
    func createEnemies() {
        
        // here should be logic for enemy(game) levels if their number will increase
        
        for i in 0...2 {
            var enemiesRow = [UIImageView]()
            for j in 0...5{
                let enemy = UIImageView(image: #imageLiteral(resourceName: "enemy"))
                let enemyCGRect = CGRect(x: view.frame.width * (1/6) + CGFloat(j*50), y: view.frame.width * (1/7) + CGFloat(i*50), width: view.frame.width * (1/10), height: view.frame.width * (1/10))
                enemy.frame = enemyCGRect
                enemiesRow.append(enemy)
                view.addSubview(enemy)
            }
            enemiesImageViews.append(enemiesRow)
        }
    }
    
    func drawPlayer(){
        // movement
        if ((playerImageView.frame.origin.x + playerXOffset > 8) && (playerImageView.frame.origin.x + playerXOffset + playerImageView.frame.width < view.frame.width - 8)){
            playerImageView.frame.origin.x += playerXOffset
        }
        playerAttackCD += 1
        attack()
    }
    
    func drawEnemies() {
        
        // here should be logic for enemy(game) levels if their ms and fire rate will increase
        
        //enemyAttack()
        
        // enemies moves
        
        // x axis
        for i in 0...2 {
            for j in 0...5 {
                enemiesImageViews[i][j].frame.origin.x += enemiesXOffset
            }
        }
        
        // checks
        for i in 0...2 {
            for j in 0...5 {
                if (enemiesImageViews[i][j].frame.origin.x + enemiesImageViews[i][j].frame.width >= view.frame.width - 8) {
                    enemiesXOffset = -1
                    enemiesYOffset += view.frame.height * (1/300)
                }else if (enemiesImageViews[i][j].frame.origin.x  <= 8) {
                    enemiesXOffset = 1
                    enemiesYOffset += view.frame.height * (1/300)
                }
            }
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
    
    func attack() {
        
        // test
        let playerFireRate = 30
        
        if playerAttackCD > playerFireRate {
            let myView = CGRect(x: playerImageView.frame.origin.x + playerImageView.frame.width * 0.45, y: playerImageView.frame.origin.y - playerImageView.frame.height * 0.3, width: playerImageView.frame.width * 0.1, height: playerImageView.frame.height * 0.5)
            let newPlayerBullet = UIImageView(frame: myView)
            newPlayerBullet.image = #imageLiteral(resourceName: "playerBullet")
            view.addSubview(newPlayerBullet)
            playerBulletsImageViews.append(newPlayerBullet)
            playerAttackCD = 0
        }
        
        outer: for (number, item) in playerBulletsImageViews.enumerated(){
            item.frame.origin.y -= 10
            if item.frame.origin.y < -100 {
                playerBulletsImageViews[number].removeFromSuperview()
                playerBulletsImageViews.remove(at: number)
            }
        }
    }
}

