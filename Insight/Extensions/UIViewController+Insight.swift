//
//  UIViewController+Insight.swift
//  Insight
//
//  Created by Patrick Goley on 11/17/15.
//  Copyright © 2015 Affirmative. All rights reserved.
//

import Foundation
import CoreData

typealias ObjectCompletionBlock = (NSManagedObject?) -> ()

protocol ModalSelectionViewController {
    
    var completion: ObjectCompletionBlock? { get set }
}

extension UIViewController {
    
    func startModalSelection<T where T: UIViewController, T: ModalSelectionViewController>(var viewController: T, completion: ObjectCompletionBlock) {
        
        viewController.completion = completion
        
        presentNavigationController(withRoot: viewController)
    }
    
    func presentNavigationController(withRoot rootViewController: UIViewController, animated: Bool = true, completion: (() -> ())? = nil) {
        
        let navController = UINavigationController(rootViewController: rootViewController)
        
        presentViewController(navController, animated: animated, completion: completion)
    }
}