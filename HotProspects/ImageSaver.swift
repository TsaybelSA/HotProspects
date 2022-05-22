//
//  ImageSaver.swift
//  Instafilter
//
//  Created by Сергей Цайбель on 13.05.2022.
//

import UIKit

class ImageSaver: NSObject {
	
	var successHandler: (() -> Void)?
	var errorHandler: ((Error) -> Void)?
	
	func writeToPhotoAlbum(image: UIImage) {
		UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
	}
	
	@objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			errorHandler?(error)
		} else {
			successHandler?()
		}
		print("Save finished!")
	}
}
