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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startGame()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(drawObjects), userInfo: nil, repeats: true)
    }
    
    @objc func drawObjects(){
        //drawPlayer()
        drawEnemies()
    }
    
    @IBAction func leftButtonTouchDown(_ sender: Any) {
        if (playerImageView.frame.origin.x >= 16){
            playerImageView.frame.origin.x -= 10
        }
    }
    
    @IBAction func rightButtonTouchDown(_ sender: Any) {
        if (playerImageView.frame.origin.x <= view.frame.maxX - playerImageView.frame.width - 16){
            playerImageView.frame.origin.x += 10
        }
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
    
    func drawEnemies() {
        
        // here should be logic for enemy(game) levels if their ms and fire rate will increase
        
        //enemyAttack()
        
        // enemies moves
        
        // x axis
        for i in 0...2 {
            for j in 0...5 {
                if (enemiesImageViews[i][j].frame.origin.x + enemiesImageViews[i][j].frame.width >= view.frame.width - 8) {
                    enemiesXOffset = -1
                    enemiesYOffset += view.frame.height * (1/40)
                }else if (enemiesImageViews[i][j].frame.origin.x  <= 8) {
                    enemiesXOffset = 1
                    enemiesYOffset += view.frame.height * (1/40)
                }
                
                enemiesImageViews[i][j].frame.origin.x += enemiesXOffset
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
}

