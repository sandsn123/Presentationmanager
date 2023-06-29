# Presentationmanager
Custom modal presentation for UIKit & SwiftUI


## Installation

### [Swift Package Manager (SPM)](https://github.com/ashleymills/Reachability.swift#swift-package-manager-spm)

1. File -> Swift Packages -> Add Package Dependency...
2. Enter package URL : https://github.com/sandsn123/Presentationmanager.git, choose the latest release

## Usage

```swift
// <your swiftui view>
.lspresent(isPresented: $isPresented, presentationManager: .init(direction: .center, 			presentationSize: PresentationSize())) {
			// presented view
}
```
