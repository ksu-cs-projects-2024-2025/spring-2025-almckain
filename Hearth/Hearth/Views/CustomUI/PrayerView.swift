//
//  PrayerView.swift
//  Hearth
//
//  Created by Aaron McKain on 4/5/25.
//

import SwiftUI

struct PrayerView: View {
    var prayer: PrayerModel
    var isFuturePrayer: Bool = false
    var displayInHome: Bool = false
    
    var onSave: (PrayerModel) -> Void
    var onDelete: (() -> Void)? = nil
    var onCancel: (() -> Void)? = nil
    
    @State private var isExpanded = false
    @State private var isEditing = false
    @State private var animationEnabled = true
    @State private var prayerText: String
    @State private var isCompleted: Bool
    @State private var editorHeight: CGFloat = 40
    
    @State private var reminderDate: Date
    
    // For alert if user picks a past date
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showDeleteConfirmation: Bool = false
    
    init(prayer: PrayerModel,
         isFuturePrayer: Bool = false,
         initialEditing: Bool = false,
         displayInHome: Bool = false,
         onSave: @escaping (PrayerModel) -> Void,
         onDelete: (() -> Void)? = nil,
         onCancel: (() -> Void)? = nil
    ) {
        self.prayer = prayer
        self.isFuturePrayer = isFuturePrayer
        self.onSave = onSave
        self.onDelete = onDelete
        self.onCancel = onCancel
        self.displayInHome = displayInHome
        
        _prayerText = State(initialValue: prayer.content)
        _isCompleted = State(initialValue: prayer.completed)
        _isEditing = State(initialValue: initialEditing)
        _isExpanded = State(initialValue: initialEditing)
        
        _reminderDate = State(initialValue: prayer.timeStamp > Date.distantPast ? prayer.timeStamp : Date())
    }
    
    var body: some View {
        VStack(spacing: 8){
            HStack(spacing: 5) {
                if Calendar.current.isDateInToday(prayer.timeStamp) || prayer.timeStamp < Date() {
                    VStack {
                        Circle()
                            .stroke(isCompleted ? Color.parchmentLight : Color.hearthEmberMain, lineWidth: 2)
                            .background(
                                Circle()
                                    .fill(isCompleted ? Color.hearthEmberMain : .parchmentLight)
                                    .frame(width: 24, height: 24)
                            )
                            .frame(width: 24, height: 24)
                            .padding(.top, 8)
                            .allowsHitTesting(!isEditing)
                            .onTapGesture {
                                withAnimation(.easeInOut) {
                                    isCompleted.toggle()
                                    
                                    var updated = prayer
                                    updated.completed = isCompleted
                                    onSave(updated)
                                }
                            }
                        Spacer()
                    }
                }
                
                if isEditing {
                    VStack {
                        DynamicTextEditor(text: $prayerText, dynamicHeight: $editorHeight)
                            .frame(height: editorHeight)
                            .frame(maxWidth: .infinity)
                        //.padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white)
                            )
                            .onChange(of: prayerText) { _, newValue in
                                let filtered = newValue.filter { $0 != "\n" }
                                if filtered.count > 50 {
                                    prayerText = String(filtered.prefix(100))
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Text("\(prayerText.filter { $0 != "\n" }.count)/100")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                } else {
                    Text(prayerText)
                        .font(.customBody1)
                        .foregroundStyle(.parchmentDark)
                        .lineLimit(isExpanded ? nil : 1)
                        .animation(.easeInOut, value: isExpanded)
                        .padding(.leading, 6)
                        .onTapGesture {
                            withAnimation(.easeInOut) { isExpanded.toggle() }
                        }
                }
                Spacer()
            }
            
            if isExpanded {
                if isEditing {
                    if isFuturePrayer {
                        DatePicker(
                            "Reminder Time",
                            selection: $reminderDate,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .labelsHidden()
                        .padding(.vertical, 4)
                    }
                    
                    HStack(alignment: .center, spacing: 24) {
                        Button("Cancel") {
                            withAnimation(.easeInOut) {
                                animationEnabled = true
                                isEditing = false
                                prayerText = prayer.content
                                onCancel?()
                            }
                        }
                        .foregroundStyle(.hearthError)
                        
                        Button("Save") {
                            withAnimation(.easeInOut) {
                                animationEnabled = true
                                isEditing = false
                                var updatedPrayer = prayer
                                updatedPrayer.content = prayerText
                                
                                // If this is a future prayer, we must ensure date is in the future
                                if isFuturePrayer {
                                    guard reminderDate > Date() else {
                                        // Show an alert or revert to old date
                                        showAlert = true
                                        alertMessage = "The selected date/time must be in the future."
                                        return
                                    }
                                    updatedPrayer.timeStamp = reminderDate
                                }
                                
                                onSave(updatedPrayer)
                            }
                        }
                    }
                    .padding(.top, 4)
                } else {
                    Group {
                        HStack(alignment: .center, spacing: 24) {
                            Button("Delete") {
                                withAnimation(.easeInOut) {
                                    showDeleteConfirmation = true
                                }
                            }
                            .foregroundStyle(.hearthError)
                            
                            Button("Edit") {
                                withAnimation(.easeInOut) {
                                    animationEnabled = false
                                    isEditing = true
                                    
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .foregroundColor(.parchmentLight)
        )
        .onTapGesture {
            if !isEditing {
                withAnimation(.easeInOut) {
                    isExpanded.toggle()
                    
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Invalid Date"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // If you'd like, reset to old date or do something else
                }
            )
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete this prayer reminder? This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    onDelete?()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

/*
#Preview {
    PrayerView()
}
*/
