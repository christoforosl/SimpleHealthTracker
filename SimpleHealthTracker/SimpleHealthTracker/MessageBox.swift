//
//  MessageBox.swift
//  Marbyl
//
//  Created by Christoforos Lambrou on 7/22/18.
//  Copyright © 2018 Christoforos Lambrou. All rights reserved.
//

import Foundation
import SwiftMessages

class MessageBox {
    static func showError( error: Error ) {
        print(error)
        showError(error.localizedDescription, durationSeconds: 2)
    }
    
    private static let sosIconText = "🅾️"
    private static let iconText = "✅"
    private static let DEAFULT_ERROR_TITLE = "System Error"
    private static let DEAFULT_MESSAGE_TITLE = "Done :-)"
    
    static func showError(_ messageText: String,durationSeconds:Int = 2, title: String? = DEAFULT_ERROR_TITLE){
        // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
        // files in the main bundle first, so you can easily copy them into your project and make changes.
        let view = MessageView.viewFromNib(layout: .messageView)
        var config = SwiftMessages.Config();
        config.duration = SwiftMessages.Duration.seconds(seconds: TimeInterval(durationSeconds))
        
        // Theme message elements with the warning style.
        view.configureTheme(.error)
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: title ?? "", body: messageText, iconText: sosIconText)
        view.button?.isHidden = true
        //view.button?.backgroundImage(for: )
        // Show the message.
        SwiftMessages.show( config: config, view: view)
    }
    
    static func show(_ messageText: String, durationSeconds:Int = 2, title:String? = DEAFULT_MESSAGE_TITLE ){
        
        // Instantiate a message view from the provided card view layout. SwiftMessages searches for nib
        // files in the main bundle first, so you can easily copy them into your project and make changes.
        let view = MessageView.viewFromNib(layout: .messageView)
        var config = SwiftMessages.Config();
        config.duration = SwiftMessages.Duration.seconds(seconds: TimeInterval(durationSeconds))
        
        // Theme message elements with the warning style.
        view.configureTheme(.success)
        
        
        // Add a drop shadow.
        view.configureDropShadow()
        
        // Set message title, body, and icon. Here, we're overriding the default warning
        // image with an emoji character.
        
        view.configureContent(title: title ?? "", body: messageText, iconText: iconText)
        view.button?.isHidden = true
        //view.button?.backgroundImage(for: )
        // Show the message.
        SwiftMessages.show( config: config, view: view)
        
        
    }
}

