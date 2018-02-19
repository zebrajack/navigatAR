//
//  NewEventViewController.swift
//  navigatAR
//
//  Created by Migala, Alex on 2/17/18.
//  Copyright © 2018 MICDS Programming. All rights reserved.
//

import Eureka
import Firebase
import CodableFirebase

class NewEventViewController: FormViewController {
	
	var availableNodes: [String] = []
	var selectedNodes: FirebaseArray<FirebasePushKey> = []
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.updateDBData()
		
		form +++ Section("Event Information")
			<<< TextRow("eventname") { row in
				row.title = "Name"
//				row.placeholder = "Name"
			}
			
			<<< TextRow("eventdescription") { row in
				row.title = "Description"
//				row.placeholder = "Description"
			}
			
			+++ Section("Event Time")
			<<< DateTimeRow("eventstarttime") { row in
				row.title = "Start Time"
				row.dateFormatter?.dateStyle = DateFormatter.Style.full
			}
			<<< DateTimeRow("eventendtime") { row in
				row.title = "End Time"
				row.dateFormatter?.dateStyle = DateFormatter.Style.full
			}
			
			+++ ButtonRow() { row in
				row.title = "Select Nodes"
				row.onCellSelection { row, cell in
					self.performSegue(withIdentifier: "showSelectNodesForEvent", sender: nil)
					// TODO: store data in selectedNodes
				}
			}
		
			+++ ButtonRow() { row in
				row.title = "Create Event"
				row.onCellSelection { row, cell in
					let formValues = self.form.values()
					
					let newEvent = Event(
						name: formValues["eventname"] as! String,
						description: formValues["eventdescription"] as! String,
						locations: self.selectedNodes,
						start: formValues["eventstarttime"] as! Date,
						end: formValues["eventendtime"] as! Date
					)
					
					print("Creating event: \(newEvent)")
					
					let ref = Database.database().reference()
					ref.child("events").childByAutoId().setValue(try! FirebaseEncoder().encode(newEvent))
				}
		}
	}
	
	@IBAction func unwindBackFromSelectionsSegue(_ sender: UIStoryboardSegue) {
		print("Unwinding back to create event")
		
		guard let selections = sender.source as? SelectNodesViewController else { return }
		
		for node in selections.selectedNodes {
			print(node.name)
		}
	}
	
	func updateDBData() {
		// Get nodes from db and load into the array
		let ref = Database.database().reference()
		print("Loading available nodes for db")
		ref.child("nodes").observe(.value, with: { snapshot in
			guard snapshot.exists() else { return }
			let value = snapshot.value!
			
			do {
				let loc = Array((try FirebaseDecoder().decode([FirebasePushKey: Node].self, from: value)).values)
				self.availableNodes = loc.map { node in node.name }
			}
			catch let error {
				print(error)
			}
		})
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		self.availableNodes = []
	}
}
