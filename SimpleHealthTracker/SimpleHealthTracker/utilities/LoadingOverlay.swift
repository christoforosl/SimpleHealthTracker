//
//  LoadingOverlay.swift
//  Marbyl
//
//  Created by Christoforos Lambrou on 7/22/18.
//  Copyright © 2018 Christoforos Lambrou. All rights reserved.
//

import Foundation
import UIKit

public class LoadingOverlay{
    
    var overlayView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    var activityContainerView = UIView()
    
    class var shared: LoadingOverlay {
        struct Static {
            static let instance: LoadingOverlay = LoadingOverlay()
        }
        return Static.instance
    }
    
    public func showActivityIndicator(view: UIView) {
        showActivityIndicatorWithText(view: view, message: "Please wait...")
    }
    
    public func showActivityIndicatorWithText(view: UIView, message: String) {
        
        self.activityContainerView.frame = view.frame
        self.activityContainerView.backgroundColor = UIColor.white
        self.activityContainerView.addSubview(self.overlayView)
        self.activityContainerView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin,.flexibleHeight, .flexibleWidth]
        self.overlayView.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
        self.overlayView.center = view.center
        self.overlayView.autoresizingMask = [.flexibleLeftMargin,.flexibleTopMargin,.flexibleRightMargin,.flexibleBottomMargin]
        self.overlayView.backgroundColor = UIColor.black
        self.overlayView.clipsToBounds = true
        self.overlayView.layer.cornerRadius = 10
        
        self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 80)
        self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        self.activityIndicator.center = CGPoint(x: self.overlayView.bounds.width / 2, y: self.overlayView.bounds.height / 2)
        
        self.overlayView.addSubview(self.activityIndicator)
        view.addSubview(self.activityContainerView)
        view.bringSubview(toFront: self.activityContainerView)
        self.activityIndicator.startAnimating()
        
    }
    
    public func hideOverlayViewIf(hideIt:Bool) {
        if(hideIt) {
            hideOverlayView()
        }
    }
    public func hideOverlayView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityContainerView.removeFromSuperview()
        }
    }
}

