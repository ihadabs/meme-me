//
//  MemesTableVC.swift
//  MemeMe
//
//  Created by Hadi Albinsaad on 20/10/2018.
//  Copyright © 2018 Hadi. All rights reserved.
//

import UIKit



class MemesTableVC: UITableViewController {
    
    var memes: [Meme] {
        return (UIApplication.shared.delegate as! AppDelegate).memes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell", for: indexPath)
        let meme = memes[indexPath.row]
        cell.imageView?.image = meme.memedImage // 50 * 50
        cell.textLabel?.text = meme.topText + " ... " + meme.bottomText
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let meme = memes[indexPath.row]
        performSegue(withIdentifier: "Preview", sender: meme)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Preview" {
            let memePreviewVC = segue.destination as! MemePreviewVC
            memePreviewVC.meme = sender as? Meme
        }
    }
}
