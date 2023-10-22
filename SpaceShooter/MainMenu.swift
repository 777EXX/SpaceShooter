
import SpriteKit

class MainMenu: SKScene {
    
    var starfield:SKEmitterNode!
    
    var newGameBtnNode:SKSpriteNode!
    var levelBtnNode:SKSpriteNode!
    var labelLevelNode:SKLabelNode!
    
    //    задержка анимации космоса
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfield_anim") as? SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        //        Отображение кнопок в меню
        newGameBtnNode = self.childNode(withName: "newGameBtn") as? SKSpriteNode
        newGameBtnNode.texture = SKTexture(imageNamed: "newGameBtn")
        
        levelBtnNode = self.childNode(withName: "levelBtn") as? SKSpriteNode
        levelBtnNode.texture = SKTexture(imageNamed: "levelBtn")
        
        labelLevelNode = self.childNode(withName: "labelLevelBtn") as? SKLabelNode
        
        let userLevel = UserDefaults.standard
        
        if userLevel.bool(forKey: "hard") {
            labelLevelNode.text = "Сложно"
        } else {
            labelLevelNode.text = "Легко"

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        if let location = touch?.location(in: self) {
            let nodesArray = self.nodes(at: location)
            
            if nodesArray.first?.name == "newGameBtn" {
                let transition = SKTransition.flipVertical(withDuration: 0.5)
                let gameScene = GameScene(size: UIScreen.main.bounds.size)
                self.view?.presentScene(gameScene, transition: transition)
            } else if nodesArray.first?.name == "levelBtn" {
                changeLevel()
            }
            
        }
        
    }
    
    func changeLevel() {
        let userLevel = UserDefaults.standard
        
        if labelLevelNode.text == "Легко" {
            labelLevelNode.text = "Сложно"
            userLevel.set(true, forKey: "hard")
        } else {
            labelLevelNode.text = "Легко"
            userLevel.set(false, forKey: "hard")
        }
        
        userLevel.synchronize()
    }
    
}
