//
//  ResultView.swift
//  
//
//  Created by Oleksandr Potapov on 29.03.2022.
//

import Core
import UIKit

final class ResultView: UIView {
    
    private let result: LetterResult
    private let letter: Character
    private lazy var label: UILabel = makeLabel()
    private lazy var resultView: UIView = makeView()
    
    init(result: LetterResult, letter: Character) {
        self.result = result
        self.letter = letter
        super.init(frame: .zero)
        addConstrainedSubview(resultView)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ResultView {
    func showLetter() {
        label.isHidden = false
    }
    
    func hideLetter() {
        label.isHidden = true
    }
}

private extension ResultView {
    func makeView() -> UIView {
        let view = UIView()
        view.addConstrainedSubview(makeBackgroundView(), insets: .init(top: 1, left: 1, bottom: 1, right: 1))
        view.addConstrainedSubview(label)
        return view
    }
    
    func makeBackgroundView() -> UIView {
        let label = UILabel()
        switch result {
        case .correct: label.text = "🟩"
        case .wrongPosition: label.text = "🟨"
        case .wrong: label.text = "⬛"
        }
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }
    
    func makeLabel() -> UILabel {
        let label = UILabel()
        label.text = String(letter)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.isHidden = true
        return label
    }
}

#if DEBUG

import SwiftUI

struct ResultView_Preview: PreviewProvider {
    static var previews: some View {
        LetterView().previewLayout(.fixed(width: 30, height: 30))
    }
}

private struct LetterView: UIViewRepresentable {
    func makeUIView(context _: Context) -> ResultView {
        ResultView(result: .correct, letter: "A")
    }
    
    func updateUIView(_: ResultView, context _: Context) {}
}

#endif

