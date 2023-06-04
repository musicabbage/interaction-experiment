//
//  ToastView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/6/4.
//

import SwiftUI
import PopupView

enum ToastType {
    case success, info, error
    
    var color: Color {
        switch self {
        case .success:
            return .green
        case .info:
            return .orange
        case .error:
            return .red
        }
    }
    
    var iconName: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        case .error:
            return "xmark.circle.fill"
        }
    }
}

extension View {
    
    func toast(
        isPresented: Binding<Bool>,
        type: ToastType,
        message: String) -> some View {
            self.popup(isPresented: isPresented) {
                Label(message, systemImage: type.iconName)
                    .padding(12)
                    .font(.title3)
                    .foregroundColor(.white)
                    .background(type.color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } customize: { custom in
                custom
                    .autohideIn(2)
                    .position(.bottom)
                    .type(.floater())
            }
    }

//    public func popup<PopupContent: View>(
//        isPresented: Binding<Bool>,
//        @ViewBuilder view: @escaping () -> PopupContent,
//        customize: @escaping (Popup<PopupContent>.PopupParameters) -> Popup<PopupContent>.PopupParameters
//        ) -> some View {
//            self.modifier(
//                FullscreenPopup<Int, PopupContent>(
//                    isPresented: isPresented,
//                    isBoolMode: true,
//                    params: customize(Popup<PopupContent>.PopupParameters()),
//                    view: view,
//                    itemView: nil)
//            )
//        }
}
