import Core
import UIKit

final class ScoreView: UIView {
    
    private let score: Score
    private lazy var stackView: UIStackView = makeStackView()
    
    init(score: Score) {
        self.score = score
        super.init(frame: .zero)
        addConstrainedSubview(
            stackView,
            insets: .init(top: 8, left: 16, bottom: 8, right: 16),
            edges: .all
        )
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ScoreView {
    func makeStackView() -> UIStackView {
        let scores = score.tries.map({ result(for: $0, word: score.word) })
        let rows = scores.map(makeRowStackView(for:))
        let emptyRows = (0..<(6 - scores.count)).map({ _ in makeEmptyRowStackView() })
        let stackView = UIStackView(arrangedSubviews: rows + emptyRows)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    func makeRowStackView(for results: [LetterResult]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: results.map(makeResultView(for:)))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }
    
    func makeResultView(for result: LetterResult) -> UIView {
        let view = UILabel()
        switch result {
            case .correct:
                view.text = "🟩"
            case .wrongPosition:
                view.text = "🟨"
            case .wrong:
                view.text = "⬛"
        }
        return view
    }
    
    func makeEmptyRowStackView() -> UIStackView {
        let views: [UIView] = (0...5).map({ _ in
            let label = UILabel()
            label.text = " "
            return label
        })
        
        return UIStackView(arrangedSubviews: views)
    }
}

#if DEBUG

import SwiftUI

struct ScoreView_Preview: PreviewProvider {
    static var previews: some View {
        GridView().previewLayout(.fixed(width: 150, height: 150))
    }
}

private struct GridView: UIViewRepresentable {
    func makeUIView(context _: Context) -> ScoreView {
        ScoreView(score: .init(
            id: 1,
            date: .init(year: 2022, month: 3, day: 27),
            word: "nymph",
            tries: ["train", "ponds", "blume", "nymph"]
        ))
    }
    
    func updateUIView(_: ScoreView, context _: Context) {}
}

#endif

