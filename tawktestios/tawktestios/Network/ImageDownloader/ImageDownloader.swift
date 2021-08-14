//
//  ImageDownloader.swift
//  tawktestios
//
//  Created by JMC on 28/7/21.
//

import Foundation
import UIKit

final class ImageDownloader {
    static let shared = ImageDownloader()
    private let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
//    private let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)
    private var cachedImages: [String: UIImage]
//    private var imagesDownloadTasks: [String: URLSessionDataTask]
    
    // MARK: Private init
    private init() {
        cachedImages = [:]
//        imagesDownloadTasks = [:]
    }
    
    func downloadImage(with imageUrlString: String?, completionHandler: @escaping (ImageDownloadCompletionHandler), placeholderImage: UIImage?) {
        
        guard let imageUrlString = imageUrlString else {
            completionHandler("", placeholderImage, false)
            return
        }
        
        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completionHandler(imageUrlString, image, true)
        } else {
            guard let url = URL(string: imageUrlString) else {
                completionHandler(imageUrlString, placeholderImage, false)
                return
            }
            
//            if let cachedTask = getDataTaskFrom(urlString: imageUrlString) {
//                return
//            }
            
            let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            let diskCacheURL = cachesURL.appendingPathComponent("DownloadCache")
            let cache = URLCache(memoryCapacity: 10_000_0000, diskCapacity: 1_000_000_0000, directory: diskCacheURL)
            let config = URLSessionConfiguration.default
            config.urlCache = cache
            let session = URLSession(configuration: config)
            
//            let task = session.dataTask(with: url)
            
            ImageDownloaderClient.shared.enqueue(session: session, downloadTaskURL: url, completionHandler: {
                result in
                
                switch result {
                    case .success(let response):
                        completionHandler(response.url ?? "", response.image ?? placeholderImage, response.isCached ?? false)
                        
                        // Store the downloaded image in cache
                        self.serialQueueForImages.sync(flags: .barrier) {
                            self.cachedImages[imageUrlString] = response.image
                        }
        
                        // Clear out the finished task from download tasks container
//                        _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
//                            self.imagesDownloadTasks.removeValue(forKey: response.url ?? "")
//                        }
                        
                        break
                        
                    case .failure(let error):
                        completionHandler("", placeholderImage, false)
                        break
                }
            })
//            let task = session.dataTask(with: url) { (data, response, error) in
//
//                guard let data = data else {
//                    return
//                }
//
//                if let _ = error {
//                    DispatchQueue.main.async {
//                        completionHandler(imageUrlString, placeholderImage, false)
//                    }
//                    return
//                }
//
//                let image = UIImage(data: data)?.decodedImage()
//
//                // Store the downloaded image in cache
//                self.serialQueueForImages.sync(flags: .barrier) {
//                    self.cachedImages[imageUrlString] = image
//                }
//
//                // Clear out the finished task from download tasks container
//                _ = self.serialQueueForDataTasks.sync(flags: .barrier) {
//                    self.imagesDownloadTasks.removeValue(forKey: imageUrlString)
//                }
//
//                // Always execute completion handler explicitly on main thread
//                DispatchQueue.main.async {
//                    completionHandler(imageUrlString, image, false)
//                }
//            }
            
            // We want to control the access to no-thread-safe dictionary in case it's being accessed by multiple threads at once
//            self.serialQueueForDataTasks.sync(flags: .barrier) {
//                imagesDownloadTasks[imageUrlString] = task
//            }
            
//            task.resume()
        }
    }
    
    
    private func getCachedImageFrom(urlString: String) -> UIImage? {
        // Reading from the dictionary should happen in the thread-safe manner.
        serialQueueForImages.sync {
            return cachedImages[urlString]
        }
    }
    
//    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {
//        
//        // Reading from the dictionary should happen in the thread-safe manner.
//        serialQueueForDataTasks.sync {
//            return imagesDownloadTasks[urlString]
//        }
//    }
    
}

