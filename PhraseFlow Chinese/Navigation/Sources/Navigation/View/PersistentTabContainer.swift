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
        initializeAllTabs()
    }
    
    private func initializeAllTabs() {
        guard let store = store else { return }
        
        // Initialize all tabs at once
        let tabs: [(ContentTab, UIViewController)] = [
            (.reader, UIHostingController(rootView: NavigationStack {
                StoryRootView(environment: store.environment.storyEnvironment)
            })),
            (.progress, UIHostingController(rootView: 
                StudyRootView(environment: store.environment.studyEnvironment)
            )),
            (.translate, UIHostingController(rootView: NavigationStack {
                TranslationRootView(environment: store.environment.translationEnvironment)
            })),
            (.subscribe, UIHostingController(rootView: 
                SubscriptionRootView(environment: store.environment.subscriptionEnvironment)
            )),
            (.settings, UIHostingController(rootView: 
                SettingsRootView(environment: store.environment.settingsEnvironment)
            ))
        ]
        
        for (tab, hostingController) in tabs {
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
            hostingController.view.isHidden = true
        }
    }
    
    func updateVisibleTab(_ tab: ContentTab) {
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
