//
//  FileManager-DocumentsDirectory.swift
//  HotProspects
//
//  Created by Сергей Цайбель on 22.05.2022.
//

import Foundation

extension FileManager {
	static var documentsDirectory: URL {
		let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return path[0]
	}
}
