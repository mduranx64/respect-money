//
//  ClearableNumberField.swift
//  RespectMoney
//
//  Created by Miguel Duran on 15-03-25.
//

import SwiftUI

struct ClearableNumberField: View {
    let label: String
    let placeholder: String
    @Binding var value: Double?
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)

            Spacer()

            TextField(placeholder, value: $value, format: .number)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .submitLabel(.done)
                .focused($isFocused)
                
            HStack {
                if isFocused, value != nil, value != 0 {
                    Button {
                        value = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var amount: Double?
    Form {
         ClearableNumberField(label: "Amount", placeholder: "0.00", value: $amount)
    }
}
