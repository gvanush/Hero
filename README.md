# Hero

The repository for Generative, a mobile-based 3d visual animated content creation tool on mobile devices using generative creation techniques.

For prototype demo please follow this Youtube [link](https://youtu.be/E0ktVodXODs)

To try the prototype on iOS (requires version 16 or higher) devices please follow this [link](https://testflight.apple.com/join/MWc3Axez)

For 3D animated content created using the prototype please follow this [link](https://www.instagram.com/g.e.n.e.r.a.t.i.v.e/)

## Structure

### Hero 
iOS application, with the user interface implemented using SwiftUI framework.

### Spirit 
Rendering and animation engine designed with cross-platform compatibility in mind. It is utilizing [entt](https://github.com/skypjack/entt) Entity Component System library for general structure and [Metal](https://developer.apple.com/metal/) for rendering. For implementation, C++ programming language is used and for interfacing with other programming languages (so far with Swift) C API is provided.

## Setup

_Requires macOS Ventura / Xcode 14_

1. Clone the repository and switch to its root folder from terminal
2. <code>git submodule update --init</code>
3. Build and run the project
