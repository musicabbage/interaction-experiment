# Development documentation

## Install instructions

Apple has strict rules for installing apps on real devices. Basically, everyone should download apps from the App Store so that they can get commissions from developers. A valid IPA([iOS App Store package](https://en.wikipedia.org/wiki/.ipa)) which can run on devices should contain a valid certification authenticated by Apple. The certification is generated from Apple and signed with an Apple ID.

To create a valid IPA, we need an Apple ID. By logging in to the account using Xcode, the source code can be compiled along with the certification downloaded from Apple. Once this is done, the API can be authorized by Apple and installed on devices.

# ![](https://hackmd.io/_uploads/BJZ4RzXWp.png)
![overall_diagram](https://github.com/musicabbage/interaction-experiment/assets/8994570/90e4b1b8-4f31-45e6-9949-fad70594b1c7)

### What you need?
- Devices
    - Mac
    - iPad

- Software
    - [Apple ID](https://appleid.apple.com/)
    - Xcode
        - macOS Ventura 13.5 or higher version: [Xcode v15](https://developer.apple.com/xcode/)
        - Before macOS Ventura 13.5: [Xcode v14.3.1.zip](https://download.developer.apple.com/Developer_Tools/Xcode_14.3.1/Xcode_14.3.1.xip)
        - Minimum requirements and supported SDKs: https://developer.apple.com/support/xcode/
        - All Xcode downloads page: https://developer.apple.com/download/all/?q=xcode
- Source code
    - https://github.com/musicabbage/interaction-experiment

### Setup Xcode
> With Xcode v15

**Step 1.** Log in with your Apple ID on Xcode

Open Xcode, press `Command` + `,` to open Xcode Settings. `Setting > Accounts > ➕ ` 

![](https://hackmd.io/_uploads/rkMin4xWT.png)
<img width="942" alt="1_setup_xcode_1_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/9b63cb5f-4a28-4268-8f44-e67b64fa31c3">

Choose `Apple ID`

![](https://hackmd.io/_uploads/SJS8RExW6.png)
<img width="942" alt="1_setup_xcode_1_2" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/0d72edae-0919-435b-b2f4-3ddece331520">


Then log in with your Apple ID.

Your account should appear in the list after successfully logging in with your Apple ID.

![](https://hackmd.io/_uploads/H183JBeWT.png)
<img width="942" alt="1_setup_xcode_1_3" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/e81c5512-ebe6-4e4e-b48d-80d8bbd66d5b">


**Step 2.** Download the source code at https://github.com/musicabbage/interaction-experiment. The latest version is [v1.1](https://github.com/musicabbage/interaction-experiment/releases/tag/v1.1)

**Step 3.** Setup signing

Select the project file > Choose `InteractExperiment` in the TARGETS list, > Select `Signing & Capabilities` > Expand the `Signing` section

![](https://hackmd.io/_uploads/SJ7YSBxbT.png)
<img width="1072" alt="1_setup_xcode_2_2" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/a5d08b27-d92d-4d7f-beac-09c04eaf95f5">

Check `Automatically manage signing` ✅ and select the team related to the Apple ID you just logged in to.

![](https://hackmd.io/_uploads/B1DUHHxZp.png)
<img width="1072" alt="1_setup_xcode_2_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/ae20c0d9-8f7e-4144-b824-459e5623d21c">

If everything is set, you should see the `Signing` setting like this:

![](https://hackmd.io/_uploads/H1tyDBgbp.png)
<img width="1011" alt="1_setup_xcode_2_3" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/460e4d2d-9def-4865-a27d-628bded326d9">

**Trouble shooting:**

![](https://hackmd.io/_uploads/B1KNcHgb6.png)
<img width="1032" alt="1_setup_xcode_2_ts" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/d26dbabc-faa4-4f95-bea0-d01877240add">

If you see the error in the `Signing Certificate` field with the following message: 

> Failed to register bundle identifier
> 
> The app identifier "ac.sussex.InteractExperiment" cannot be registered to your development team because it is not available. Change your bundle identifier to a unique string to try again.

Which means others used this ID. (The Bundle Identifier must be unique across **ALL app IDs worldwide**.) Therefore, change the `Bundle Identifier` to another unique id, ex: *ac.{your_sussex_id}.InteractExperiment*.

**Step 4.** Ensure iOS SDK is downloaded.

![](https://hackmd.io/_uploads/SkGE-fzW6.png)
<img width="1401" alt="1_setup_xcode_2_4" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/ab655e51-dbcd-47f9-aa00-615915d0bc57">

### Setup the iPad
**Step1.** Enable **Developer Mode**. Open your iPad Settings.

Select `Privacy & Security`. In the SECURITY sections, tap `Developer Mode`.

![](https://hackmd.io/_uploads/ByApCSe-6.jpg)
![2_setup_ipad_1_1](https://github.com/musicabbage/interaction-experiment/assets/8994570/a081fd5b-7386-4d80-9d50-df8a1b46d770)

Switch on `Developer Mode`

![](https://hackmd.io/_uploads/ryDC0Slba.png)
![2_setup_ipad_1_2](https://github.com/musicabbage/interaction-experiment/assets/8994570/18144b9f-0c6a-4df4-ba69-9ca3e7c6564a)

You will receive a warning that enabling Developer Mode will decrease your device's security and ask you to restart the iPad. Tap the Restart button to continue to open Developer Mode.

![](https://hackmd.io/_uploads/Bk4Genl-a.jpg)
![2_setup_ipad_1_3](https://github.com/musicabbage/interaction-experiment/assets/8994570/7504483e-fb66-4a13-9ca7-aab4c60296bb)

You can find Apple's official documentation on enabling Developer Mode with the following link: https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device.

**Step 2.** Ensure the iPad is connected to the internet.

**Step 3.** Connect the iPad to the Mac. If it connects successfully, the device will show in the list of running target devices.

![](https://hackmd.io/_uploads/rkT7jzM-p.png)
<img width="650" alt="2_setup_ipad_3_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/67699a3e-c736-477d-bcca-72532556df49">

**Trouble shooting:**

If you can't see the iPad on the device list, please check:

1. Ensure the iPad is connected to the Mac by checking Finder's Sidebar. (The iPad would show in the Sidebar if it connect to the Mac correctly.) https://support.apple.com/en-gb/guide/mac-help/mchld88ac7da/mac
2. Ensure the iOS SDK is Downloaded.
3. Ensure Xcode supports the iOS version. https://developer.apple.com/support/xcode 

### Running the app on the iPad

**Step 1.** [Xcode] Select the running scheme `InteractExperiment`.

![](https://hackmd.io/_uploads/rJp5sfzb6.png)
<img width="1155" alt="3_running_1_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/23e01e94-e586-4534-ae12-770b5c7ef39c">

**Step 2.** [Xcode] Select the target device.

![](https://hackmd.io/_uploads/HkUTiGzZp.png)
<img width="1155" alt="3_running_2_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/354831f1-a534-4d27-a0ca-a9d795602ddb">

**Step 3.** [Xcode] Tap the run button in Xcode.

![](https://hackmd.io/_uploads/HkNQ2GMW6.png)
<img width="1156" alt="3_running_3_1" src="https://github.com/musicabbage/interaction-experiment/assets/8994570/b24e14ed-5058-40d1-8d91-dced79ee3f4e">

**Step 4.** [iPad] Trust the profile for the app on the iPad.

You need to trust the developer profile if you receive an `Untrusted Developer` alert on your iPad.

![](https://hackmd.io/_uploads/rJVNEMz-T.png)
![3_running_4_1](https://github.com/musicabbage/interaction-experiment/assets/8994570/9b1ebb2a-5aac-4c2f-9693-f3317f73dc6d)

Open iPad `Settings > General > VPN & Device Management`. 

![](https://hackmd.io/_uploads/BkhjBGzW6.png)
![3_running_4_2](https://github.com/musicabbage/interaction-experiment/assets/8994570/a0a42d7f-19fa-450f-9a3e-cd74eedca49a)

In the `DEVELOPER APP` section, tap `Apple Development: {your_Apple_ID}`.

![](https://hackmd.io/_uploads/H1b3SMzWp.png)

Trust `Apple Development: {your_Apple_ID}`.
![3_running_4_3](https://github.com/musicabbage/interaction-experiment/assets/8994570/34f9ad69-9f5c-4fef-b0b1-4ecac5c89036)

![](https://hackmd.io/_uploads/Hy_3HfMZT.jpg)
![3_running_4_4](https://github.com/musicabbage/interaction-experiment/assets/8994570/5e33b526-fa94-4640-86b2-561bd5bfacd6)

**Step 5.** [Xcode] Run the app again. (as the same with Step 3)

**That's it!!! 🎉 I hope that the app runs smoothly on your iPad.❤️**

### References:
- Running your app in Simulator or on a device:  https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device

## ViewModel
### 1. Define as protocol
### 2. Create from coordinator
### 3. Define `ViewState` to update view state.
> Such as loading / load text or images / display error message
### 4. Using `Publisher` to notify views
> To make the view model can be reuse between SwiftUI and UIKit

## Coordinator
Coordinators are responsible for routing between different views, such as pushing a view to the navigation stack or presenting a modal view or a cover view. There are three things that coordinators have to do:


1. Create views.
2. Perform push/present behaviours.
3. Maintain the state of the navigation stack.

#### Create views
Each view should be clean and only present UI and data. The business logic is stored in the ViewModel, and the routing is performed by coordinators.

To separate the UI and the business logic, a view model is initialized by a coordinator and then injected into the created views. Additionally, the FlowState is used to bind user actions from the UI to the coordinator.

```swift
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
```swift
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
```swift
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

![Coordinator](https://github.com/musicabbage/interaction-experiment/assets/8994570/06456f2c-a7c4-4c80-a79b-00c5655239b0)


> *I used these articles as references to construct this coordinator structure.* 👇
> - [SwiftUI Flow Coordinator pattern to coordinate navigation between views](https://medium.com/macoclock/swiftui-flow-coordinator-pattern-to-coordinate-navigation-between-views-8fa6ac487585)
> - [SwiftUI Flow Coordinator pattern with NavigationStack to coordinate navigation between views (iOS 16 +)](https://medium.com/macoclock/swiftui-flow-coordinator-pattern-with-navigationstack-to-coordinate-navigation-between-views-ios-1a2b6cd239d7)
> 

# Experiment Log Data
### File name
{Name} (Trial {trial number}){experiment start date}
> ex. Anonymous Participant (Trial 1) 2023-07-04 - 18-48-10.txt
```
outputFileString = InteractLog.filepath+" (Trial "+trial.getTrialnr()+") "+filedate.format(expStartDate)+".txt";
```

### Experient Data
```
Name                 :Anonymous Participant
Experiment Start     :04/07/2023 - 17:29:30
Stroke Colour        :0,0,0,255
Background Colour    :255,255,255,255
Stroke Width         :2.0
Stimulus Files       :S1.png,S2.png,S3.png,S4.png,S5.png,S6.png,S7.png,S8.png
Familiarisation File :P1.png
Input Mask File      :
Drawing Pad Size     :1260,600
Trial Number         :1
Trial Start          :04/07/2023 - 17:29:34
Trial End            :04/07/2023 - 17:29:41
```


| Field                |  | 
| -------------------- | -------- | 
| Name                 |      | 
| Experiment Start     | After inputting participant id (instruction) | 
| Stroke Colour        |      | 
| Background Colour    |      | 
| Stroke Width         |      | 
| Stimulus Files       |      | 
| Familiarisation File |      | 
| Input Mask File      |      | 
| Drawing Pad Size     |      | 
| Trial Number         |      | 
| Trial Start          | Experiment startNextTrial (InputPad init) | 
| Trial End            | KeyEvent.VK_ESCAPE (trial ended, before end message) | 



### Event Data
| Code | Callstack |
| -------- | -------- |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.data_separator_descr+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"(RETURN"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.repstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.nextstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.prevstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.hidestim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+InteractLog.endexp_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyPressed_"+kc+"("+e.getKeyChar()+":"+e.getKeyLocation()+")")`| |
|  |  |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.data_separator_descr+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"(RETURN"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.repstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.nextstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.prevstim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.hidestim_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+InteractLog.endexp_keyname+":"+e.getKeyLocation()+")")`| |
|`("0;0","KeyReleased_"+kc+"("+e.getKeyChar()+":"+e.getKeyLocation()+")")`| |
| | |
|`eventCount+";"+System.nanoTime()+";"+x2+";"+y2+";ButtonReleased"+newline;` | mouseReleased |
|`eventCount+";"+System.nanoTime()+";"+x1+";"+y1+";ButtonDown"+newline;` | mousePressed |
| | |
|`("0;0","DrawingEnabled")`| InputPane init |
|`("0;0","FamiliarisationOff_"+InteractLog.famfilename)`| InputPane removeStim (firststim) |
|`("0;0","StimulusOff_"+InteractLog.stimfilename)`| InputPane removeStim (stimpresent) |
|`("0;0","StimulusOn_"+InteractLog.stimfilename)`| InputPane showStim |
|`("0;0","FamiliarisationOn_"+InteractLog.famfilename)`| StimPanel init |
| | |


- `ButtonDown/ButtonReleased`: strokesData
    - ButtonDown:  get `x1`, `y1` 
        - mousePressed
    - ButtonReleased: add to strokesData `strokesData+= ";"+temp[1]+";"+x1+";"+y1+";"+temp[2]+";"+temp[3]+newline;`
        - mouseReleased
```
temp = {String[5]@3809} ["6", "24912044833416", "373", "175", "ButtonDown"]
 0 = "6"
 1 = "24912044833416"
 2 = "373" //x1
 3 = "175" //y1
 4 = "ButtonDown"
 
["7", "24913597758916", "326", "366", "ButtonReleased"]
```
- `KeyReleased`: keyData


InputPad line.170
```
if(kc == KeyEvent.VK_ESCAPE || (e.isControlDown() && kc == KeyEvent.VK_ENTER)) {
			if(writeFile()) ex.endTrial();
		}
```
