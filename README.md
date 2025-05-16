# Hearth – iOS App

**Hearth** is a native iOS application built exclusively for iPhones. It is not compatible with Android devices and must be built using [Xcode](https://developer.apple.com/xcode/).

---

## Prerequisites

- A Mac running macOS
- [Xcode](https://developer.apple.com/xcode/) (available on the App Store)
- An Apple Developer account (not required unless you want to run it on a personal device)
- An iPhone or iOS Simulator

---

## Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/hearth.git
cd hearth
```

> You can also use Xcode’s built in Git support to clone the repository.

---

### 2. Open the Project in Xcode

1. Open Xcode.
2. Select `File > Open` and navigate to the `Hearth.xcodeproj` file.

---

### 3. Install Dependencies

Firebase should install automatically via Swift Package Manager. If not:

1. Go to `File > Add Packages...`
2. Enter the following URL:
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
3. Add the following products:
   - `FirebaseFirestore`
   - `FirebaseAuth`

---

## Running Hearth in the iOS Simulator

1. In Xcode, locate the device selector at the top center of the window.
2. Choose an iPhone simulator.
3. Click the **Run** button to build and launch the app.

---

## Running on a Physical iPhone

> Make sure **Developer Mode** is enabled on your device:  
> [Apple Documentation – Enabling Developer Mode](https://developer.apple.com/documentation/xcode/enabling-developer-mode-on-a-device)

1. Ensure your iPhone is unlocked, on the same wifi network as your Mac, and has Bluetooth enabled.
2. Connect your iPhone via USB or wirelessly if configured.
3. In Xcode, select your iPhone from the device list.
4. Click the **Run** button to build and run Hearth on your device.

---
