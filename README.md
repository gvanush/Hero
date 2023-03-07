# Hero

The repository for Generative, a 3d visual animated content creation tool using generative creation techniques.

## Structure

### Hero 
iOS application, with the user interface implemented using SwiftUI framework using Swift programming language.

### Spirit 
Rendering and animation engine designed with cross-platform compatibility in mind. It is utilizing [entt](https://github.com/skypjack/entt) Entity Component System library for general structure and [Metal](https://developer.apple.com/metal/) for rendering. For implementation, C++ programming language is used and for interfacing with other programming languages (so far with Swift) C API is provided.

Currenlty Spirit is embedded in Hero but will be detached to its own repository as other platforms will be supported. 

## Setup

_Requires macOS Ventura / Xcode 14_

1. Clone the repository and switch to its root folder from terminal
2. <code>git submodule update --init</code>
3. Build and run the project
