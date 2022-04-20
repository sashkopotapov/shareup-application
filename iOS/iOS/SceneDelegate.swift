import Core
import UIKit
import Views
import Combine

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var root: UIViewController?
    private var cancellables = Set<AnyCancellable>()
    
    func scene(
        _ scene: UIScene,
        willConnectTo _: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) {
        guard let scene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        
        let backend = Backend.test //live(accessToken: "SASHKO-POTAPOV-7B591EF")
        let scoresSubject = CurrentValueSubject<[Score], Error>([])
        let scoresPublisher = scoresSubject
            .map({ $0.sorted(by: \.id) })
            .eraseToAnyPublisher()
        
        backend.typeErasedGetAllScores
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion { scoresSubject.send(completion: .failure(error)) }
            }, receiveValue: {
                scoresSubject.value += $0
            })
            .store(in: &cancellables)
        
        let addNewScoreSubject = PassthroughSubject<Score, Never>()
        addNewScoreSubject
            .eraseToAnyPublisher()
            .flatMap(maxPublishers: .max(1), { backend.typeErasedAddNewScore($0) })
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion { scoresSubject.send(completion: .failure(error)) }
            }, receiveValue: {
                scoresSubject.value.append($0)
            })
            .store(in: &cancellables)
        
        let root = UINavigationController(rootViewController: ScoresViewController(
            scoresPublisher: scoresPublisher, addAction: { addNewScoreSubject.send($0) }
        ))
        
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


