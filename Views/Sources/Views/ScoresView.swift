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
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var collectionView: UICollectionView = makeCollectionView()
    private lazy var dataSource: UICollectionViewDiffableDataSource<Section, Int> =
    makeDataSource()
    
    private var didApplyInitialSnapshot = false
    
    public init(scoresPublisher: AnyPublisher<[Score], Error>) {
        self.scoresPublisher = scoresPublisher
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.addConstrainedSubview(collectionView)
        scoresPublisher
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: onReceiveScores)
            .store(in: &cancellables)
    }
}

private extension ScoresViewController {
    func makeCollectionView() -> UICollectionView {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
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
    
    var onReceiveScores: ([Score]) -> Void {
        { [weak self] (scores: [Score]) in
            guard let self = self else { return }
            let animate = self.didApplyInitialSnapshot
            self.didApplyInitialSnapshot = true
            self.scores = ScoresCollection(scores)
            var snapshot = NSDiffableDataSourceSnapshot<Section, Int>()
            snapshot.appendSections([.scores])
            snapshot.appendItems(scores.map(\.id))
            self.dataSource.apply(snapshot, animatingDifferences: animate)
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
        ScoresViewController(scoresPublisher: Backend.test.typeErasedGetAllScores)
    }
    
    func updateUIViewController(_: UIViewControllerType, context _: Context) {}
}

#endif
