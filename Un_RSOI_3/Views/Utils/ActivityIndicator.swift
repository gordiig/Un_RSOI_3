//
//  UIActivityIndicator.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 19.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI
import UIKit


struct ActivityIndicator: UIViewRepresentable {
    @Binding var isAnimating: Bool
    var style = UIActivityIndicatorView.Style.medium
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
