//
//  PersistentTabContainer.swift
//  Navigation
//
//  Created by Assistant on 09/01/2025.
//

import SwiftUI
import Story
import Study
import Translation
import Subscription
import Settings
import UIKit

struct PersistentTabContainer: UIViewControllerRepresentable {
    @EnvironmentObject var store: NavigationStore
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = TabContainerViewController()
        controller.store = store
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let controller = uiViewController as? TabContainerViewController {
            controller.updateVisibleTab(store.state.contentTab)
        }
    }
}

class TabContainerViewController: UIViewController {
    var store: NavigationStore?
    private var tabControllers: [ContentTab: UIViewController] = [:]
    private var currentTab: ContentTab?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
    }
    
    func updateVisibleTab(_ tab: ContentTab) {
        guard let store = store else { return }
        
        // Create controller if not exists
        if tabControllers[tab] == nil {
            let hostingController: UIViewController
            
            switch tab {
            case .reader:
                hostingController = UIHostingController(rootView: NavigationStack {
                    StoryRootView(environment: store.environment.storyEnvironment)
                        .environmentObject(store)
                })
            case .progress:
                hostingController = UIHostingController(rootView: 
                    StudyRootView(environment: store.environment.studyEnvironment)
                        .environmentObject(store)
                )
            case .translate:
                hostingController = UIHostingController(rootView: NavigationStack {
                    TranslationRootView(environment: store.environment.translationEnvironment)
                        .environmentObject(store)
                })
            case .subscribe:
                hostingController = UIHostingController(rootView: 
                    SubscriptionRootView(environment: store.environment.subscriptionEnvironment)
                        .environmentObject(store)
                )
            case .settings:
                hostingController = UIHostingController(rootView: 
                    SettingsRootView(environment: store.environment.settingsEnvironment)
                        .environmentObject(store)
                )
            }
            
            tabControllers[tab] = hostingController
            addChild(hostingController)
            view.addSubview(hostingController.view)
            hostingController.view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
                hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            hostingController.didMove(toParent: self)
        }
        
        // Update visibility
        if currentTab != tab {
            if let previousController = currentTab.flatMap({ tabControllers[$0] }) {
                previousController.view.isHidden = true
            }
            
            tabControllers[tab]?.view.isHidden = false
            currentTab = tab
        }
    }
}
