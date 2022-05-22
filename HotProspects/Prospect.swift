//
//  Prospect.swift
//  HotProspects
//
//  Created by Сергей Цайбель on 21.05.2022.
//

import Foundation

class Prospect: Identifiable, Codable {
	var id = UUID()
	var name = "Anonymous"
	var emailAdress = ""
	var isContacted = false
}

class Prospects: ObservableObject {
	@Published private(set) var people: [Prospect]
	
//	let userDefaultsKey = "SavedData"
	let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedData")
	
	init() {
		people = []
		
		do {
			let data = try Data(contentsOf: savePath)
			let decoded = try JSONDecoder().decode([Prospect].self, from: data)
			people = decoded
		} catch {
			print("Failed to load data from Documents Directory")
		}
		
//		if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
//			if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
//				people = decoded
//			}
//		}
	}
	
	private func save() {
		do {
			let data = try JSONEncoder().encode(people)
			try data.write(to: savePath, options: [.atomic])
		} catch {
			print("Failed to save data")
		}
		
//		if let encoded = try? JSONEncoder().encode(people) {
//			UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
//		}
	}
	
	func add(_ prospect: Prospect) {
		people.append(prospect)
		save()
	}
	
	func toggle(_ prospect: Prospect) {
		objectWillChange.send()
		prospect.isContacted.toggle()
		save()
	}
}
