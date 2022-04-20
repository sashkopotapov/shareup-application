import Core
import UIKit

public class ScoreCell: UICollectionViewCell {
    var score: Score?

    override public func updateConfiguration(using state: UICellConfigurationState) {
        contentConfiguration = ScoreContentConfiguration(score: score).updated(for: state)
    }
}

private struct ScoreContentConfiguration: UIContentConfiguration, Hashable {
    var date: String
    var word: String
    var tries: [String]
    var attempts: String
    var isWordShown: Bool
        
    init(score: Score? = nil) {
        guard let score = score else {
            date = ""
            word = ""
            tries = []
            attempts = "Wordly 0/0"
            isWordShown = false
            return
        }

        date = score.date.stringValue
        word = score.word
        tries = score.tries
        isWordShown = false
        
        attempts = "Wordle \(score.id) \(score.tries.count)/6"
    }

    func makeContentView() -> UIView & UIContentView {
        ScoreContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updated = self
        if state.isSelected {
            updated.isWordShown = true
        } else {
            updated.isWordShown = false
        }
        return updated
    }
}

private class ScoreContentView: UIView, UIContentView {
    private var _configuration: ScoreContentConfiguration!
    var configuration: UIContentConfiguration {
        get { _configuration }
        set {
            // Had to add this distinction since it is being set twice while selection and breaks animation chain
            // TODO Investigate the reason behind it later
            guard let config = newValue as? ScoreContentConfiguration, config != _configuration
            else { return }
            _configuration = config
            apply(configuration: config)
        }
    }

    private lazy var stackView: UIStackView = makeStackView()
    private lazy var scoreLabel: UILabel = makeScoreLabel()
    private lazy var dateLabel: UILabel = makeDateLabel()
    
    private lazy var scoreView: ScoreView = makeScoreView()

    init(configuration: ScoreContentConfiguration) {
        _configuration = configuration
        super.init(frame: .zero)
        addConstrainedSubview(
            stackView,
            insets: .init(top: 8, left: 8, bottom: 8, right: 8),
            edges: .all
        )
        setContentCompressionResistancePriority(.required, for: .vertical)
        apply(configuration: configuration)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension ScoreContentView {
    func apply(configuration: ScoreContentConfiguration) {
        dateLabel.text = configuration.date
        scoreLabel.text = configuration.attempts
        configuration.isWordShown ? scoreView.showWord() : scoreView.hideWord()
    }

    func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, scoreLabel, scoreView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }

    func makeDateLabel() -> UILabel {
        let label = makeLabel()
        label.font = UIFont.preferredFont(forTextStyle: .footnote)
        label.textColor = .secondaryLabel
        return label
    }
    
    func makeScoreLabel() -> UILabel {
        let label = makeLabel()
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textColor = .label
        return label
    }

    func makeTriesLabel() -> UILabel {
        let label = makeLabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }
    
    func makeScoreView() -> ScoreView {
        let view = ScoreView(word: _configuration.word, tries: _configuration.tries)
        return view
    }

    func makeLabel() -> UILabel {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        label.allowsDefaultTighteningForTruncation = true
        label.adjustsFontForContentSizeCategory = true
        return label
    }
}

#if DEBUG

    import SwiftUI

    struct ScoreCellView_Preview: PreviewProvider {
        static var previews: some View {
            CellView().previewLayout(.fixed(width: 180, height: 210))
        }
    }

    private struct CellView: UIViewRepresentable {
        func makeUIView(context _: Context) -> ScoreContentView {
            ScoreContentView(configuration: .init(score: .init(
                id: 1,
                date: .init(year: 2022, month: 3, day: 27),
                word: "shall",
                tries: ["mouth","happy","ahead","chias", "shank", "shall"]
            )))
        }

        func updateUIView(_: ScoreContentView, context _: Context) {}
    }
#endif
