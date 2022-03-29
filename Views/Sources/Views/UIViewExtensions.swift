import UIKit

public extension UIView {
    func addConstrainedSubview(
        _ view: UIView,
        insets: UIEdgeInsets = .zero,
        edges: UIRectEdge = .all,
        priority: UILayoutPriority = .required
    ) {
        view.translatesAutoresizingMaskIntoConstraints = false

        addSubview(view)

        if edges.contains(.left) {
            let constraint = view.leadingAnchor
                .constraint(equalTo: leadingAnchor, constant: insets.left)
            constraint
                .identifier = "\(type(of: view)).leading == \(type(of: self)).leading"
            constraint.priority = priority
            constraint.isActive = true
        }

        if edges.contains(.right) {
            let constraint = view.trailingAnchor
                .constraint(equalTo: trailingAnchor, constant: -insets.right)
            constraint
                .identifier = "\(type(of: view)).trailing == \(type(of: self)).trailing"
            constraint.priority = priority
            constraint.isActive = true
        }

        if edges.contains(.top) {
            let constraint = view.topAnchor
                .constraint(equalTo: topAnchor, constant: insets.top)
            constraint.identifier = "\(type(of: view)).top == \(type(of: self)).top"
            constraint.priority = priority
            constraint.isActive = true
        }

        if edges.contains(.bottom) {
            let constraint = view.bottomAnchor
                .constraint(equalTo: bottomAnchor, constant: -insets.bottom)
            constraint.identifier = "\(type(of: view)).bottom == \(type(of: self)).bottom"
            constraint.priority = priority
            constraint.isActive = true
        }
    }
}
