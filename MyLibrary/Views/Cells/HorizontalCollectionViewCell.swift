//
//  CollectionViewCell.swift
//  MyBookLibrary
//
//  Created by Birkyboy on 22/10/2021.
//

import UIKit
import AlamofireImage

class HorizontalCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "horizontalCell"
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setBookCoverViewWidth()
        setTitleStackview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
   // MARK: - Subviews
    private let bookCover = BookCover(frame: .zero)
    private let titleView = CellTitleView()
    private let descriptionLabel = TextLabel(maxLines: 4, fontSize: 13, weight: .regular)
   
    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .top
        stack.distribution = .fill
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func prepareForReuse() {
        titleView.titleLabel.text = nil
        titleView.subtitleLabel.text = nil
        descriptionLabel.text = nil
        bookCover.image = nil
    }

    func configure(with book: Item) {
        titleView.titleLabel.text = book.volumeInfo?.title
        titleView.subtitleLabel.text = book.volumeInfo?.authors?.first
        descriptionLabel.text = book.volumeInfo?.volumeInfoDescription
        if let imageUrl = book.volumeInfo?.imageLinks?.smallThumbnail, let url = URL(string: imageUrl) {
            bookCover.af.setImage(withURL: url,
                                  cacheKey: book.volumeInfo?.industryIdentifiers?.first?.identifier,
                                  placeholderImage: Images.welcomeScreen,
                                  completion: nil)
        }
    }
}
// MARK: - Constraints
extension HorizontalCollectionViewCell {
    
    private func setBookCoverViewWidth() {
        bookCover.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bookCover)
        NSLayoutConstraint.activate([
            bookCover.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookCover.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            bookCover.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookCover.widthAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.7)
        ])
    }
    
    private func setTitleStackview() {
        contentView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleView)
        textStackView.addArrangedSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            textStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 10),
            textStackView.leadingAnchor.constraint(equalTo: bookCover.trailingAnchor, constant: 10),
            textStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
