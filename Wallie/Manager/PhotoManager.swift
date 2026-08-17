//
//  PhotoManager.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 16/08/26.
//

import SwiftUI
import Photos
import Combine

class PhotoManager: ObservableObject {
    @Published var recentImages: [FotoItem] = []
    
    func requestPermissionAndFetch() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized || status == .limited {
                self.fetchPhotos()
            }
        }
    }
    
    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 10
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 200, height: 200)
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = false
        requestOptions.deliveryMode = .opportunistic
        
        assets.enumerateObjects { asset, _, _ in
            let fotoID = asset.localIdentifier
            
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                if let image = image {
                    DispatchQueue.main.async {
                        if !self.recentImages.contains(where: { $0.id == fotoID }) {
                            self.recentImages.append(FotoItem(id: fotoID, image: image))
                        }
                    }
                }
            }
        }
    }
}
