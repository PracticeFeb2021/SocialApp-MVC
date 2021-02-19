//
//  PostVC.swift
//  SocialApp
//
//  Created by Oleksandr Bretsko on 1/2/2021.
//

import UIKit

class PostVC: UIViewController, StoryboardInitializable {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var contentView: UIView!
    
    
    @IBOutlet weak var postTitleLabel: UILabel!
    
    @IBOutlet weak var postBodyLabel: UILabel!
    
    @IBOutlet weak var postAuthorLabel: UILabel!
    
    @IBOutlet weak var commentsTableView: UITableView!
    
    @IBOutlet weak var commentsTableConstraint: NSLayoutConstraint!
    
    var post: Post!
    
    var comments = [Comment]()
    
    var netService: NetworkingService!
    
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTitleLabel.text = post.title
        postBodyLabel.text = post.body

        commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: CommentCell.cellReuseId)
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
        
        reloadUser()
        reloadComments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateScrollViewContentSize()
    }
    
    private func updateScrollViewContentSize(){
        
        commentsTableConstraint.constant = commentsTableView.contentSize.height + 20.0
        var heightOfSubViews:CGFloat = 0.0
        contentView.subviews.forEach { subview in
            if let tableView = subview as? UITableView {
                heightOfSubViews += (tableView.contentSize.height + 20.0)
            } else {
                heightOfSubViews += subview.frame.size.height
            }
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.size.width, height: heightOfSubViews)
    }
    
    //MARK: - Network
    
    private func reloadUser() {
        
        netService.loadUsers { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            switch result {
            case .failure(let error):
                //TODO: handle error
                print("ERROR: \(error)")
                
            case .success(let users):
                print("INFO: \(users.count) users received from network")
                guard let user = users.first(where: {
                    $0.id == strongSelf.post.userId
                }) else {
                    return
                }
                DispatchQueue.main.async {
                    strongSelf.postAuthorLabel.text = user.name
                }
            }
        }
    }
    
    private func reloadComments() {
        
        netService.loadComments { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            
            let comments: [Comment]
            switch result {
            case .failure(let error):
                //TODO: handle error
                print("ERROR: \(error)")
                return
            case .success(let receivedComments):
                comments = receivedComments
                break
            }
            let commentsForPost = comments.filter {
                $0.postId == strongSelf.post.id
            }
            print("INFO: found \(commentsForPost.count) comments for this post")
            
            DispatchQueue.main.async {
                strongSelf.comments = commentsForPost
                strongSelf.commentsTableView.reloadData()
                strongSelf.commentsTableConstraint.constant = strongSelf.commentsTableView.contentSize.height
                strongSelf.view.layoutIfNeeded()
            }
        }
    }
}


extension PostVC: UITableViewDelegate,UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard !comments.isEmpty else {
            return UITableViewCell()
        }
        let cell =
            commentsTableView.dequeueReusableCell(withIdentifier: CommentCell.cellReuseId, for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}
