//
//  ImageDownloader.swift
//  AffordIQUI
//
//  Created by Sultangazy Bukharbay on 20/11/2023.
//  Copyright © 2023 BlackArrow Financial Solutions Limited. All rights reserved.
//

import Foundation
import UIKit
import AffordIQNetworkKit
import AffordIQFoundation
import SVGKit

actor ImageDownloader {
    static var shared = ImageDownloader()
    
    private var cache: [String: UIImage] = [: ]
    
    private init() { }
    
    func getImage(urlString: String) async -> UIImage {
        print("[ImageDownloader] Image url", urlString)
        // Checking if there is an image in loaded cache. If yes will take an image and return it directly
        if let image = cache[urlString] {
            print("[ImageDownloader] Image from cache")
            return image
        }
        // Checking if local memory has this image.
        else if let image = readImage(from: urlString) {
            // Storing local image into cache
            print("[ImageDownloader] Image from local storage")
            cache[urlString] = image
            return image
        }
        
        var image: UIImage?
        do {
            image = try await downloadImage(from: urlString)
        } catch {
            print("[ImageDownloader] downloadImage(form:) Thrown error")
        }
        
        if let image {
            print("[ImageDownloader] Image from remote server")
            return image
        }
        
        print("[ImageDownloader] return empty image")
        return UIImage()
    }
    
    /// Storing image after successful image fetch from remote server.
    private func storeImageLocally(data: Data, to url: URL) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cachedImagesURL = documentsURL.appendingPathComponent("CachedImages")
        
        if !fileManager.fileExists(atPath: cachedImagesURL.path) {
            do {
                try fileManager.createDirectory(
                    atPath: cachedImagesURL.path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("[ImageDownloader] Could not create directory: \(error)")
            }
        }
        
        let imageURL = cachedImagesURL.appendingPathComponent(url.lastPathComponent)
        
        do {
            try data.write(to: imageURL, options: .atomic)
        } catch {
            print("[ImageDownloader] Error writing to file: \(error)")
        }
    }
    
    /// Read image from local memory if cache doesn't have image with this url
    private func readImage(from urlString: String) -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let cachedImagesURL = documentsURL.appendingPathComponent("CachedImages")
        let imageURL = cachedImagesURL.appendingPathComponent(url.lastPathComponent)
        
        guard fileManager.fileExists(atPath: imageURL.path) else {
            print("[ImageDownloader] [readImage(from:) File does not exist")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: imageURL)
            let svgImage = SVGKImage(data: data)
            let image = svgImage?.uiImage

            return image
        } catch {
            print("[ImageDownloader] readImage(from:) Error reading image: \(error)")
        }
        
        print("[ImageDownloader] readImage(from:) Returns nil")
        return nil
    }
    
    /// Download image from remote server. Last option after checking cache and local memory.
    private func downloadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else { throw AffordIQError.invalidURL(url: urlString) }
        
        let (data, urlResponse) = try await URLSession.shared.data(from: url)
        guard urlResponse as? HTTPURLResponse != nil else {
            throw NetworkError.responseFailed(reason: urlResponse)
        }
        
        let svgImage = SVGKImage(data: data)
        let image = svgImage?.uiImage
        
        cache[urlString] = image
        storeImageLocally(data: data, to: url)
        
        return image
    }
}
