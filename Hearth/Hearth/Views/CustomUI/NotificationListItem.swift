//
//  NotificationListItem.swift
//  Hearth
//
//  Created by Aaron McKain on 4/30/25.
//

import SwiftUI

struct NotificationListItem: View {
    let title: String
    let description: String
    let iconName: String
    @Binding var isEnabled: Bool
    let timeView: () -> AnyView
    let infoMessage: String?
    
    init(
        title: String,
        description: String,
        iconName: String,
        isEnabled: Binding<Bool>,
        @ViewBuilder timeView: @escaping () -> some View,
        infoMessage: String? = nil
    ) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self._isEnabled = isEnabled
        self.timeView = { AnyView(timeView()) }
        self.infoMessage = infoMessage
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .font(.system(size: 16))
                    .foregroundStyle(isEnabled ? .hearthEmberMain : .gray.opacity(0.7))
                    .frame(width: 28, height: 28)
                    .background(
                        Circle()
                            .fill(isEnabled ?
                                  Color.hearthEmberMain.opacity(0.15) :
                                  Color.gray.opacity(0.08))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.customHeadline1)
                        .fontWeight(.medium)
                        .foregroundStyle(isEnabled ? .hearthEmberMain : .gray)
                    
                    Text(description)
                        .font(.customBody1)
                        .foregroundStyle(isEnabled ? .parchmentDark : .gray.opacity(0.7))
                }
                
                Spacer()
                
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(.hearthEmberMain)
            }
            
            if isEnabled {
                if let infoMessage = infoMessage {
                    HStack(spacing: 6) {
                        Image(systemName: "info.circle")
                            .font(.customBody1)
                            .foregroundStyle(.hearthEmberLight)
                        
                        Text(infoMessage)
                            .font(.customBody2)
                            .foregroundStyle(.parchmentDark)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                    }
                    .padding(.top, 2)
                    .padding(.leading, 40)
                } else {
                    HStack {
                        Text("Reminder Time:")
                            .font(.customBody1)
                            .foregroundStyle(.parchmentDark)
                            .padding(.leading, 40)
                        
                        Spacer()
                        
                        timeView()
                    }
                    .padding(.top, 2)
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isEnabled)
    }
}

