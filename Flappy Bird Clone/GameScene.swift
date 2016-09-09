//
//  GameScene.swift
//  Flappy Bird Clone
//
//  Created by Arunjot Singh on 6/15/16.
//  Copyright (c) 2016 Arunjot Singh. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var score = 0
    var scoreLabel = SKLabelNode()
    var gameOverLabel = SKLabelNode()
    var infoLabel = SKLabelNode()
    
    var infoLabelContainer = SKSpriteNode()
    var gameOverLabelContaner = SKSpriteNode()
    
    var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    
    var movingObjects = SKSpriteNode()
    
    var gameOver = false
    
    enum colliderType: UInt32 {
        
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    
    func makebg() {
        
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let movebg = SKAction.moveByX(-bgTexture.size().width, y: 0, duration: 9)
        let replacebg = SKAction.moveByX(bgTexture.size().width, y: 0, duration: 0)
        let movebgForever = SKAction.repeatActionForever(SKAction.sequence([movebg,replacebg]))
        
        for i in 0 ..< 3 {
            
            bg = SKSpriteNode(texture: bgTexture)
            bg.position = CGPoint(x: bgTexture.size().width/2 + bgTexture.size().width * CGFloat(i), y: CGRectGetMidY(self.frame))
            bg.zPosition = -1
            bg.size.height = self.frame.height
            
            bg.runAction(movebgForever)
            movingObjects.addChild(bg)

        }
    }
    
    func makeBird() {
        
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animateWithTextures([birdTexture1, birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatActionForever(animation)
        
        bird = SKSpriteNode(texture: birdTexture1)
        
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height/2)
        bird.physicsBody?.dynamic = false
        bird.physicsBody?.categoryBitMask = colliderType.Bird.rawValue
        bird.physicsBody?.contactTestBitMask = colliderType.Object.rawValue
        bird.physicsBody?.collisionBitMask = colliderType.Object.rawValue
        
        bird.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        bird.zPosition = 1
        bird.runAction(makeBirdFlap)
        
        movingObjects.addChild(bird)
    }
    
    func makeInfoLabel() {
        
        infoLabel.fontName = "Helvetica"
        infoLabel.fontSize = 30
        infoLabel.fontColor = UIColor.blueColor()
        infoLabel.text = "Tap to control"
        infoLabel.position = CGPointMake(CGRectGetMidX(self.frame), (CGRectGetMidY(self.frame)/2))
        infoLabelContainer.addChild(infoLabel)
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.physicsWorld.contactDelegate = self
        self.addChild(movingObjects)
        self.addChild(gameOverLabelContaner)
        self.addChild(infoLabelContainer)
        
        makebg()
        
        
        makeBird()
        
        let triggerTime = (Int64(NSEC_PER_SEC) * 3)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
            self.intialLoad()
        })
        
        let ground = SKNode()
        ground.position = CGPointMake(0, 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, 1))
        ground.physicsBody?.dynamic = false
        ground.physicsBody?.categoryBitMask = colliderType.Object.rawValue
        ground.physicsBody?.contactTestBitMask = colliderType.Object.rawValue
        ground.physicsBody?.collisionBitMask = colliderType.Object.rawValue
        
        self.addChild(ground)
        
      
        dispatch_async(dispatch_get_main_queue()) {
            let timer = NSTimer(timeInterval: 3, target: self, selector: #selector(GameScene.makePipes), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        }
        
        
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height - 70)
        scoreLabel.zPosition = 5
        self.addChild(scoreLabel)
        
      
        makeInfoLabel()

//        let skView = view
//        
//        skView.showsPhysics = true
    }
    
    func intialLoad() {
        bird.physicsBody?.dynamic = true
        infoLabelContainer.removeAllChildren()
    }
    
    
    func makePipes() {
        
        let gapHeight = bird.size.height * 4
        let movementAmount = arc4random() % UInt32(self.frame.size.height/2)
        let pipeOffset = CGFloat(movementAmount) - self.frame.size.height / 4
        
        let movePipes = SKAction.moveByX(-self.frame.size.width * 2, y: 0, duration: NSTimeInterval(self.frame.size.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipes, removePipes])
        
        let pipe1Texture = SKTexture(imageNamed: "pipe1.png")
        pipe1 = SKSpriteNode(texture: pipe1Texture)
        pipe1.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) + pipe1Texture.size().height/2 + gapHeight/2 + pipeOffset)
        pipe1.runAction(moveAndRemovePipes)
        
        pipe1.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size())
        pipe1.physicsBody?.dynamic = false
        pipe1.physicsBody?.categoryBitMask = colliderType.Object.rawValue
        pipe1.physicsBody?.contactTestBitMask = colliderType.Object.rawValue
        pipe1.physicsBody?.collisionBitMask = colliderType.Object.rawValue

        
        movingObjects.addChild(pipe1)
        
        let pipe2Texture = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipe2Texture)
        pipe2.position = CGPointMake(CGRectGetMidX(self.frame) + self.frame.size.width, CGRectGetMidY(self.frame) - pipe2Texture.size().height/2 - gapHeight/2 + pipeOffset)
        pipe2.runAction(moveAndRemovePipes)
        
        pipe2.physicsBody = SKPhysicsBody(rectangleOfSize: pipe1Texture.size())
        pipe2.physicsBody?.dynamic = false
        pipe2.physicsBody?.categoryBitMask = colliderType.Object.rawValue
        pipe2.physicsBody?.contactTestBitMask = colliderType.Object.rawValue
        pipe2.physicsBody?.collisionBitMask = colliderType.Object.rawValue
        
        movingObjects.addChild(pipe2)
        
        let gap = SKNode()
        gap.position = CGPoint(x: CGRectGetMidX(self.frame) + self.frame.size.width + pipe1.size.width, y: CGRectGetMidY(self.frame) + pipeOffset)
        gap.runAction(moveAndRemovePipes)
        
        gap.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(pipe1.size.width, gapHeight))
        gap.physicsBody?.dynamic = false
        gap.physicsBody?.categoryBitMask = colliderType.Gap.rawValue
        gap.physicsBody?.contactTestBitMask = colliderType.Bird.rawValue
        gap.physicsBody?.collisionBitMask = colliderType.Gap.rawValue
        
        movingObjects.addChild(gap)
        

    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {

        if contact.bodyA.categoryBitMask == colliderType.Gap.rawValue || contact.bodyB.categoryBitMask == colliderType.Gap.rawValue {
            score += 1
            scoreLabel.text = String(score)
        
        } else {
            
            if gameOver == false {
                
                gameOver = true
                self.speed = 0
                print("we have a contact!")
                print("Score = \(score)")
                gameOverLabel.fontName = "Helvetica"
                gameOverLabel.fontSize = 30
                gameOverLabel.text = "Game Over! Tap to play again"
                gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame))
                
                gameOverLabelContaner.addChild(gameOverLabel)

            }
            
        }
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        if gameOver == false {
            infoLabelContainer.removeAllChildren()
            bird.physicsBody?.dynamic = true
            bird.physicsBody?.velocity = CGVectorMake(0, 0)
            bird.physicsBody?.applyImpulse(CGVectorMake(0, 70))
            
        } else {
            
            score = 0
            scoreLabel.text = "0"
            gameOver = false

            movingObjects.removeAllChildren()
            gameOverLabelContaner.removeAllChildren()

            makebg()
            makeBird()
            makeInfoLabel()
            self.speed = 1
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
