# Development documentation
## ViewModel
TBD
## Coordinator
Coordinators are responsible for routing between different views, such as pushing a view to the navigation stack or presenting a modal view or a cover view. There are three things that coordinators have to do:


1. Create views.
2. Perform push/present behaviours.
3. Maintain the state of the navigation stack.

#### Create views
Each view should be clean and only present UI and data. The business logic is stored in the ViewModel, and the routing is performed by coordinators.

To separate the UI and the business logic, a view model is initialized by a coordinator and then injected into the created views. Additionally, the FlowState is used to bind user actions from the UI to the coordinator.

```swift=
struct CreateConfigurationCoordinator: View {

    @StateObject var state: CreateConfigFlowState
    private let viewModel: CreateConfigurationViewModel = .init()

    var body: some View {
        CreateConfigurationView(flowState: state, viewModel: viewModel)
    }
}
```
To route to this coordinator, just create this coordinator like this:
```swift
    var body: some View {
        CreateConfigurationCoordinator()
    }
```

#### Perform push/present behaviours
Push and present behaviours are triggered by a `FlowState`, such as:
```swift=
class CreateConfigFlowState: ObservableObject {
    // 1
    @Binding var path: NavigationPath 
    // 2
    @Published var presentedItem: CreateConfigFlowLink? 
    @Published var coverItem: CreateConfigFlowLink?
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
    
    // 3
    static var mock: CreateConfigFlowState {
        CreateConfigFlowState(path: .constant(.init()))
    }
}

// 4 & 5
enum CreateConfigFlowLink: Hashable & Identifiable {
    case FlowLinkA
    case FlowLinkB(String) //parameter

    var id: String { String(describing: self) }
}
```

1. If this coordinator might be contained in a navigation stack, it should have a NavigationPath with the `@Binding` property wrapper. This NavigationPath needs to be injected from its parent coordinator so that the NavigationView which store in the parent can be notified when the path is changed.
```swift
// parent coordinator
NavigationStack(path: $state.path) {
    //views
}
```
2. `presentedItem` and `coverItem` represent modal and full-screen views, respectively. These are represented as an enum so that when the coordinator is notified of presenting a view, it can identify which view will be shown based on the enum value.

3. You can create a `mock` coordinator variable for testing and SwiftUI preview.
4. Declare an enum for FlowLink, which defines different routes based on users' actions. In this case, there are two actions `FlowLinkA` and `FlowLinkB`. You can define paremeters by using associated values.
5. FlowLink conforms to `Hashable` and `Identifiable` protocols to enable its usage in NavigationPath.

With a FlowState, a coordinator can perform a push/present action with the following code:
```swift=
struct CreateConfigurationCoordinator: View {
    NavigationStack(path: $state.path) {
        CreateConfigurationView(flowState: state, viewModel: viewModel)
            .navigationDestination(for: CreateConfigFlowLink.self, destination: navigationDestination)
            .sheet(item: $state.presentedItem, content: presentContent)
            .fullScreenCover(item: $state.coverItem, content: coverContent)
    }
}

private extension CreateConfigurationCoordinator {
    @ViewBuilder
    private func navigationDestination(link: CreateConfigFlowLink) -> some View {
        switch link {
        case let .FlowLinkB(parameter):
            //some view
        default:
            Text("not implemented process")
        }
    }
    
    @ViewBuilder
    private func presentContent(item: CreateConfigFlowLink) -> some View {
        switch item {
        case .FlowLinkA:
           //some view
        default:
            Text("undefined present content")
        }
    }

    @ViewBuilder
    private func coverContent(item: CreateConfigFlowLink) -> some View {
        //some view
    }
}

```


#### Maintain the state of the navigation stack.

The NavigationPath instance is initialised by the coordinator who owns the NavigationStack. It passes the path into child coordinator to make children can push/pop views.


- Parent
```swift
@ObservedObject var state: RootFlowState = .init()
    
var body: some View {
NavigationStack(path: $state.path) {
    RootView(flowState: state)
        .navigationDestination(for: RootFlowLink.self, destination: navigationDestination)
}
```
- Children
```swift
class ChildFlowState: ObservableObject {
    @Binding var path: NavigationPath
    
    init(path: Binding<NavigationPath>) {
        _path = .init(projectedValue: path)
    }
}

struct ChildCoordinator: View {
    
    @StateObject var state: ChildFlowState
    
    init(navigationPath: Binding<NavigationPath>) {
        _state = .init(wrappedValue: .init(path: navigationPath))
    }
}
```
To push a new view, child coordinator can append a new FlowLink into the NavigationPath:
```swift
state.path.append(ChildFlowLink.someLink)
```

Put them together, the architecture with coordinators can be described by the following diagram:
![](https://hackmd.io/_uploads/BkDy3-vd3.png)



> *I used these articles as references to construct this coordinator structure.* 👇
> - [SwiftUI Flow Coordinator pattern to coordinate navigation between views](https://medium.com/macoclock/swiftui-flow-coordinator-pattern-to-coordinate-navigation-between-views-8fa6ac487585)
> - [SwiftUI Flow Coordinator pattern with NavigationStack to coordinate navigation between views (iOS 16 +)](https://medium.com/macoclock/swiftui-flow-coordinator-pattern-with-navigationstack-to-coordinate-navigation-between-views-ios-1a2b6cd239d7)
> 