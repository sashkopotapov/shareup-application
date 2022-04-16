import Combine
import Core
import OrderedCollections
import UIKit

private enum Section {
    case scores
}

public class ScoresViewController: UIViewController {
    private let scoresPublisher: AnyPublisher<[Score], Error>
    private var scores = ScoresCollection()
    private var addAction: (Score) -> Void
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collectionView: UICollectionView = makeCollectionView()
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Int> = makeDataSource()
    private lazy var addButton: UIBarButtonItem = makeAddButton()
    
    private var didApplyInitialSnapshot = false
    
    public init(scoresPublisher: AnyPublisher<[Score], Error>, addAction: @escaping (Score) -> Void) {
        self.scoresPublisher = scoresPublisher
        self.addAction = addAction
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = "Wordle"
        navigationItem.rightBarButtonItem = addButton
        
        view.addConstrainedSubview(collectionView)
        scoresPublisher
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: onReceiveScores)
            .store(in: &cancellables)
    }
    
    func presentAlertController() {
        let alertController = UIAlertController(title: "Add result", message: "Add today`s Wordle result.", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: {
            $0.placeholder = "word"
        })
        
        alertController.addTextField(configurationHandler: {
            $0.placeholder = "tries,guesses,other"
        })
        
        alertController.addAction(.init(title: "Add", style: .default, handler: { [weak alertController, weak self] _ in
            guard let word = alertController?.textFields?[0].text,
                  let tries = alertController?.textFields?[1].text else { return }
            let wordPrepared = word.replacingOccurrences(of: " ", with: "")
            let triesArray =  tries.replacingOccurrences(of: " ", with: "").components(separatedBy: ",")
            
            guard wordPrepared.count == 5, triesArray.count > 0, triesArray.count <= 6, triesArray.filter({ $0.count != 5 }).isEmpty  else { return }
            
            let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
            guard let year = components.year, let month = components.month, let day = components.day else { return }
            
            let dayDate = DayDate(year: year, month: month, day: day)
            self?.addAction(Score(id: wordleNumberFromDate(dayDate: dayDate)!, date: dayDate, word: wordPrepared, tries: triesArray))
        }))
        
        present(alertController, animated: true)
    }
}

private extension ScoresViewController {
    func makeCollectionView() -> UICollectionView {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(210))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(5)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }
    
    func makeDataSource() -> UICollectionViewDiffableDataSource<Section, Int> {
        let cellRegistration = UICollectionView.CellRegistration<ScoreCell, Score>
        { cell, _, score in cell.score = score }
        
        return UICollectionViewDiffableDataSource<Section, Int>(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, itemIdentifier in
            let score: Score? = self?.scores[itemIdentifier]
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: score
            )
        }
    }
    
    func makeAddButton() -> UIBarButtonItem {
        let button = UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { [weak self] _ in
            self?.presentAlertController()
        }), menu: nil)
        
        return button
    }
    
    var onReceiveScores: ([Score]) -> Void {
        { [weak self] (scores: [Score]) in
            guard let self = self else { return }
            let animate = self.didApplyInitialSnapshot
            self.didApplyInitialSnapshot = true
            self.scores = ScoresCollection(scores)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
            snapshot.appendSections([.scores])
            snapshot.appendItems(scores.map(\.id))
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
}

#if DEBUG

import SwiftUI

struct ScoresView_Preview: PreviewProvider {
    static var previews: some View {
        ScoresView()
    }
}

struct ScoresView: UIViewControllerRepresentable {
    func makeUIViewController(context _: Context) -> some UIViewController {
        ScoresViewController(scoresPublisher: Backend.test.typeErasedGetAllScores, addAction: {_ in })
    }
    
    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

#endif
