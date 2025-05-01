//
//  NotificationCardView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/30/25.
//

import SwiftUI

struct NotificationCardView: View {
    let title: String
    let description: String
    let iconName: String
    @Binding var isEnabled: Bool
    let timePickerView: () -> AnyView
    let infoMessage: String?
    
    init(
        title: String,
        description: String,
        iconName: String,
        isEnabled: Binding<Bool>,
        @ViewBuilder timePickerView: @escaping () -> some View,
        infoMessage: String? = nil
    ) {
        self.title = title
        self.description = description
        self.iconName = iconName
        self._isEnabled = isEnabled
        self.timePickerView = { AnyView(timePickerView()) }
        self.infoMessage = infoMessage
    }
    
    var body: some View {
        VStack(spacing: 0) {
            cardHeader
            
            if isEnabled {
                expandedContent
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .opacity(isEnabled ? 1.0 : 0.7)
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isEnabled)
    }
    
    private var cardHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 18))
                .foregroundStyle(isEnabled ? .hearthEmberMain : .gray.opacity(0.7))
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(isEnabled ?
                              Color.hearthEmberMain.opacity(0.2) :
                              Color.gray.opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(isEnabled ? .primary : Color.gray)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(isEnabled ? Color.secondary : .gray.opacity(0.7))
            }
            
            Spacer()
            
            Toggle("", isOn: $isEnabled)
                .labelsHidden()
                .tint(.hearthEmberMain)
        }
    }
    
    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
                .padding(.vertical, 8)
            
            HStack {
                Text("Reminder time:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                timePickerView()
            }
            .padding(.horizontal, 4)
            
            if let infoMessage = infoMessage {
                HStack {
                    Image(systemName: "info.circle")
                        .font(.footnote)
                        .foregroundStyle(.hearthEmberMain.opacity(0.7))
                    
                    Text(infoMessage)
                        .font(.footnote)
                        .foregroundStyle(.hearthEmberMain.opacity(0.8))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                }
                .padding(.top, 4)
                .padding(.horizontal, 4)
            }
        }
    }
}
