//
//  HomeControllerLayout.swift
//  MyLibrary
//
//  Created by Birkyboy on 23/11/2021.
//

import UIKit

class IphoneHomeTabLayout {
    
    typealias DataSource = UICollectionViewDiffableDataSource<HomeCollectionViewSections, AnyHashable>
    
    // Categories section layout
    private func makeCategoryLayoutSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .estimated(100),
                                          heightDimension: .absolute(45))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size,
                                                       subitems: [item])
        group.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil,
                                                          top: nil,
                                                          trailing: .fixed(5),
                                                          bottom: nil)
        return createSection(with: group,
                             scrollType: .continuous)
    }
    
    // Horizontal scroll single cell
    private func makeHorizontalScrollLayoutSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        item.contentInsets = .init(top: 0,
                                   leading: 0,
                                   bottom: 0,
                                   trailing: 10)
        let size = NSCollectionLayoutSize(widthDimension: .absolute(130),
                                          heightDimension: .absolute(190))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size,
                                                       subitem: item, count: 1)
        group.interItemSpacing = .fixed(10)
        return createSection(with: group,
                             scrollType: .continuousGroupLeadingBoundary)
    }
    
    // Horizontal scroll layout, cell with description
    private func makeBookDetailLayoutSection(numberItems: Int,
                                             environment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem.withEntireSize()
        item.contentInsets = .init(top: 0,
                                   leading: 0,
                                   bottom: 0,
                                   trailing: 30)
        let desiredWidth: CGFloat = 600
        let itemCount = environment.container.effectiveContentSize.width / desiredWidth
        let fractionWidth: CGFloat = 1 / (itemCount.rounded())
   
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(fractionWidth - 0.1),
                                          heightDimension: .absolute(290))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size,
                                                     subitem: item,
                                                     count: numberItems)
        group.interItemSpacing = .fixed(15)
        return createSection(with: group,
                             scrollType: .continuousGroupLeadingBoundary)
    }
    
    private func addHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                    heightDimension: .estimated(30))
        return NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerItemSize,
                                                           elementKind: UICollectionView.elementKindSectionHeader,
                                                           alignment: .top)
    }
    
    private func createSection(with group: NSCollectionLayoutGroup,
                               scrollType: UICollectionLayoutSectionOrthogonalScrollingBehavior) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = scrollType
        section.contentInsets = .init(top: 10,
                                      leading: 7,
                                      bottom: 40,
                                      trailing: 7)
        section.boundarySupplementaryItems = [addHeader()]
        return section
    }
}
// MARK: - Layout composer protocol
extension IphoneHomeTabLayout: HomeLayoutComposer {
    
    func setCollectionViewLayout(dataSource: DataSource) -> UICollectionViewLayout {
     
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, environement in
            let section = dataSource.snapshot().sectionIdentifiers[sectionIndex]
            switch section {
            case .categories:
                return self?.makeCategoryLayoutSection()
            case .newEntry:
                return self?.makeHorizontalScrollLayoutSection()
            case .favorites:
                return self?.makeHorizontalScrollLayoutSection()
            case .recommanding:
                return self?.makeBookDetailLayoutSection(numberItems: 3, environment: environement)
            }
        }
        return layout
    }
}
