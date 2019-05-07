//
//  OrganizationCell.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

class OrganizationCell: UICollectionViewCell {
    var org: Organization? {
        didSet {
            guard let urlString = org?.avatarUrl else { return }
            self.orgImageView.loadImageUsingCache(with: urlString)
        }
    }
    
    let orgImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = Metric.orgImageSize / 2
        $0.layer.borderWidth = Metric.orgBorderWidth
        $0.layer.borderColor = UIColor.lightGray.cgColor
        
        $0.backgroundColor = .yellow
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(orgImageView)
        
        orgImageView.centerInSuperview()
        orgImageView.constrainWidth(constant: Metric.orgImageSize)
        orgImageView.constrainHeight(constant: Metric.orgImageSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
