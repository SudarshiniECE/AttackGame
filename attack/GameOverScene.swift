//
//  GameOverScene.swift
//  attack
//
//  Created by Sudharshini on 20/06/19.
//  Copyright © 2019 Sudharshini. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    var screenSize = CGSize()
    init(size: CGSize, count : Int) {
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        let label = SKLabelNode(fontNamed: "Chalkduster")
        label.text = "Your Score : \(count)"
        label.fontSize = 30
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2 + 25)
        addChild(label)
        
        let label2 = SKLabelNode(fontNamed: "Chalkduster")
        label2.text = "Tap to play again!"
        label2.fontSize = 35
        label2.fontColor = SKColor.blue
        label2.position = CGPoint(x: size.width/2, y: size.height/2 - 25)
        addChild(label2)
        screenSize = size
        
        // 4
       
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0),
            SKAction.run() { [weak self] in
                // 5
                guard let `self` = self else { return }
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: self.screenSize)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
    }
}
