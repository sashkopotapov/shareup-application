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
    var tries: String
    var finalScore: Score?
    
    var dateColor: UIColor = .label
    var triesColor: UIColor = .secondaryLabel

    init(score: Score? = nil) {
        guard let score = score else {
            date = ""
            tries = ""
            finalScore = nil
            return
        }

        date = score.date.stringValue
        tries = "\(score.tries.count) tries"
        finalScore = score
    }

    func makeContentView() -> UIView & UIContentView {
        ScoreContentView(configuration: self)
    }

    func updated(for state: UIConfigurationState) -> Self {
        guard let state = state as? UICellConfigurationState else { return self }
        var updated = self
        if state.isSelected {
            updated.dateColor = .label
            updated.triesColor = .label
        } else {
            updated.dateColor = .label
            updated.triesColor = .secondaryLabel
        }
        return updated
    }
}

private class ScoreContentView: UIView, UIContentView {
    private var _configuration: ScoreContentConfiguration
    var configuration: UIContentConfiguration {
        get { _configuration }
        set {
            guard let config = newValue as? ScoreContentConfiguration
            else { return }
            _configuration = config
            apply(configuration: config)
        }
    }

    private lazy var stackView: UIStackView = makeStackView()
    private lazy var dateLabel: UILabel = makeDateLabel()
    private lazy var triesLabel: UILabel = makeTriesLabel()
    
    private lazy var scoreView: UIView = makeScoreView()

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
        dateLabel.textColor = configuration.dateColor
        triesLabel.text = configuration.tries
        triesLabel.textColor = configuration.triesColor
    }

    func makeStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [dateLabel, scoreView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentCompressionResistancePriority(.required, for: .vertical)
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        return stackView
    }

    func makeDateLabel() -> UILabel {
        let label = makeLabel()
        label.font = UIFont.preferredFont(forTextStyle: .title3)
        label.textColor = .label
        return label
    }

    func makeTriesLabel() -> UILabel {
        let label = makeLabel()
        label.font = UIFont.preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        return label
    }
    
    func makeScoreView() -> UIView {
        guard var score = _configuration.finalScore else { return UIView() }
        let view = ScoreView(word: score.word, tries: score.tries)
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
            CellView().previewLayout(.fixed(width: 180, height: 180))
        }
    }

    private struct CellView: UIViewRepresentable {
        func makeUIView(context _: Context) -> ScoreContentView {
            ScoreContentView(configuration: .init(score: .init(
                id: 1,
                date: .init(year: 2022, month: 3, day: 27),
                word: "nymph",
                tries: ["train", "ponds", "blume", "nymph"]
            )))
        }

        func updateUIView(_: ScoreContentView, context _: Context) {}
    }
#endif
