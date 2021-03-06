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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


enum CardLevel :CGFloat {
  case board = 10
  case moving = 100
  case enlarged = 200
}

class GameScene: SKScene {
  
  override func didMove(to view: SKView) {
    let bg = SKSpriteNode(imageNamed: "bg_blank")
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    addChild(bg)
    
    
    let wolf = Card(cardType: .wolf)
    wolf.position = CGPoint(x: 100,y: 200)
    addChild(wolf)
    
    let bear = Card(cardType: .bear)
    bear.position = CGPoint(x: 300, y: 200)
    addChild(bear)
  }
  
  
  // MARK: - Touch Overrides
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint, touchOfInterest: UITouch?) in
      if let touchedCard: Card = card {
        if touchOfInterest?.tapCount > 1 {
          touchedCard.enlarge()
        }
        if touchedCard.enlarged { return }
        
        touchedCard.zPosition = CardLevel.moving.rawValue
        touchedCard.pickup()
      }
    }

  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint, touchOfInterest: UITouch?) in
      if card != nil {
        if card!.enlarged { return }
      }
      
      card?.position = touchPoint
    }
    
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint, touchOfInterest: UITouch?) in
      if card != nil {
        if card!.enlarged { return }
        
        card!.zPosition = CardLevel.board.rawValue
        card!.removeFromParent()
        self.addChild(card!)
        
        card?.drop()
      }
    }
    
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    // seems to be a problem with the sim where the touch is lost in some cpu cycle. so this code isn't really doing anything
    
    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint, touchOfInterest: UITouch?) in
      card?.position = touchPoint
      card?.wiggle(false)
      card?.drop()
    }
  }
  
  // Mark: - Helpers
  fileprivate func locateCardInScene(fromTouches touches: Set<UITouch>, actionBlock: (_ card: Card?, _ touchPoint: CGPoint, _ touchOfInterest: UITouch?)->Void) {
    for touch in touches {
      let location = touch.location(in: self)
      if let card: Card = atPoint(location) as? Card {
        actionBlock(card, location, touch)
      }
    }
  }
  
}
