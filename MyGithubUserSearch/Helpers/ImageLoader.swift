//
//  ImageLoader.swift
//  MyGithubUserSearch
//
//  Created by Jinwoo Kim on 2020/03/03.
//  Copyright © 2020 jinuman. All rights reserved.
//

import Nuke
import RxSwift

class ImageLoader: ReactiveCompatible {
    
    typealias Completion = (Result<UIImage, Error>) -> Void
    
    static let shared = ImageLoader()
    
    private init() {}
    
    // MARK: - Methods
    
    func loadImage(with url: URL?, completion: @escaping Completion) {
        
        guard let url = url else { return }
        self.loadImage(url: url, completion: completion)
        
    }
    
    func loadImage(with urlString: String?, completion: @escaping Completion) {
        guard let urlString = urlString else { return }
        self.loadImage(with: urlString, completion: completion)
    }
    
    private func loadImage(url: URL, completion: @escaping Completion) {
        
        ImagePipeline.shared.loadImage(with: url) { result in
            switch result {
            case let .success(response):
                completion(.success(response.image))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
    }
    
}

// MARK: - Extensions

extension Reactive where Base: ImageLoader {
    
    func loadImage(urlString: String?) -> Observable<UIImage?> {
        
        return Observable<UIImage?>.create { observer in
            
            self.base.loadImage(with: urlString) { result in
                    switch result {
                    case let .success(image):
                        observer.onNext(image)
                    case let .failure(error):
                        observer.onError(error)
                    }
            }
            
            return Disposables.create()
        }
    }
}

extension UIImageView {
    
    func setImage(
        with urlString: String?,
        placeholder: UIImage? = nil)
    {
        if let urlString = urlString {
            ImageLoader.shared.loadImage(with: urlString) { result in
                switch result {
                case let .success(image):
                    self.image = image
                case let .failure(error):
                    log.debugPrint(error, level: .error)
                    self.image = placeholder
                }
            }
        } else {
            self.image = placeholder
        }
    }
    
    func setImage(
        with url: URL?,
        placeholder: UIImage? = nil)
    {
        if let url = url {
            ImageLoader.shared.loadImage(with: url) { result in
                switch result {
                case let .success(image):
                    self.image = image
                case let .failure(error):
                    log.debugPrint(error, level: .error)
                    self.image = placeholder
                }
            }
        } else {
            self.image = placeholder
        }
    }
    
}

