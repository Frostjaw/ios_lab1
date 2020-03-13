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
    
    var timer : Timer?
    
    var enemies: [[UIImageView]] = [[UIImageView]]()
    
    var enemyXDir :CGFloat = 1
    var enemyYDir :CGFloat = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        createEnemies()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        timer = Timer.scheduledTimer(timeInterval: 1/60, target: self, selector: #selector(draw), userInfo: nil, repeats: true)
    }
    
    @objc func draw(){
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
    
    func createEnemies() {
        for i in 0...2 {
            var enemiesRow = [UIImageView]()
            for j in 0...5{
                let enemy = UIImageView(image: #imageLiteral(resourceName: "enemy"))
                let enemyCGRect = CGRect(x: view.frame.width * (1/6) + CGFloat(j*50), y: view.frame.width * (1/7) + CGFloat(i*50), width: view.frame.width * (1/10), height: view.frame.width * (1/10))
                enemy.frame = enemyCGRect
                enemiesRow.append(enemy)
                view.addSubview(enemy)
            }
            enemies.append(enemiesRow)
        }
    }
    
    func drawEnemies() {
        //enemyAttack()
        
        for i in 0...2 {
            for j in 0...5 {
                enemies[i][j].frame.origin.x += enemyXDir
            }
        }
        
        for i in 0...2{
            if enemies[i][0].frame.origin.x + enemies[i][0].frame.width >= view.frame.width {
                enemyXDir = -1
                enemyYDir += view.frame.width * (1/44)
            }
            if enemies[i][0].frame.origin.x  <= 0 {
                enemyXDir = 1
                enemyYDir += view.frame.width * (1/44)
            }
        }
        
//        for i in 0...2 {
//            for j in 0...5 {
//                enemies[i][j].frame.origin.y += enemyYDir
//                enemies[i][j].transform = CGAffineTransform(scaleX: enemyXDir, y: 1)
//            }
//        }
        enemyYDir = 0
        
        
    }


}

