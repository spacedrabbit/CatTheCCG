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

enum CardLevel :CGFloat {
  case board = 10
  case moving = 100
  case enlarged = 200
}

class GameScene: SKScene {
  
  override func didMoveToView(view: SKView) {
    let bg = SKSpriteNode(imageNamed: "bg_blank")
    bg.anchorPoint = CGPoint.zero
    bg.position = CGPoint.zero
    addChild(bg)
    
    
    let wolf = Card(cardType: .Wolf)
    wolf.position = CGPointMake(100,200)
    addChild(wolf)
    
    let bear = Card(cardType: .Bear)
    bear.position = CGPointMake(300, 200)
    addChild(bear)
  }
  
  
  // MARK: - Touch Overrides
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint) in
      card?.zPosition = CardLevel.moving.rawValue
      
      card?.wiggle(true)
      card?.pickup()
    }

  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {

    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint) in
      card?.position = touchPoint
    }
    
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    
    locateCardInScene(fromTouches: touches) { (card: Card?, touchPoint: CGPoint) in
      if card != nil {
        card!.zPosition = CardLevel.board.rawValue
        card!.removeFromParent()
        self.addChild(card!)
        
        card?.wiggle(false)
        card?.drop()
      }
    }
    
  }
  
  override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
    guard let validTouches = touches else { return }
    // seems to be a problem with the sim where the touch is lost in some cpu cycle. so this code isn't really doing anything
    
    locateCardInScene(fromTouches: validTouches) { (card: Card?, touchPoint: CGPoint) in
      card?.wiggle(false)
    }
  }
  
  // Mark: - Helpers
  private func locateCardInScene(fromTouches touches: Set<UITouch>, actionBlock: (card: Card?, touchPoint: CGPoint)->Void) {
    for touch in touches {
      let location = touch.locationInNode(self)
      if let card: Card = nodeAtPoint(location) as? Card {
        actionBlock(card: card, touchPoint: location)
      }
    }
  }
  
}
