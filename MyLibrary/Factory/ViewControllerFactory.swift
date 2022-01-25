//
//  ViewControllerFactory.swift
//  MyLibrary
//
//  Created by Birkyboy on 20/01/2022.
//
import UIKit

class ViewControllerFactory {
    // MARK: Services
    private let libraryService = LibraryService()
    private let userService = UserService()
    private let categoryService = CategoryService()
    private let imageStorageService = ImageStorageService()
    private let recommendationService = RecommandationService()
    private let queryService = QueryService()
    private let commentService = CommentService()
    private let feedbackManager = FeedbackManager()
    private let validation = Validator()
    private let formatter = Formatter()
    private let converter = Converter()
    private let categoryFormatter = CategoriesFormatter()
    
    private lazy var apiManager = ApiManager(session: .default, validator: validation)
    private lazy var accountService = AccountService(userService: userService,
                                                     libraryService: libraryService,
                                                     categoryService: categoryService)
    private lazy var messageService = MessageService(apiManager: apiManager)
    
    // MARK: Presenters
    private lazy var welcomeAccountPresenter = SetupAccountPresenter(accountService: accountService,
                                                                     validation: validation)
    private lazy var categoryPresenter = CategoryPresenter(categoryService: categoryService)
    private lazy var libraryPresenter = LibraryPresenter(libraryService: libraryService)
    private lazy var accountTabPresenter = AccountTabPresenter(userService: userService,
                                                               imageService: imageStorageService,
                                                               accountService: accountService)
    private lazy var homePresenter = HomePresenter(libraryService: libraryService,
                                                   categoryService: categoryService,
                                                   recommendationService: recommendationService)
    private lazy var commentPresenter = CommentPresenter(commentService: commentService,
                                                         messageService: messageService,
                                                         formatter: formatter)
    private lazy var bookCardPresenter = BookCardPresenter(libraryService: libraryService,
                                                           recommendationService: recommendationService,
                                                           categoryService: categoryService,
                                                           formatter: formatter,
                                                           categoryFormatter: categoryFormatter)
    private lazy var newCategoryPresenter = NewCategoryPresenter(categoryService: categoryService)
    private lazy var newBookPresenter = NewBookPresenter(libraryService: libraryService,
                                                         formatter: formatter,
                                                         converter: converter,
                                                         validator: validation)
    
    // MARK: Layout
    private let bookListLayout = BookListLayout()
    private let homeTabLayout = HomeTabLayout()
    
    private func makeResultViewController() -> SearchViewController {
        SearchViewController(presenter: SearchPresenter(apiManager: apiManager),
                             layoutComposer: bookListLayout)
    }
}

// MARK: - Factory
extension ViewControllerFactory: Factory {
    
    func makeHomeTabVC() -> UIViewController {
        return  HomeViewController(presenter: homePresenter,
                                   layoutComposer: homeTabLayout)
    }
    
    func makeAccountTabVC() -> UIViewController {
        return AccountViewController(presenter: accountTabPresenter,
                                     feedbackManager: feedbackManager)
    }
    
    func makeCategoryVC(settingCategory: Bool,
                        bookCategories: [String],
                        newBookDelegate: NewBookViewControllerDelegate?) -> UIViewController {
        return CategoriesViewController(settingBookCategory: settingCategory,
                                        selectedCategories: bookCategories,
                                        newBookDelegate: newBookDelegate,
                                        categoryPresenter: categoryPresenter)
    }
    
    func makeNewCategoryVC(editing: Bool, category: CategoryModel?) -> UIViewController {
        return NewCategoryViewController(editingCategory: editing,
                                         category: category,
                                         presenter: newCategoryPresenter)
    }
    
    func makeBookListVC(with query: BookQuery) -> UIViewController {
        return BookLibraryViewController(currentQuery: query,
                                         queryService: queryService,
                                         presenter: libraryPresenter,
                                         layoutComposer: bookListLayout)
    }
    
    func makeAccountSetupVC(for type: AccountInterfaceType) -> UIViewController {
        return AccountSetupViewController(presenter: welcomeAccountPresenter,
                                          interfaceType: type)
    }
    
    func makeNewBookVC(with book: Item?, isEditing: Bool, bookCardDelegate: BookCardDelegate?) -> UIViewController {
        return NewBookViewController(book: book,
                                     isEditing: isEditing,
                                     bookCardDelegate: bookCardDelegate,
                                     presenter: newBookPresenter,
                                     resultViewController: makeResultViewController())
    }
    
    func makeBookCardVC(book: Item, type: SearchType?, factory: Factory) -> UIViewController {
        return BookCardViewController(book: book,
                                      searchType: type,
                                      libraryService: libraryService,
                                      recommendationService: recommendationService,
                                      presenter: bookCardPresenter)
    }
    
    func makeBookDescriptionVC(description: String?, newBookDelegate: NewBookViewControllerDelegate?) -> UIViewController {
        return BookDescriptionViewController(bookDescription: description,
                                             newBookDelegate: newBookDelegate)
    }
    
    func makeCommentVC(with book: Item?) -> UIViewController {
        return CommentsViewController(book: book,
                                      presenter: commentPresenter,
                                      validator: validation)
    }
    
    func makeBookCoverDisplayVC(with image: UIImage) -> UIViewController {
        return BookCoverViewController(image: image)
    }
    
    func makeListVC(for dataType: ListDataType,
                    selectedData: String?,
                    newBookDelegate: NewBookViewControllerDelegate?) -> UIViewController {
        let presenter = ListPresenter(listDataType: dataType,
                                      formatter: formatter)
        return ListTableViewController(receivedData: selectedData,
                                       newBookDelegate: newBookDelegate,
                                       presenter: presenter)
    }
    
    func makeBarcodeScannerVC(delegate: BarcodeScannerDelegate?) -> UIViewController {
        return BarcodeScanViewController(barcodeDelegate: delegate)
    }
}
