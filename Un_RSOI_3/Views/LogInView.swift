//
//  LogInView.swift
//  Un_RSOI_3
//
//  Created by Dmitry Gorin on 19.10.2019.
//  Copyright © 2019 gordiig. All rights reserved.
//

import SwiftUI

struct LogInView: UIViewControllerRepresentable {
    func makeUIViewController(context: UIViewControllerRepresentableContext<LogInView>) -> LogInViewController {
        return LogInViewController()
    }
    
    func updateUIViewController(_ uiViewController: LogInViewController, context: UIViewControllerRepresentableContext<LogInView>) {
        
    }
    
    
}

struct LogInView_Previews: PreviewProvider {
    static var previews: some View {
        LogInView()
    }
}
