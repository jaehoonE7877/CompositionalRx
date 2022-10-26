//
//  SearchViewController.swift
//  CompositionalRx
//
//  Created by Seo Jae Hoon on 2022/10/26.
//

import UIKit
import RxSwift
import RxCocoa
final class SearchViewController: BaseViewController {
    
    //MARK: Property, View
    let searchBar = UISearchBar(frame: .zero).then {
        $0.returnKeyType = .search
    }
    
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout.init()).then {
        //$0.delegate = self
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var dataSource: DataSource!
    private typealias DataSource = UICollectionViewDiffableDataSource<Int, SearchResult>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Int, SearchResult>
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.collectionViewLayout = configureCellLayout()
        configureDataSource()
        setBinding()
    }
    
    override func setConstraints() {
        [searchBar, collectionView].forEach { view.addSubview($0) }
        
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(44)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func setBinding() {
        
        viewModel.photoList
            .withUnretained(self)
            .subscribe { vc, photo in
                var snapshot = Snapshot()
                snapshot.appendSections([0])
                snapshot.appendItems(photo.results)
                vc.dataSource.apply(snapshot)
            } onError: { error in
                print("=====\(error)")
            } onCompleted: {
                print("=====onCompleted")
            } onDisposed: {
                print("=====onDisposed")
            }
            .disposed(by: disposeBag)
        
        searchBar
            .rx
            .text
            .orEmpty
            .debounce(.seconds(1), scheduler: MainScheduler.instance )
            .distinctUntilChanged()
            .withUnretained(self)
            .bind { vc, text in
                vc.viewModel.requestSearchPhoto(query: text)
            }
            .disposed(by: disposeBag)
    }
    
}

extension SearchViewController {
    
    private func configureCellLayout() -> UICollectionViewLayout {
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        
        return layout
    }
    
    private func configureDataSource() {
        
        let cellRegisteration = UICollectionView.CellRegistration<UICollectionViewListCell,SearchResult>(handler: { cell, indexPath, itemIdentifier in
            
            var content = UIListContentConfiguration.valueCell()
            content.text = "\(itemIdentifier.likes)"
            
            //String >> URL >> Data >> Image
            DispatchQueue.global().async {
                let url = URL(string: itemIdentifier.urls.thumb)!
                let data = try? Data(contentsOf: url)
                
                DispatchQueue.main.async {
                    content.image = UIImage(data: data!)
                    cell.contentConfiguration = content
                }
                
            }
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.strokeWidth = 2
            background.strokeColor = .systemPink
            cell.backgroundConfiguration = background
            
        })
        
        //collectionView.dataSource = self와 같은 맥락 => numberOfItemsInSection, cellForItemAt 메서드를 대신함
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegisteration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
    }
}
