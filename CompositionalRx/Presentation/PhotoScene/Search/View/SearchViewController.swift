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
        
        let input = SearchViewModel.Input(text: searchBar.rx.text.orEmpty)
        let output = viewModel.transform(input: input)
        
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
        
        output.searchText
            .withUnretained(self)
            .bind { vc, text in
                vc.viewModel.requestSearchPhoto(query: text)
            }
            .disposed(by: disposeBag)
        
//        collectionView.rx.prefetchItems
//            .compactMap { $0.last?.item }
//            .withUnretained(self)
//            .bind { vc, item in
//                vc.viewModel.pagenationRequest(item: item, query: vc.searchBar.text!)
//            }
//            .disposed(by: disposeBag)
        
//        collectionView.rx.didScroll
//            .subscribe { [weak self] _ in
//                guard let self = self else { return }
//                let offset = self.collectionView.contentOffset.y
//                let contentHeight = self.collectionView.contentSize.height
//                
//                if offset > (contentHeight - self.collectionView.frame.size.height - 100) {
//                    self.viewModel.requestSearchPhoto(query: self.searchBar.text ?? "")
//                }
//            }
//            .disposed(by: disposeBag)
    }
    
}

extension SearchViewController {
    
    private func configureCellLayout() -> UICollectionViewLayout {
        // 제일 큰 사진
        let fullSizeItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/3)))
        fullSizeItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        // 2번째 줄 큰 사진 + 작은사진 x2
        let mainItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(2/3), heightDimension: .fractionalHeight(1.0)))
        mainItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        let pairItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.5)))
        pairItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let trailingGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)), subitem: pairItem, count: 2)
        
        let mainWithTrailingGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9)), subitems: [mainItem, trailingGroup])
        //3번째 작은 사진 x3
        let tripleItem = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1/3), heightDimension: .fractionalHeight(1.0)))
        tripleItem.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
       
        let tripleGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(2/9)), subitem: tripleItem, count: 3)
      
        
        let configuration = UICollectionViewCompositionalLayoutConfiguration()
        //4. 2번의 반대 방향
        let mainWithReversedGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(4/9)), subitems: [trailingGroup, mainItem])
        
        let nestedGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(16/9)), subitems: [fullSizeItem, mainWithTrailingGroup, tripleGroup, mainWithReversedGroup])
        
        let section = NSCollectionLayoutSection(group: nestedGroup)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func configureDataSource() {
        
        let cellRegisteration = UICollectionView.CellRegistration<SearchCollectionViewCell,SearchResult>(handler: { cell, indexPath, itemIdentifier in
            
            cell.setData(data: itemIdentifier)
            
        })
        
        //collectionView.dataSource = self와 같은 맥락 => numberOfItemsInSection, cellForItemAt 메서드를 대신함
        dataSource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegisteration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
    }
}
