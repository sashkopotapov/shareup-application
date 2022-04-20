//
//  File.swift
//  
//
//  Created by Oleksandr Potapov on 20.04.2022.
//

import UIKit

protocol WordleLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, heightForScoreAtIndexPath indexPath: IndexPath) -> CGFloat
}

class WordleLayout: UICollectionViewLayout {
    weak var delegate: WordleLayoutDelegate?
    
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var deletingIndexPaths = [IndexPath]()
    private var insertingIndexPaths = [IndexPath]()
    
    private var contentHeight: CGFloat = 0
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    func resetCache() {
        cache.removeAll()
    }
    
    override func prepare() {
        guard
            cache.isEmpty == true,
            let collectionView = collectionView
        else {
            return
        }
        let columnWidth = contentWidth / CGFloat(numberOfColumns)
        var xOffset: [CGFloat] = []
        for column in 0..<numberOfColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
        for item in 0..<collectionView.numberOfItems(inSection: 0) {
            let indexPath = IndexPath(item: item, section: 0)
            
            let photoHeight = delegate?.collectionView(
                collectionView,
                heightForScoreAtIndexPath: indexPath) ?? 180
            let height = cellPadding * 2 + photoHeight
            let frame = CGRect(x: xOffset[column],
                               y: yOffset[column],
                               width: columnWidth,
                               height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cache.isEmpty {
            print("Cache is empty")
            prepare()
        }
        return cache[indexPath.item]
    }
    
    // MARK: Attributes for Updated Items

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) else { return nil }

        if !deletingIndexPaths.isEmpty {
            if deletingIndexPaths.contains(itemIndexPath) {

                attributes.transform3D = CATransform3DRotate(CATransform3DIdentity, CGFloat(Double.pi), 1, 0, 0) // CGAffineTransform(scaleX: 0.5, y: 0.5)
                attributes.alpha = 0.0
                attributes.zIndex = 0
            }
        }

        return attributes
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) else { return nil }

        if insertingIndexPaths.contains(itemIndexPath) {
            attributes.transform3D = CATransform3DRotate(CATransform3DIdentity, CGFloat(Double.pi), 1, 0, 0) // CGAffineTransform(scaleX: 0.5, y: 0.5)
            attributes.alpha = 0.0
            attributes.zIndex = 0
        }

        return attributes
    }

    // MARK: Updates

    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)

        for update in updateItems {
            switch update.updateAction {
                case .delete:
                    guard let indexPath = update.indexPathBeforeUpdate else { return }
                    deletingIndexPaths.append(indexPath)
                case .insert:
                    guard let indexPath = update.indexPathAfterUpdate else { return }
                    insertingIndexPaths.append(indexPath)
                default:
                    break
            }
        }
    }

    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()

        deletingIndexPaths.removeAll()
        insertingIndexPaths.removeAll()
    }
}
