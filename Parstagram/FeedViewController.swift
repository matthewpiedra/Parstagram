//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Matthew Piedra on 10/7/21.
//

import UIKit
import Parse
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MessageInputBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var refreshControl: UIRefreshControl!
    
    var posts = [PFObject]()
    var numberOfPosts = Int()
    let commentBar = MessageInputBar()
    var canAppear = false
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        commentBar.inputTextView.placeholder = "Add a comment"
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self

        // Do any additional setup after loading the view.
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyBoardWillBeHidden(note:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func keyBoardWillBeHidden(note: Notification) {
        commentBar.inputTextView.text = nil
        canAppear = false
        becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadPosts()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    override var canBecomeFirstResponder: Bool {
        return canAppear
    }
    
    @IBAction func onSignOut(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginController = main.instantiateViewController(withIdentifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginController
    }
    
    @objc func onRefresh() {
        // load posts again
        loadPosts()
    }
    
    func loadPosts() {
        self.numberOfPosts = 2
        
        // refresh table view to fetch post you just created (possibly)
        let query = PFQuery(className: "Posts")
        // since author is a pointer to a row in another table, if we don't
        // include then it'll just be the pointer, but if we do include it
        // then we get the actual object the pointer is pointing to
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    func loadMorePosts() {
        // load more posts if user scrolls past a certain point
        self.numberOfPosts = self.numberOfPosts + 2

        // refresh table view to fetch post you just created (possibly)
        let query = PFQuery(className: "Posts")

        // since author is a pointer to a row in another table, if we don't
        // include then it'll just be the pointer, but if we do include it
        // then we get the actual object the pointer is pointing to
        query.includeKeys(["author", "comments", "comments.author"])
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
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        // send comment to post
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["author"] = PFUser.current()!
        comment["post"] = selectedPost
        
        selectedPost.add(comment, forKey: "comments")

        selectedPost.saveInBackground { (success, error) in
            if success {
                print("comment saved")
            }
            else {
                print(error!)
            }
        }
        
        tableView.reloadData()
        
        // Clear everything
        commentBar.inputTextView.text = nil
        canAppear = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == posts.count {
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
        // length of how many comments the post has
        // Overall since there can only be one photo in each section
        // the equation would be: 1 + numberOfComments + addComment cell
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return 1 + comments.count + 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // there are as many sections as there are posts
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // why indexPath.section instead of indexPath.rows?
        // Because we have to account for the comment rows that a post can contain
        // Thus there can be many rows linked with eachother in one section
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            // configure image, username, and label for table cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! PostCell
            
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
        else if indexPath.row <= comments.count { // if the post contains comments
            let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell") as! CommentCell
            
            let comment = comments[indexPath.row - 1]
            
            let commentText = comment["text"] as? String
            cell.commentLabel.text = commentText
            
            let user = comment["author"] as! PFUser
            cell.nameLabel.text = user.username
            
            return cell
        }
        else  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "addCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 475
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // open comment section
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []

        if indexPath.row == comments.count + 1 {
            canAppear = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()

            selectedPost = post
        }
    }
    
    func deleteComment(fromPost post: PFObject, commentIndex idx: Int) {
        let comments = post["comments"] as! [PFObject]
        let comment = comments[idx]
        
        do {
            post.remove(comment, forKey: "comments")
            try comment.delete()
            self.tableView.reloadData()
        }
        catch {
            print("There was an error!")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let post = posts[indexPath.section]
        let numOfComments = ((post["comments"] as? [PFObject]) ?? []).count

        if indexPath.row != 0 && indexPath.row <= numOfComments {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
                        // delete the comment here
                        self.deleteComment(fromPost: post, commentIndex: indexPath.row-1)
                        completionHandler(true)
                    }
            
            
            deleteAction.image = UIImage(systemName: "trash")
            deleteAction.backgroundColor = .systemRed
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
        }
        else {
            return nil
        }
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
