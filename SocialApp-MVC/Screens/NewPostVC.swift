//
//  NewPostVC.swift
//  SocialApp-MVC
//
//  Created by Oleksandr Bretsko on 22.07.2021.
//

import UIKit

class NewPostVC: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var postTitleTextField: UITextField!
    
    @IBOutlet weak var postBodyTextView: UITextView!
    
    var netService: NetworkingService!
    
    enum Mode {
        case new
        case edit
    }
    var mode: Mode = .new
    
    var post: Post?
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .new:
            topLabel.text = "New post"
        case .edit:
            topLabel.text = ""
        }
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        navigationItem.rightBarButtonItem = doneButton
        
        if let post = post {
            postTitleTextField.text = post.title
            postBodyTextView.text = post.body
        }
    }
    
    //MARK: - Methods
    
    @objc func doneButtonPressed() {
        switch mode {
        case .new:
            guard validateCurrentPost() else {
                presentAlert()
                return
            }
            //TODO: create post
        case .edit:
            guard validateCurrentPost() else {
                presentAlert()
                return
            }
            var editedPost = post!
            editedPost.title = postTitleTextField.text!
            editedPost.body = postBodyTextView.text!
            //TODO: update post
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    private func presentAlert() {
        let alert = UIAlertController(title: "Error", message: "Post title and body cannot be empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
    
    private func validateCurrentPost() -> Bool {
        guard let postTitle = postTitleTextField.text, !postTitle.isEmpty,
              let postBody = postBodyTextView.text,
              !postBody.isEmpty else {
                  return false
              }
        return true
    }
}
