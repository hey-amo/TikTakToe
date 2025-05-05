//: SwiftUI implementation of TikTakToe in Swift Playgrounds
//: Follows tutorial on https://www.youtube.com/watch?v=MCLiPW2ns2w

import SwiftUI
import PlaygroundSupport

struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .background(Color.white)

    }
}

// Wrap the SwiftUI view in a UIHostingController
let contentView = ContentView()
    .preferredColorScheme(.light)

let hostingController = UIHostingController(rootView: contentView)


// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(hostingController)

