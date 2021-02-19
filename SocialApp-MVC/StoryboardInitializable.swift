//
//  StoryboardInitializable.swift
//  StoryboardInitializable
//
//  Created by Oleksandr Bretsko on 1/2/2021.
//

import UIKit


protocol StoryboardInitializable {
    
    static var storyboardID: String { get }
}

extension StoryboardInitializable where Self: UIViewController {
    
    static var storyboardID: String {
         String(describing: Self.self)
    }
    static func initFromStoryboard(name: String = "Main") -> Self {
        let storyboard = UIStoryboard(name: name, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: storyboardID) as! Self
    }
}


