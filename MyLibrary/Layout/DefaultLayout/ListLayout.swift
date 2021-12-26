//
//  ListLayout.swift
//  MyLibrary
//
//  Created by Birkyboy on 23/11/2021.
//

import UIKit
import SwiftUI

class ListLayout {
 
    private  func makeVerticalGridLayoutSection(gridItemSize: GridItemSize,
                                                environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        
        let desiredWidth: CGFloat = environment.container.effectiveContentSize.width * gridItemSize.rawValue
        print(desiredWidth)
        let itemCount = environment.container.effectiveContentSize.width / desiredWidth
        print(itemCount)
        let fractionWidth: CGFloat = 1 / (itemCount.rounded())
        print(fractionWidth)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .init(top: 0, leading: 2.5, bottom: 17, trailing: 2.5)
      
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                               heightDimension: .fractionalWidth(fractionWidth * 1.7))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 5, leading: 7, bottom: 0, trailing: 7)
        section.boundarySupplementaryItems = [addFooter()]
        return section
    }
    
    private func addFooter() -> NSCollectionLayoutBoundarySupplementaryItem {
        let footerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: footerItemSize,
                                                           elementKind: UICollectionView.elementKindSectionFooter,
                                                           alignment: .bottom)
    }
}
// MARK: - Layout composer protocol
extension ListLayout: DefaultLayoutComposer {
    
    func setCollectionViewLayout(gridItemSize: GridItemSize) -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] _, environement in
            return self?.makeVerticalGridLayoutSection(gridItemSize: gridItemSize, environment: environement)
        }
    }
}
