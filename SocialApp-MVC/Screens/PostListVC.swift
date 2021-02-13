//
//  PostListVC.swift
//  SocialApp
//
//  Created by Oleksandr Bretsko on 1/2/2021.
//

import UIKit

class PostListVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [Post]()
    
    var netService: NetworkingService! 
    
    //MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        navigationItem.title = "Posts"
        
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: PostCell.cellReuseId)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        netService.loadPosts { [weak self] posts in
            guard let strongSelf = self,
                  let newPosts = posts else {
                return
            }
            print("INFO: \(newPosts.count) posts received from network")
            
            DispatchQueue.main.async {
                strongSelf.posts = newPosts
                strongSelf.tableView.reloadData()
            }
        }
    }
}

//MARK: - TableView

extension PostListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !posts.isEmpty else {
            return UITableViewCell()
        }
        let cell =
            self.tableView.dequeueReusableCell(withIdentifier: PostCell.cellReuseId, for: indexPath) as! PostCell
        cell.configure(with: posts[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        vc.netService = netService
        vc.post = posts[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
