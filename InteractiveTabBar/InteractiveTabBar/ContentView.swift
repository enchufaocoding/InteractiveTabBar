//
//  ContentView.swift
//  InteractiveTabBar
//
//  Created by Jose Alberto Rosario Castillo on 26/12/24.
//

import SwiftUI

struct ContentView: View {
    @State private var activeTab: TabItem = .home
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $activeTab) {
                ForEach(TabItem.allCases, id: \.rawValue) { tab in
                    Tab.init(value: tab) {
                        Text(tab.rawValue)
                            .toolbarVisibility(.hidden, for: .tabBar)
                    }
                }
            }
            InteractiveTabBar(activeTab: $activeTab)
        }
    }
}

struct InteractiveTabBar: View {
    @Binding var activeTab: TabItem
    @Namespace private var animation
    @State private var tabButtonLocations: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    @State private var tabButtonSizes: [CGRect] = Array(repeating: .zero, count: TabItem.allCases.count)
    @State private var activeDraggingTab: TabItem?
    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabItem.allCases, id: \.rawValue) { tab in
                TabButton(tab)
            }
        }
        .frame(height: 70)
        .padding(.horizontal, 15)
        .padding(.bottom, 10)
        .background {
            Rectangle()
                .fill(.background.shadow(.drop(color: .primary.opacity(0.2), radius: 5)))
                .ignoresSafeArea()
                .padding(.top, 20)
        }
        .coordinateSpace(.named("ACTIVETAB"))
    }
    
    @ViewBuilder
    func TabButton(_ tab: TabItem) -> some View {
        let isActive = (activeDraggingTab ?? activeTab) == tab
        VStack(spacing: 6) {
            Image(systemName: tab.symbolIcons)
                .symbolVariant(.fill)
                .frame(width: isActive ? 50 : 25, height: isActive ? 50 : 25)
                .background {
                    if isActive {
                        Circle()
                            .fill(.blue.gradient)
                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                    }
                }
                .frame(width: 25, height: 25, alignment: .bottom)
                .foregroundStyle(isActive ? .white : .primary)
            Text(tab.rawValue)
                .font(.caption2)
                .foregroundStyle(isActive ? .blue : .primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .onGeometryChange(for: CGRect.self, of: { $0.frame(in: .named("ACTIVETAB"))
        }, action: { newValue in
            tabButtonLocations[tab.index] = newValue
        })
        .contentShape(.rect)
        .onTapGesture() {
            withAnimation(.snappy()) {
                activeTab = tab
            }
        }
        .gesture(
            DragGesture(coordinateSpace: .named("ACTIVETAB"))
                .onChanged { value in
                    let location = value.location
                    
                    if let index = tabButtonLocations.firstIndex(where: { $0.contains(location) }) {
                        withAnimation(.snappy(duration: 0.25, extraBounce: 0)) {
                            activeDraggingTab = TabItem.allCases[index]
                        }
                    }
                }.onEnded { _ in
                  if let activeDraggingTab {
                      activeTab = activeDraggingTab
                    }
                    activeDraggingTab = nil
                },
            isEnabled: activeTab == tab
        )
    }
}


#Preview {
    ContentView()
}

enum TabItem: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case notifications = "Notifications"
    case settings = "Settings"
    
    var symbolIcons: String {
        switch self {
        case .home: return "house"
        case .search: return "magnifyingglass"
        case .notifications: return "bell"
        case .settings: return "gearshape"
        }
    }
    
    var index: Int {
        Self.allCases.firstIndex(of: self) ?? 0
    }
}
