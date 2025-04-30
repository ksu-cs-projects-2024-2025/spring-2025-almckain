//
//  UserCard.swift
//  Hearth
//
//  Created by Aaron McKain on 4/16/25.
//

import SwiftUI

struct UserCard: View {
    @ObservedObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        CardView {
            VStack(spacing: 8) {
                if let user = profileViewModel.user {
                    Text("\(user.firstName) \(user.lastName)")
                        .font(.customDisplay)
                        .foregroundStyle(.hearthEmberMain)
                }
                
                Text("Joined Hearth \(profileViewModel.formattedDateString())")
                    .font(.customCaption1)
                    .foregroundStyle(.parchmentDark)
            }
            .padding(.vertical, 10)
        }
    }
}
