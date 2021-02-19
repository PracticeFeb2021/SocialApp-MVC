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
        loadUser(withID: post.userId)
        loadComments(forPostWithID: post.id)
        
        commentsTableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: CommentCell.cellReuseId)
        commentsTableView.dataSource = self
        commentsTableView.delegate = self
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
    
    private func loadUser(withID id: Int) {
        netService.loadUsers { users in
            if let user = users?.first(where: {
                $0.id == id
            }) {
                DispatchQueue.main.async { [weak self] in
                    self?.postAuthorLabel.text = user.name
                }
            }
        }
    }
    
    private func loadComments(forPostWithID id: Int) {
        netService.loadComments { comments in
            guard let comments1 = comments else {
                print("INFO: No comments received from network")
                return
            }
            let commentsForPost = comments1.filter {
                $0.postId == id
            }
            guard commentsForPost.count > 0 else {
                print("INFO: No comments received from network")
                return
            }
            print("INFO: found \(commentsForPost.count) comments for this post")
            
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.comments = commentsForPost
                strongSelf.commentsTableView.reloadData()
                strongSelf.commentsTableConstraint.constant = strongSelf.commentsTableView.contentSize.height
                strongSelf.view.layoutIfNeeded()
                
                // force the layout of subviews before drawing
                strongSelf.commentsTableView.layoutIfNeeded()
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
            self.commentsTableView.dequeueReusableCell(withIdentifier: CommentCell.cellReuseId, for: indexPath) as! CommentCell
        cell.configure(with: comments[indexPath.row])
        return cell
    }
}
