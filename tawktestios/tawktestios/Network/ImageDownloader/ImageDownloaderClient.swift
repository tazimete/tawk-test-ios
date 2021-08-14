//
//  ImageDownloaderClient.swift
//  tawktestios
//
//  Created by JMC on 14/8/21.
//

import Foundation


public class ImageDownloaderClient{
    public static let shared = ImageDownloaderClient()
    public var queueManager: QueueManager

    
    public init(withQueueManager queueManager: QueueManager = QueueManager.shared) {
        self.queueManager = queueManager
    }
    
    public func enqueue(session: URLSession, downloadTaskURL: URL, completionHandler: @escaping ImageDownloadResultHandler) {
        let operation = NetworkOperation(session: session, downloadTaskURL: downloadTaskURL, completionHandler: completionHandler)
        operation.qualityOfService = .utility
        queueManager.enqueue(operation)
    }
}