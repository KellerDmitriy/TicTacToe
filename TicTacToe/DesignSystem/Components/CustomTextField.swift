//
//  CustomTextField.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 09.10.2024.
//

import SwiftUI

// MARK: - CustomTextField
struct CustomTextField: View {
    // MARK: - Properties
    var placeHolder: String
    @Binding var text: String
    @FocusState var isActive
    
    // MARK: - Drawing Constants
    private struct Drawing {
        static let height: CGFloat = 50
        static let leadingPadding: CGFloat = 20
        static let verticalPadding: CGFloat = 16
        static let cornerRadius: CGFloat = 30
        static let strokeWidth: CGFloat = 2.0
        static let strokeOpacity: CGFloat = 0.5
        static let borderColor = Color.secondaryPink
        static let textColor = Color.basicBlack
        static let filledBorderColor = Color.basicBlack.opacity(0.4)
    }
    
    // MARK: - Body
    var body: some View {
        ZStack(alignment: .leading) {
            // Placeholder Text
            Text(placeHolder)
                .foregroundColor(isActive || !text.isEmpty ? Drawing.filledBorderColor : .secondaryGray)
                .padding(.horizontal, Drawing.leadingPadding)
                .background(Color.clear)
                .offset(y: (isActive || !text.isEmpty) ? -20 : 0)
                .scaleEffect(isActive || !text.isEmpty ? 0.8 : 1.0, anchor: .leading)
                .animation(.easeInOut(duration: 0.2), value: isActive || !text.isEmpty)
            
            TextField("", text: $text)
                .padding(.leading, Drawing.leadingPadding)
                .padding(.top, Drawing.verticalPadding)
                .focused($isActive)
                .frame(height: Drawing.height)
                .foregroundColor(Drawing.textColor)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.vertical, Drawing.verticalPadding / 2)
        .background(Color.basicLightBlue)
        .cornerRadius(Drawing.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Drawing.cornerRadius)
                .stroke(isActive || !text.isEmpty ? Drawing.filledBorderColor : Drawing.borderColor, lineWidth: Drawing.strokeWidth)
                .opacity(isActive ? 1 : Drawing.strokeOpacity)
        )
        .padding(.horizontal, 20)
        .onTapGesture {
            isActive = true
        }
    }
}

// MARK: - Preview
#Preview {
    CustomTextField(
        placeHolder: "email",
        text: .constant("")
    )
}
