//
//  TextFieldWithClearButton.swift
//  RadiantTune
//
//  Created by 杜乐乐 on 2024-07-20.
//

import SwiftUI

struct ClearButton: ViewModifier {
    @Binding var text: String

    public func body(content: Content) -> some View {
        HStack {
            content
            if !text.isEmpty {
                Button(action: {
                    self.text = ""
                }) {
                    Image(systemName: "multiply.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        self.modifier(ClearButton(text: text))
    }
}

