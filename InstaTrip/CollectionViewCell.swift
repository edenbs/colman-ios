//
//  CollectionViewCell.swift
//  InstaTrip
//
//  Created by Dana Tsirulnik on 31/01/2018.
//  Copyright © 2018 Eden Ben Shoshan. All rights reserved.
//

import UIKit
class CollectionViewCell:  UICollectionViewCell {
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postContent: UILabel!
    /* @IBOutlet var postImage: UIImageView!
    @IBOutlet var postcontent: UILabel! //Shoukl change.*/
    
    func displayContent(image: UIImage, content: String){
        postImage.image = image
        postContent.text = content
    }
    
    
}
