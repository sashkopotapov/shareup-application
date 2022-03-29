import UIKit

public extension UIViewController {
    func addConstrainedChildViewController(
        _ childController: UIViewController,
        insets: UIEdgeInsets = .zero,
        edges: UIRectEdge = .all,
        priority: UILayoutPriority = .required
    ) {
        addChild(childController)
        view.addConstrainedSubview(
            childController.view,
            insets: insets,
            edges: edges,
            priority: priority
        )
        childController.didMove(toParent: self)
    }

    func addChildViewController(_ childController: UIViewController) {
        addChild(childController)
        view.addSubview(childController.view)
        childController.didMove(toParent: self)
    }

    func removeFromParentViewController() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
