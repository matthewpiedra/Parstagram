//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Matthew Piedra on 10/7/21.
//

import UIKit
import Parse

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var posts = [PFObject]()
    var numberOfPosts = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        // Do any additional setup after loading the view.
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPosts()
    }
    
    func loadPosts() {
        self.numberOfPosts = 1
        
        // refresh table view to fetch post you just created (possibly)
        let query = PFQuery(className: "Posts")
        // since author is a pointer to a row in another table, if we don't
        // include then it'll just be the pointer, but if we do include it
        // then we get the actual object the pointer is pointing to
        query.includeKey("author")
        query.limit = self.numberOfPosts
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                
                self.tableView.reloadData()
                
                self.run(after: 2) {
                    self.refreshControl.endRefreshing()
                }
            }
            else {
                print(error!)
            }
        }
    }
    
    @IBAction func onSignOut(_ sender: Any) {
        PFUser.logOut()
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onRefresh() {
        // load posts again
        loadPosts()
    }
    
    func loadMorePosts() {
        // load more posts if user scrolls past a certain point
        self.numberOfPosts = self.numberOfPosts + 1
        
        // refresh table view to fetch post you just created (possibly)
        let query = PFQuery(className: "Posts")
        
        // since author is a pointer to a row in another table, if we don't
        // include then it'll just be the pointer, but if we do include it
        // then we get the actual object the pointer is pointing to
        query.includeKey("author")
        query.limit = self.numberOfPosts
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                
                self.tableView.reloadData()
            }
            else {
                print(error!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == posts.count {
            loadMorePosts()
        }
    }
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // length of how many posts the user has
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // configure image, username, and label for table cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
        
        let post = posts[indexPath.row]
        
        let user = post["author"] as! PFUser
        cell.usernameLabel.text = user.username
        
        let comment = post["comment"] as! String
        cell.captionLabel.text = comment
        
        let imageFile = post["image"] as! PFFileObject
        let urlString = imageFile.url!
        let url = URL(string: urlString)!
        cell.postImage.af.setImage(withURL: url)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 475
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
