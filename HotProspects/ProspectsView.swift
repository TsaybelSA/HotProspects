//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Сергей Цайбель on 21.05.2022.
//

import UserNotifications
import CodeScanner
import SwiftUI

struct ProspectsView: View {
	enum FilterType {
		case none, contacted, uncontacted
	}
	
	enum SortType {
		case name, recentlyAdded
	}
	
	@EnvironmentObject var prospects: Prospects
	let filter: FilterType
	
	@State private var sortedBy: SortType = .name
	@State private var showingConfirmation = false
	
	@State private var isShowingScanner = false
	
    var body: some View {
		NavigationView {
			List {
				ForEach(sortedProspects) { prospect in
					HStack {
						contactedMark(for: prospect)
						VStack(alignment: .leading) {
							Text(prospect.name)
								.font(.headline)
							Text(prospect.emailAdress)
								.foregroundColor(.secondary)
						}
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
							
							Button {
								addNotification(for: prospect)
							} label: {
								Label("Remind to contact", systemImage: "bell")
							}
							.tint(.orange)
						}
					}
				}
			}
			.navigationTitle(title)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button {
						showingConfirmation = true
					} label: {
						Label("Sorted by", systemImage: "line.3.horizontal.decrease.circle")
					}
				}
				ToolbarItem(placement: .navigationBarTrailing) {
					Button {
						isShowingScanner = true
					} label: {
						Label("Scan", systemImage: "qrcode.viewfinder")
					}
				}
			}
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Unknown\nwithsome@mail.com", completion: handleScan)
			}
			.confirmationDialog("Sort by", isPresented: $showingConfirmation, titleVisibility: .visible) {
				Button {
					sortedBy = .name
				} label: {
					Label("Name", systemImage: "abc")
				}
				Button {
					sortedBy = .recentlyAdded
				} label: {
					Label("Time of adding", systemImage: "clock")
				}
			}
		}
    }
	
	@ViewBuilder
	func contactedMark(for prospect: Prospect) -> some View {
		if prospect.isContacted && filter == .none {
			Image(systemName: "checkmark.circle")
				.foregroundColor(.green)
		} else if !prospect.isContacted && filter == .none {
			Image(systemName: "x.circle")
				.foregroundColor(.red)
		}
	}
	
	var sortedProspects: [Prospect] {
		switch sortedBy {
			case .name:
				return filteredProspects.sorted(by: { $0.name < $1.name })
			case .recentlyAdded:
				return filteredProspects.reversed()
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
	
	func addNotification(for prospect: Prospect) {
		let center = UNUserNotificationCenter.current()
		
		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = "Contact \(prospect.name)"
			content.subtitle = prospect.emailAdress
			content.sound = .default
			
			// can be improved by adding alert and chosing tome when to remind
			var dataConmponents = DateComponents()
			dataConmponents.hour = 9
			
//			let trigger = UNCalendarNotificationTrigger.init(dateMatching: dataConmponents, repeats: false)
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
			
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			center.add(request)
		}
		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					} else {
						print("Nope, user didn`t give permission")
					}
				}
			}
		}
		
	}
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
		ProspectsView(filter: .none)
    }
}
