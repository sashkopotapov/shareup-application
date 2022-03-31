import Core
import UIKit

final class ScoreView: UIView {
    
    private let word: String
    private let tries: [String]
    private lazy var resultViews: [UIView] = makeResultViews()
    private lazy var stackView: UIStackView = makeStackView()
    private lazy var animators: [UIViewPropertyAnimator] = makeAnimators()
    
    private let animationFlipTime: CGFloat = 0.2
    
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
        for (index, row) in resultViews.enumerated() where row is UIStackView {
            guard let rowStack = row as? UIStackView else { return }
            
            let animator = animators[index]
            setAnimatorToInactiveState(animator)
            
            animator.addAnimations({
                for view in rowStack.arrangedSubviews where view is ResultView {
                    view.layer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(180 * Double.pi / 180), 1, 0, 0)
                }
            })
            
            animator.addCompletion({ position in
                guard index <= rowStack.arrangedSubviews.count, position == .end else { return }
                for view in rowStack.arrangedSubviews where view is ResultView {
                    view.layer.transform = CATransform3DIdentity
                    (view as? ResultView)?.showLetter()
                }
            })
            
            animator.startAnimation(afterDelay: animationFlipTime * Double(index))
        }
    }
    
    func hideWord() {
        for (index, row) in resultViews.enumerated() where row is UIStackView {
            guard let rowStack = row as? UIStackView else { return }
            setAnimatorToInactiveState(animators[index])
            for view in rowStack.arrangedSubviews where view is ResultView {
                view.layer.transform = CATransform3DIdentity
                (view as? ResultView)?.hideLetter()
            }
        }
    }
}

private extension ScoreView {
    func setAnimatorToInactiveState(_ animator: UIViewPropertyAnimator) {
        if animator.state == .active { animator.stopAnimation(false) }
        if animator.state == .stopped { animator.finishAnimation(at: .start) }
    }
    
    func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: resultViews)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.spacing = 5
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
        label.backgroundColor = .clear
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    func makeAnimators() -> [UIViewPropertyAnimator] {
        return (0..<6).map({ _ in UIViewPropertyAnimator(duration: 0.2, curve: .linear) })
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

