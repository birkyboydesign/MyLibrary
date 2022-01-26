//
//  CommentsViewController.swift
//  MyLibrary
//
//  Created by Birkyboy on 28/11/2021.
//

import UIKit
import InputBarAccessoryView
import IQKeyboardManagerSwift
import FirebaseAuth

class CommentsViewController: UIViewController {
    
    // MARK: - Properties
    typealias Snapshot = NSDiffableDataSourceSnapshot<CommentsSection, AnyHashable>
  
    private let mainView = CommentControllerView()
    private let keyboardManager = KeyboardManager()
    private let validator: ValidatorProtocol
    private let presenter: CommentPresenter
    
    private lazy var dataSource = makeDataSource()
    private var book: Item?
    
    // MARK: - Initializer
    init(book: Item?,
         presenter: CommentPresenter,
         validator: ValidatorProtocol) {
        self.book = book
        self.presenter = presenter
        self.validator = validator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        view = mainView
        view.backgroundColor = .viewControllerBackgroundColor
        title = Text.ControllerTitle.comments
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.view = self
        presenter.book = book
        IQKeyboardManager.shared.enableAutoToolbar = false
        mainView.tableView.dataSource = dataSource
        configureKeyboard()
        setDelegates()
        setTargets()
        addNavigationBarButtons()
        applySnapshot(animatingDifferences: false)
        presenter.getBookDetails()
        presenter.getComments()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    // MARK: - Setup
    private func addNavigationBarButtons() {
        let activityIndicactorButton = UIBarButtonItem(customView: mainView.activityIndicator)
        navigationItem.rightBarButtonItems = [activityIndicactorButton]
    }
    
    private func setTargets() {
        mainView.refresherControl.addAction(UIAction(handler: { [weak self] _ in
            self?.presenter.getComments()
        }), for: .valueChanged)
    }
    
    private func setDelegates() {
        mainView.emptyStateView.delegate = self
        mainView.inputBar.delegate = self
        mainView.tableView.delegate = self
    }
    
    private func configureKeyboard() {
        IQKeyboardManager.shared.enable = false
        keyboardManager.bind(inputAccessoryView: mainView.inputBar)
        keyboardManager.bind(to: mainView.tableView)
    }
}
// MARK: - TableView Delegate
extension CommentsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = dataSource.snapshot().sectionIdentifiers[indexPath.section]
        switch section {
        case .book:
            return 150
        case .today, .past:
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let section = dataSource.snapshot().sectionIdentifiers[section]
        let numberOfItemsInsection = dataSource.snapshot().numberOfItems(inSection: section)
        
        let sectionTitleLabel = TextLabel(color: .secondaryLabel,
                                          maxLines: 1,
                                          alignment: .center,
                                          font: .lightSectionTitle)
        sectionTitleLabel.text = section.headerTitle.uppercased()
        return numberOfItemsInsection == 0 ? nil : sectionTitleLabel
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 21
    }
    
    /// Adds swipe gestures to edit or delete comment
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = self.contextMenuAction(for: .delete, forRowAtIndexPath: indexPath)
        let editAction = self.contextMenuAction(for: .edit, forRowAtIndexPath: indexPath)
        
        guard let comment = dataSource.itemIdentifier(for: indexPath) as? CommentModel else { return nil }
        let commentOwnerID = comment.userID
        let currentUserID = Auth.auth().currentUser?.uid
        return commentOwnerID == currentUserID ? UISwipeActionsConfiguration(actions: [deleteAction, editAction]) : nil
    }
    
    /// Handles swipe gesture actions
    private func contextMenuAction(for actionType: CellSwipeActionType, forRowAtIndexPath indexPath: IndexPath) -> UIContextualAction {
        guard let comment = dataSource.itemIdentifier(for: indexPath) as? CommentModel else {
            return UIContextualAction()
        }
        let action = UIContextualAction(style: .destructive, title: actionType.title) { [weak self] (_, _, completion) in
            self?.presenter.presentSwipeAction(for: comment, actionType: actionType)
            completion(true)
        }
        action.backgroundColor = actionType.color
        action.image = actionType.icon
        return action
    }
}

// MARK: - TableView Datasource
extension CommentsViewController {
    
    /// Create a data source with 3 sections
    ///  - Note: Section 1: The current book, Section 2: Today's comment, Section 3: Past comments.
    private func makeDataSource() -> CommentDataSource {
        let dataSource = CommentDataSource(tableView: mainView.tableView,
                                    cellProvider: { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            
            let section = self?.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            switch section {
            case .book:
                if let item = item as? CommentBookCellRepresentable {
                    let reuseIdentifier = CommentsBookCell.reuseIdentifier
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                                   for: indexPath) as? CommentsBookCell else {
                        return UITableViewCell()
                    }
                    cell.configure(with: item)
                    return cell
                }
            case .today, .past:
                if let item = item as? CommentModel {
                    let reuseIdentifier = CommentTableViewCell.reuseIdentifier
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                                                   for: indexPath) as? CommentTableViewCell else {
                        return UITableViewCell()
                    }
                    if let data = self?.presenter.makeCommentCellRepresentable(with: item) {
                        cell.configure(with: data)
                    }
                    return cell
                }
            case .none:
                return nil
            }
            return nil
        })
        return dataSource
    }
    
    func applySnapshot(animatingDifferences: Bool) {
        mainView.emptyStateView.isHidden = !presenter.commentList.isEmpty
        
        var snapshot = Snapshot()
        snapshot.appendSections(CommentsSection.allCases)
        snapshot.appendItems(presenter.bookCellRepresentable, toSection: .book)
        
        let todayComments = presenter.commentList.filter({ validator.isTimestampToday(for: $0.timestamp) })
        snapshot.appendItems(todayComments, toSection: .today)
        
        let pastComments = presenter.commentList.filter({ !validator.isTimestampToday(for: $0.timestamp) })
        snapshot.appendItems(pastComments, toSection: .past)
       
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
}
// MARK: - InputBar Delegate
extension CommentsViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        presenter.addComment(with: text, commentID: presenter.editedCommentID)
        mainView.inputBar.inputTextView.text = ""
        mainView.inputBar.inputTextView.resignFirstResponder()
    }
}
// MARK: - EmptystateView Delegate
extension CommentsViewController: EmptyStateViewDelegate {
    func didTapButton() {
       mainView.inputBar.inputTextView.becomeFirstResponder()
    }
}
// MARK: - CommentPresenter Delegate
extension CommentsViewController: CommentsPresenterView {
    
    /// Add comment text to the input bar to edit and save the comment.
   func addCommentToInputBar(for comment: CommentModel) {
        mainView.inputBar.inputTextView.text = comment.message
        mainView.inputBar.inputTextView.becomeFirstResponder()
    }
    
    func showActivityIndicator() {
        showIndicator(self.mainView.activityIndicator)
    }
    
    func stopActivityIndicator() {
        DispatchQueue.main.async {
            self.mainView.refresherControl.endRefreshing()
            self.hideIndicator(self.mainView.activityIndicator)
        }
    }
}
