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
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initializeLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.organizationImageView.image = nil
    }
    
    // MARK: - Methods
    
    private func initializeLayout() {
        self.addSubview(self.organizationImageView)
        
        self.organizationImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(Metric.orgImageSize)
        }
        
        self.organizationImageView.layer.cornerRadius = Metric.orgImageSize.height / 2.0
        self.organizationImageView.layer.borderWidth = Metric.orgBorderWidth
        self.organizationImageView.layer.borderColor = UIColor.lightGray.cgColor
    }
}
