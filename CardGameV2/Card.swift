/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import SpriteKit

enum CardType: Int {
  case wolf
  case bear
  case dragon
}

class Card : SKSpriteNode {
  let cardType: CardType
  let frontTexture: SKTexture
  let backTexture: SKTexture = SKTexture(imageNamed: "card_back")
  var damage = 0
  
  var faceUp = true
  var enlarged = false
  var savedPosition = CGPoint.zero
  let largeTextureFilename: String
  var largeTexture: SKTexture?
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  init(cardType: CardType) {
    self.cardType = cardType
    
    switch cardType {
    case .wolf:
      frontTexture = SKTexture(imageNamed: "card_creature_wolf")
      largeTextureFilename = "card_creature_wolf_large"
    case .bear:
      frontTexture = SKTexture(imageNamed: "card_creature_bear")
      largeTextureFilename = "card_creature_bear_large"
    case .dragon:
      frontTexture = SKTexture(imageNamed: "card_creature_dragon")
      largeTextureFilename = "card_creature_dragon_large"
    }
    
    super.init(texture: frontTexture, color: .clear, size: frontTexture.size())
    self.addChild(damageLabel)
  }
  
  @discardableResult internal func pickup(_ now: Bool = true) -> SKAction {
    let scaleAction: SKAction = SKAction.scale(to: 1.3, duration: 0.15)
    let wiggleAction: SKAction = wiggle(true)
    
    let actionGroup: SKAction = SKAction.group([scaleAction, wiggleAction])
    if now {
      self.run(actionGroup)
    }
    
    return scaleAction
  }
  
  @discardableResult internal func drop(_ now: Bool = true) -> SKAction {
    let scaleAction: SKAction = SKAction.scale(to: 1.0, duration: 0.15)
    let nonWiggleAction: SKAction = wiggle(false)
    
    let actionGroup: SKAction = SKAction.group([scaleAction, nonWiggleAction])
    if now {
      self.run(actionGroup)
    }
    
    return scaleAction
  }
  
  @discardableResult internal func wiggle(_ animate: Bool) -> SKAction {
    let rotateWiggleIn = SKAction.rotate(toAngle: (CGFloat.pi / 180.0) * 15.0, duration: 0.10)
    let rotateWiggleOut = SKAction.rotate(toAngle: (CGFloat.pi / 180.0) * -15.0, duration: 0.10)
    let rotateRest = SKAction.rotate(toAngle: 0.0, duration: 0.15)
    let rotationSequence = SKAction.sequence([rotateWiggleIn, rotateWiggleOut, rotateRest])
    
    if animate {
      run(rotationSequence)
      return rotationSequence
    }
    else {
      // fixes mid-animation wiggle on touch ending
      let noWiggles: SKAction = SKAction.rotate(toAngle: 0.0, duration: 0.10, shortestUnitArc: true)
      run(noWiggles)
      return noWiggles
    }
  }
  
  func flip() {
    let firstHalfFlip = SKAction.scaleX(to: 0.0, duration: 0.4)
    let secondHalfFlip = SKAction.scaleX(to: 1.0, duration: 0.4)
    
    setScale(1.0)
    
    let (newTexture, hideLabel): (SKTexture, Bool) = faceUp ? (self.backTexture, true) : (self.frontTexture, false)
    
    run(firstHalfFlip, completion: { 
      self.texture = newTexture
      self.damageLabel.isHidden = hideLabel
      
      self.run(secondHalfFlip)
    }) 
    faceUp = !faceUp
  }
  
  func enlarge() {
    if enlarged {
      let slide = SKAction.move(to: savedPosition, duration:0.3)
      let scaleDown = SKAction.scale(to: 1.0, duration:0.3)
      run(SKAction.group([slide, scaleDown]), completion: {
        self.enlarged = false
        self.zPosition = CardLevel.board.rawValue
      }) 
    } else {
      enlarged = true
      savedPosition = position
      
      if largeTexture != nil {
        texture = largeTexture
      } else {
        largeTexture = SKTexture(imageNamed: largeTextureFilename)
        texture = largeTexture
      }
      
      zPosition = CardLevel.enlarged.rawValue
      
      if let parent = parent {
        removeAllActions()
        zRotation = 0
        let newPosition = CGPoint(x: parent.frame.midX, y: parent.frame.midY)
        let slide = SKAction.move(to: newPosition, duration:0.3)
        let scaleUp = SKAction.scale(to: 5.0, duration:0.3)
        run(SKAction.group([slide, scaleUp]))
      }
    }
  }
  
  
  // MARK: Lazy Instances
  internal lazy var damageLabel: SKLabelNode = {
    let damageLabel: SKLabelNode =  SKLabelNode(fontNamed: "OpenSans-Bold")
    damageLabel.name = "damageLabel"
    damageLabel.fontSize = 12
    damageLabel.fontColor = SKColor(red: 0.47, green: 0.0, blue: 0.0, alpha: 1.0)
    damageLabel.text = "0"
    damageLabel.position = CGPoint(x: 25, y: 40)
    return damageLabel
  }()

}
