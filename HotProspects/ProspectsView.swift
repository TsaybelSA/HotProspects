//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Сергей Цайбель on 21.05.2022.
//

import CodeScanner
import SwiftUI

struct ProspectsView: View {
	enum FilterType {
		case none, contacted, uncontacted
	}
	
	@EnvironmentObject var prospects: Prospects
	
	let filter: FilterType
	
	@State private var isShowingScanner = false
	
    var body: some View {
		NavigationView {
			List {
				ForEach(filteredProspects) { prospect in
					VStack(alignment: .leading) {
						Text(prospect.name)
							.font(.headline)
						Text(prospect.emailAdress)
							.foregroundColor(.secondary)
					}
					.swipeActions {
						if prospect.isContacted {
							Button {
								prospects.toggle(prospect)
							} label: {
								Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
							}
							.tint(.blue)
						} else {
							Button {
								prospects.toggle(prospect)
							} label: {
								Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
							}
							.tint(.green)
						}
					}
				}
			}
			.navigationTitle(title)
			.toolbar {
				Button {
					isShowingScanner = true
				} label: {
					Label("Scan", systemImage: "qrcode.viewfinder")
				}
			}
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Unknown\nwithsome@mail.com", completion: handleScan)
			}
		}
    }
	
	var filteredProspects: [Prospect] {
		switch filter {
			case .none:
				return prospects.people
			case .contacted:
				return prospects.people.filter({ $0.isContacted })
			case .uncontacted:
				return prospects.people.filter({ !$0.isContacted })
		}
	}
	
	var title: String {
		switch filter {
			case .none: return "Everyone"
			case .contacted: return "Contacted people"
			case .uncontacted: return "Uncontacted people"
		}
	}
	
	func handleScan(result: Result<ScanResult, ScanError>) {
		isShowingScanner = false
		
		switch result {
			case .success(let result):
				let details = result.string.components(separatedBy: "\n")
				
				guard details.count == 2 else { return }
				let person = Prospect()
				person.name = details[0]
				person.emailAdress = details[1]
				prospects.add(person)
			case .failure(let error):
				print("Scanning failed: \(error.localizedDescription)")
		}
	}
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProspectsView(filter: .none)
    }
}