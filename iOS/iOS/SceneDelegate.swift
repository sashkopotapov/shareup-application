import Core
import UIKit
import Views

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var root: UIViewController?

    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        let root = ScoresViewController(
            scoresPublisher: Backend.test
                .typeErasedGetAllScores
        )
        self.root = root
        window.backgroundColor = .black
        window.rootViewController = root
        window.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {}
    func sceneDidBecomeActive(_: UIScene) {}
    func sceneWillResignActive(_: UIScene) {}
    func sceneWillEnterForeground(_: UIScene) {}
    func sceneDidEnterBackground(_: UIScene) {}
}
