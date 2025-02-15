//
//  LoadingScreenView.swift
//  Hearth
//
//  Created by Aaron McKain on 2/15/25.
//

import SwiftUI

struct LoadingScreenView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .scaleEffect(2)
            Text("Loading...")
                .font(.customHeadline1)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.parchmentLight)
    }
}

#Preview {
    LoadingScreenView()
}
