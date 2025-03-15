//
//  ClearableTextField.swift
//  RespectMoney
//
//  Created by Miguel Duran on 15-03-25.
//

import SwiftUI

struct ClearableTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)

            Spacer()

            TextField(placeholder, text: $text)
                .multilineTextAlignment(.trailing)
                .submitLabel(.done)
                .focused($isFocused)
            
            HStack {
                
                if isFocused, !text.isEmpty {
                    Button {
                        text = "" // Clear the text
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain) // Prevents gray tap effect
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var text = "Alarm Name"
    return ClearableTextField(label: "Label", placeholder: "Enter name", text: $text)
}
