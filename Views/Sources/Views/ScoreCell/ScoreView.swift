import Core
import UIKit

final class ScoreView: UIView {
    
    private let word: String
    private let tries: [String]
    private lazy var resultViews: [UIView] = makeResultViews()
    private lazy var stackView: UIStackView = makeStackView()
    
    init(word: String, tries: [String]) {
        self.word = word
        self.tries = tries
        super.init(frame: .zero)
        addConstrainedSubview(
            stackView,
            insets: .init(top: 0, left: 0, bottom: 0, right: 0),
            edges: .all
        )
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ScoreView {
    func showWord() {
        #warning("Do animation here")
        for stack in resultViews where stack is UIStackView {
            for view in stack.subviews where view is ResultView { (view as? ResultView)?.showLetter() }
        }
    }
    
    func hideWord() {
        #warning("Do animation here")
        for stack in resultViews where stack is UIStackView {
            for view in stack.subviews where view is ResultView { (view as? ResultView)?.hideLetter() }
        }
    }
}

private extension ScoreView {
    func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: resultViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.alignment = .top
        stackView.distribution = .fillProportionally
        return stackView
    }
    
    func makeResultViews() -> [UIView] {
        let rows = tries.map({ makeRowStackView(for: result(for: $0, word: word), letters: Array($0)) })
        let emptyRows = (0..<(6 - tries.count)).map({ _ in makeEmptyRowView() })
        return rows + emptyRows
    }
    
    func makeRowStackView(for results: [LetterResult], letters: [Character]) -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: zip(results, letters).map({ makeResultView(for: $0, letter: $1) }))
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.setContentHuggingPriority(.required, for: .vertical)
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .leading
        return stackView
    }
    
    func makeResultView(for result: LetterResult, letter: Character) -> UIView {
        let view = ResultView(result: result, letter: letter)
        return view
    }
    
    func makeEmptyRowView() -> UIView {
        let label = UILabel()
        label.text = " "
        label.backgroundColor = .orange
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        ScoreView(
            word: "nymph",
            tries: ["train", "ponds", "blume", "nymph"]
        )
    }
    
    func updateUIView(_: ScoreView, context _: Context) {}
}

#endif

