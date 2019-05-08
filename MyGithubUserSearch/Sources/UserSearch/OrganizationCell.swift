//
//  OrganizationCell.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 07/05/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

class OrganizationCell: UICollectionViewCell {
    
    let organizationImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .yellow
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(organizationImageView)
        
        organizationImageView.centerInSuperview()
        organizationImageView.constrainWidth(constant: Metric.orgImageSize)
        organizationImageView.constrainHeight(constant: Metric.orgImageSize)
        
        organizationImageView.layer.cornerRadius = Metric.orgImageSize / 2
        organizationImageView.layer.borderWidth = Metric.orgBorderWidth
        organizationImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
