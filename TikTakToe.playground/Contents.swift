//: SwiftUI implementation of TikTakToe in Swift Playgrounds
//: Follows tutorial on https://www.youtube.com/watch?v=MCLiPW2ns2w

import SwiftUI
import PlaygroundSupport

let columns: [GridItem] = [GridItem(.flexible()),
                           GridItem(.flexible()),
                           GridItem(.flexible()),
]


struct ContentView: View {
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                LazyVGrid(columns: columns, spacing: 5.0) {
                    ForEach(0..<9) { i in
                        ZStack {
                            Circle()
                                .foregroundColor(.red)
                                .opacity(0.5)
                                .frame(width: ((geo.size.width / 3) - 15),
                                       height: ((geo.size.height / 3) - 15) )
                            Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                
                        }
                    }
                }
                Spacer()
            }.padding(5)
        }
    }
}

// Wrap the SwiftUI view in a UIHostingController
let contentView = ContentView()
    .preferredColorScheme(.light)

let hostingController = UIHostingController(rootView: contentView)


// Present the view controller in the Live View window
PlaygroundPage.current.setLiveView(hostingController)

