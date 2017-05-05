//
//  CircularCollectionViewLayout.swift
//  CircularCollectionView
//
//  Created by Dung Vu on 5/5/17.
//  Copyright © 2017 Rounak Jain. All rights reserved.
//

import UIKit
//https://www.raywenderlich.com/107687/uicollectionview-custom-layout-tutorial-spinning-wheel
class CircularCollectionViewLayoutAttributes: UICollectionViewLayoutAttributes {
  var anchorPoint = CGPoint(x: 0.5, y: 0.5)
  var angle: CGFloat = 0 {
    // 2
    didSet {
      zIndex = Int(angle * 1000000)
      transform = CGAffineTransform(rotationAngle: angle)
    }
  }
  
  override func copy(with zone: NSZone? = nil) -> Any {
    guard let attribute = super.copy(with: zone) as? CircularCollectionViewLayoutAttributes else {
      return CircularCollectionViewLayoutAttributes()
    }
    attribute.anchorPoint = self.anchorPoint
    attribute.angle = self.angle
    return attribute
  }
  
}



class CircularCollectionViewLayout: UICollectionViewLayout {
  
  let itemSize = CGSize(width: 133, height: 173)
  var angleAtExtreme: CGFloat {
    let numberItems = collectionView?.numberOfItems(inSection: 0) ?? 0
    return numberItems > 0 ?
      -CGFloat(numberItems - 1) * anglePerItem : 0
  }
  
  var angle: CGFloat {
    return angleAtExtreme * (collectionView?.contentOffset.x ?? 0) / (collectionViewContentSize.width -
      (collectionView?.bounds.width ?? 0))
  }
  
  var radius: CGFloat = 500 {
    didSet {
      invalidateLayout()
    }
  }
  
  override class var layoutAttributesClass: AnyClass {
    return CircularCollectionViewLayoutAttributes.self
  }
  
  var attributesList = [CircularCollectionViewLayoutAttributes]()

  // Calculate between itemSize and radius
  var anglePerItem: CGFloat {
    return atan(itemSize.width / radius)
  }

  override var collectionViewContentSize: CGSize {
    return CGSize(width: CGFloat((collectionView?.numberOfItems(inSection: 0)) ?? 0) * itemSize.width,
                  height: collectionView?.bounds.height ?? 0)
  }
  
  override func prepare() {
    super.prepare()
    guard let collectionView = self.collectionView else {
      return
    }
    let centerX = collectionView.contentOffset.x + (collectionView.bounds.width / 2.0)
    // 1
    let theta = atan2(collectionView.bounds.width / 2.0,
                      radius + (itemSize.height / 2.0) - (collectionView.bounds.height / 2.0))
    // 2
    var startIndex = 0
    var endIndex = collectionView.numberOfItems(inSection: 0) - 1
    // 3
    if (angle < -theta) {
      startIndex = Int(floor((-theta - angle) / anglePerItem))
    }
    // 4
    endIndex = min(endIndex, Int(ceil((theta - angle) / anglePerItem)))
    // 5
    if (endIndex < startIndex) {
      endIndex = 0
      startIndex = 0
    }
    // Calculate attribute
    attributesList = (startIndex...endIndex).map({
      let attributes = CircularCollectionViewLayoutAttributes(forCellWith: IndexPath(item: $0, section: 0))
      let anchorPointY = ((itemSize.height / 2.0) + radius) / itemSize.height
      
      attributes.anchorPoint = CGPoint(x: 0.5, y: anchorPointY)
      attributes.size = self.itemSize
      attributes.center = CGPoint(x: centerX, y: collectionView.bounds.midY)
//      attributes.angle = self.anglePerItem * CGFloat($0)
      attributes.angle = self.angle + (self.anglePerItem * CGFloat($0))

      return attributes

    })
  }
  
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    return attributesList
  }
  
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return attributesList[indexPath.item]
  }
  
  // Returning true from this method tells the collection view to invalidate it’s layout as it scrolls, which in turn calls prepareLayout() where you can recalculate the cells’ layout with updated angular positions.
  override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
    return true
  }
  
//  override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//    var finalContentOffset = proposedContentOffset
//    let factor = -angleAtExtreme / (collectionViewContentSize.width - (collectionView?.bounds.width ?? 0))
//    let proposedAngle = proposedContentOffset.x * factor
//    let ratio = proposedAngle / anglePerItem
//    var multiplier: CGFloat
//    if (velocity.x > 0) {
//      multiplier = ceil(ratio)
//    } else if (velocity.x < 0) {
//      multiplier = floor(ratio)
//    } else {
//      multiplier = round(ratio)
//    }
//    finalContentOffset.x = multiplier * anglePerItem / factor
//    return finalContentOffset
//  }
  
  
}
