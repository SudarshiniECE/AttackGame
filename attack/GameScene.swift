//
//  GameScene.swift
//  attack
//
//  Created by Sudharshini on 19/06/19.
//  Copyright © 2019 Sudharshini. All rights reserved.
//

import SpriteKit
import GameplayKit
struct PhysicsCategory {
    static let none      : UInt32 = 0
    static let all       : UInt32 = UInt32.max
    static let monster   : UInt32 = 0b1       // 1
    static let projectile: UInt32 = 0b10      // 2
}

func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func -(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func *(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func /(point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene {
    var scoreLabel: SKLabelNode!
    let player = SKSpriteNode(imageNamed: "player")
    let backgroundImage = SKSpriteNode(imageNamed: "bgimage")
    var count = 0
    //create the bird atlas for animation
    let birdAtlas = SKTextureAtlas(named: "monster")
    var birdSprites = Array<Any>()
    var repeatActionBird = SKAction()
    let levelTimerLabel = SKLabelNode(fontNamed: "Chalkduster")
    var levelTimerValue: Int  = 100
    var levelTimer = Timer()
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.lightGray
        backgroundImage.position = CGPoint(x: frame.origin.x, y: frame.origin.y)
        backgroundImage.size.width = self.size.width
        backgroundImage.size.height = self.size.height
        backgroundImage.anchorPoint = CGPoint(x: 0,y: 0)
        backgroundImage.zPosition = -1
        addChild(backgroundImage)
        player.position = CGPoint(x: size.width * 0.1 , y: size.height * 0.5)
       addChild(player)
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),SKAction.wait(forDuration: 1.0)])))
        
        //physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(count)"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 180, y: 360)
        addChild(scoreLabel)
        startLevelTimer()
        
        
    }
    
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min:CGFloat,max:CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    func addMonster()
    {
        //create sprite
        let monster = SKSpriteNode(texture: SKTextureAtlas(named:"monster").textureNamed("bat1"))
        
        //determine where to spawn the bat along the y axis
        let actualY = random(min:monster.size.height/2,max:size.height - monster.size.height/2)
        //position the bat slightly off the screen along thr right edge and along the random position along y axisas calculated above
        monster.position = CGPoint(x:size.width + monster.size.width / 2 , y:actualY)
        
        
        //SET UP THE BIRD SPRITES FOR ANIMATION
        birdSprites.append(birdAtlas.textureNamed("bat1"))
        birdSprites.append(birdAtlas.textureNamed("bat2"))
        birdSprites.append(birdAtlas.textureNamed("bat3"))
        birdSprites.append(birdAtlas.textureNamed("bat4"))
        birdSprites.append(birdAtlas.textureNamed("bat5"))
        birdSprites.append(birdAtlas.textureNamed("bat6"))
        birdSprites.append(birdAtlas.textureNamed("bat7"))
        
        
        
        //add the monster to the scene
        addChild(monster)
        
        //determine the speed of the monster
        let actualduration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        //PREPARE TO ANIMATE THE BIRD AND REPEAT THE ANIMATION FOREVER
        let animateBird = SKAction.animate(with: self.birdSprites as! [SKTexture], timePerFrame: 0.1)
        self.repeatActionBird = SKAction.repeatForever(animateBird)
        monster.run(repeatActionBird)
        
        //Create the actions
        let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width/2, y: actualY), duration: TimeInterval(actualduration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.run(SKAction.sequence([actionMove,actionMoveDone]))
        
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // 1
        monster.physicsBody?.isDynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.none // 5

    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = CGPoint(x: player.position.x + 100, y: player.position.y + 80)

        // 3 - Determine offset of location to projectile
        let offset = touchLocation - projectile.position
        
        // 4 - Bail out if you are shooting down or backwards
        if offset.x < 0 { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * 1000
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.none
        projectile.physicsBody?.usesPreciseCollisionDetection = true

    }
    
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
       scoreLabel.text = "Score: \(count)"
        count = count + 1
        projectile.removeFromParent()
        monster.texture = SKTexture(imageNamed: "burnedBird")
        monster.removeAllActions()
        monster.speed = 0.000000001
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            monster.removeFromParent()
        }
        
    }
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode,
                let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
    }

    func startLevelTimer() {
        
        levelTimerLabel.fontColor = SKColor.black
        levelTimerLabel.fontSize = 40
        levelTimerLabel.position = CGPoint(x: 600, y: 360)
        addChild(levelTimerLabel)
        
        levelTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(levelCountdown), userInfo: nil, repeats: true)
        
        levelTimerLabel.text = String(levelTimerValue)
        
    }
    @objc func levelCountdown(){
        
        levelTimerValue = levelTimerValue - 1
        levelTimerLabel.text = String(levelTimerValue)
        if(levelTimerValue == 0)
        {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size, count: count)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        
    }
}
extension GameScene: SKPhysicsContactDelegate {
    
}
