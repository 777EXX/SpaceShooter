
import SpriteKit
import GameplayKit
import CoreMotion


//Привязать огонь ракеты к акселерометру!
//Сделать пламя для пули


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield:SKEffectNode!
    var player:SKSpriteNode!
    var scoreLabel:SKLabelNode!
    var shuttlefire:SKEffectNode!
   
    
    var score:Int = 0 {
        didSet {
            scoreLabel.text = "Счет: \(score)"
        }
    }
    var gameTimer:Timer!
    var aliens = ["alien", "alien2", "alien3"]
    
    
    let alienCategory:UInt32 = 0x1 << 1
    let bulletCategory:UInt32 = 0x1 << 0
    
    let motionManager = CMMotionManager()
    var xAccelerate:CGFloat = 0
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    

    override func sceneDidLoad() {
//        настройки звезного неба
        starfield = SKEffectNode(fileNamed: "starfield")
        starfield.position = CGPoint (x: 0, y: 1000)
        

        self.addChild(starfield)
        
        starfield.zPosition = -1
        
//       настройки игрока
        player = SKSpriteNode(imageNamed: "Shuttle")
        player.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
        player.setScale(0.08)
        
//        настройка пламени ракеты
        shuttlefire = SKEffectNode(fileNamed: "shuttlefire")
        shuttlefire.position = CGPoint(x: UIScreen.main.bounds.width / 2, y: 75)
        shuttlefire.setScale(0.75)
        
        self.addChild(shuttlefire)
        
        shuttlefire.zPosition = -0.5
        
//        настройки гравитации
        self.addChild(player)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
//        Настройки счета
        scoreLabel = SKLabelNode(text: "Счет: 0")
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontSize = 26
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: 80, y: UIScreen.main.bounds.height - 100)
        score = 0
        
        self.addChild(scoreLabel)
        
        var timeInterval = 0.75
        
        if UserDefaults.standard.bool(forKey: "hard") {
            timeInterval = 0.3
        }
        
        
        gameTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector:
                                            #selector(addAlien), userInfo: nil, repeats: true)
//        фунция для акселерометра
        motionManager.accelerometerUpdateInterval = 0.2
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data: CMAccelerometerData?, error: Error?) in
            if let accelerometerData = data {
                let acceleration = accelerometerData.acceleration
                self.xAccelerate = CGFloat(acceleration.x) * 0.75 + self.xAccelerate * 0.25
            }
        }
    }

//    Скорость движения  игрока
    override func didSimulatePhysics() {
        player.position.x += xAccelerate * 50
        shuttlefire.position.x += xAccelerate * 50
        
//        Передвижение Игрока по оси Y
        if player.position.x < 0 {
            player.position = CGPoint(x: UIScreen.main.bounds.width - player.size.width, y: player.position.y)
        } else if player.position.x > UIScreen.main.bounds.width {
            player.position = CGPoint(x: 20, y: player.position.y)
        }
//        Передвижение пламени по оси Y
        if shuttlefire.position.x < 0 {
//            shuttlefire.position = CGPoint(x: UIScreen.main.bounds.width - shuttlefire.size.width, y: shuttlefire.position.y)
        } else if shuttlefire.position.x > UIScreen.main.bounds.width {
            shuttlefire.position = CGPoint(x: 20, y: shuttlefire.position.y)
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var alienBody:SKPhysicsBody
        var bulletBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            bulletBody = contact.bodyA
            alienBody = contact.bodyB
        } else {
            bulletBody = contact.bodyB
            alienBody = contact.bodyA
        }
        if (alienBody.categoryBitMask & alienCategory) != 0 && (bulletBody.categoryBitMask & bulletCategory) != 0 {
            colisionElements(bulletNode: bulletBody.node as! SKSpriteNode, alienNode: alienBody.node as! SKSpriteNode)}
    }
    
//    Эффект  взрыва
    func colisionElements(bulletNode:SKSpriteNode, alienNode:SKSpriteNode) {
        let explosion = SKEmitterNode(fileNamed: "Vzriv")
        explosion?.position = alienNode.position
        
        self.addChild(explosion!)
        
        self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
        
        bulletNode.removeFromParent()
        alienNode.removeFromParent()
//        Время анимации взрыва
        self.run(SKAction.wait(forDuration: 0.5)) {
            explosion?.removeFromParent()
        }
        
        score += 1
    }
        
        @objc func addAlien () {
            aliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: aliens) as! [String]
            
//            Добавление  пришельцев
            let alien = SKSpriteNode(imageNamed: aliens[0])
            let randomPos = GKRandomDistribution (lowestValue: 20, highestValue: Int(UIScreen.main.bounds.size.width - 20))
            let pos = CGFloat (randomPos.nextInt())
            alien.position = CGPoint(x: pos, y: UIScreen.main.bounds.size.height + alien.size.height)
          alien.setScale(0.05)
            
            alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
            alien.physicsBody?.isDynamic = true
            
            alien.physicsBody?.categoryBitMask = alienCategory
            alien.physicsBody?.contactTestBitMask = bulletCategory
            alien.physicsBody?.collisionBitMask = 0
            
            self.addChild(alien)
            
            let animDuration:TimeInterval = 6
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: pos, y: 0 - alien.size.height), duration: animDuration))
            actions.append(SKAction.removeFromParent())
            
            alien.run(SKAction.sequence(actions))
        }
       
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            fireBullet()
        }
        
//
        func fireBullet() {
            self.run(SKAction.playSoundFileNamed("vzriv.mp3", waitForCompletion: false))
            
            let bullet = SKSpriteNode(imageNamed: "torpedo")
            bullet.position = player.position
            bullet.position.y += 120
            bullet.setScale(0.025)
            
            bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 1)
            bullet.physicsBody?.isDynamic = true
            
            bullet.physicsBody?.categoryBitMask = bulletCategory
            bullet.physicsBody?.contactTestBitMask = alienCategory
            bullet.physicsBody?.collisionBitMask = 0
            bullet.physicsBody?.usesPreciseCollisionDetection = true
            
            self.addChild(bullet)
            
            let animDuration:TimeInterval = 0.3
            var actions = [SKAction]()
            actions.append(SKAction.move(to: CGPoint(x: player.position.x, y: UIScreen.main.bounds.size.height + bullet.size.height), duration: animDuration))
            actions.append(SKAction.removeFromParent())
            
            bullet.run(SKAction.sequence(actions))
        }
        
        
        override func update(_ currentTime: TimeInterval) {
            // Called before each frame is rendered
        }
    }

