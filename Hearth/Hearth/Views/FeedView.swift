//
//  FeedView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/6/25.
//

import SwiftUI

struct FeedView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.green
                    .opacity(0.9)
                    .ignoresSafeArea()
               
                VStack {
                    Divider()
                        .background(Color.red)
                    ScrollView {
                        Text("Have the style touching the safe area edge.")
                            .padding()
                        Text("Big balls")
                    }
                }
                .navigationTitle("Nav Bar Background")
                .font(.title2)
            }
        }
    }
}

#Preview {
    FeedView()
}
