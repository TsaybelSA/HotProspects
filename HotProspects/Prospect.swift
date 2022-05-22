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
	
	let userDefaultsKey = "SavedData"
	
	init() {
		people = []
		
		if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
			if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
				people = decoded
			}
		}
	}
	
	private func save() {
		if let encoded = try? JSONEncoder().encode(people) {
			UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
		}
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
