//
//  GoDMovesViewController.swift
//  GoD Tool
//
//  Created by The Steez on 16/09/2017.
//
//

import Cocoa

class GoDMovesViewController: GoDTableViewController {
	
	@IBOutlet var name: NSTextField!
	@IBOutlet var nameID: NSTextField!
	@IBOutlet var index: NSTextField!
	@IBOutlet var hex: NSTextField!
	@IBOutlet var offset: NSTextField!
	
	@IBOutlet var type: GoDTypePopUpButton!
	@IBOutlet var category: GoDCategoryPopUpButton!
	@IBOutlet var targets: GoDTargetsPopUpButton!
	@IBOutlet var animation: GoDOriginalMovesPopUpButton!
	@IBOutlet var effectType: GoDMoveEffectTypesPopUpButton!
	
	@IBOutlet var descID: NSTextField!
	@IBOutlet var desc: NSTextField!
	
	@IBOutlet var effect: GoDEffectsPopUpButton!
	
	@IBOutlet var power: NSTextField!
	@IBOutlet var accuracy: NSTextField!
	@IBOutlet var pp: NSTextField!
	@IBOutlet var priority: NSTextField!
	@IBOutlet var effectAcc: NSTextField!
	
	@IBOutlet var hm: NSButton!
	@IBOutlet var sound: NSButton!
	@IBOutlet var contact: NSButton!
	@IBOutlet var kings: NSButton!
	@IBOutlet var protect: NSButton!
	@IBOutlet var snatch: NSButton!
	@IBOutlet var magic: NSButton!
	@IBOutlet var mirror: NSButton!
	
	
	var filteredMoves = [(name: String, type: XGMoveTypes, index: Int, isShadow: Bool)]()
	var moves = allMovesArray().map { (move) -> (name: String, type: XGMoveTypes, index: Int, isShadow: Bool) in
		return (move.name.unformattedString, move.type, move.index, move.isShadowMove)
	}
	
	var currentMove = XGMove(index: 0) {
		didSet {
			self.reloadViewWithActivity()
		}
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.title = "Move Editor"
		self.nameID.formatter = NumberFormatter.shortFormatter()
		self.descID.formatter = NumberFormatter.shortFormatter()
		self.priority.formatter = NumberFormatter.signedByteFormatter()
		self.pp.formatter = NumberFormatter.byteFormatter()
		self.power.formatter = NumberFormatter.byteFormatter()
		self.accuracy.formatter = NumberFormatter.byteFormatter()
		self.effectAcc.formatter = NumberFormatter.byteFormatter()
		self.category.isEnabled = XGDolPatcher.isClassSplitImplemented()

		filteredMoves = moves
		table.reloadData()
    }
	
	func reloadViewWithActivity() {
		self.showActivityView {
			self.reloadView()
			self.hideActivityView()
		}
	}
	
	func reloadView() {
		
		self.name.stringValue = currentMove.name.unformattedString
		self.nameID.integerValue = currentMove.nameID
		self.index.integerValue = currentMove.moveIndex
		self.hex.stringValue = currentMove.moveIndex.hexString()
		self.offset.stringValue = currentMove.startOffset.hexString()
		
		self.descID.integerValue = currentMove.descriptionID
		self.desc.stringValue = currentMove.mdescription.unformattedString
		self.effect.selectItem(at: currentMove.effect)
		
		self.power.integerValue = currentMove.basePower
		self.priority.integerValue = currentMove.priority
		self.pp.integerValue = currentMove.pp
		self.accuracy.integerValue = currentMove.accuracy
		self.effectAcc.integerValue = currentMove.effectAccuracy

		animation.isEnabled = true
		if game != .PBR {
			self.animation.selectItem(at: currentMove.animationID)
		} else {
			let idsJSON = XGFiles.json("WZX ids")
			if idsJSON.exists, let ids = idsJSON.json as? [Int], let index = ids.firstIndex(of: currentMove.animationID) {
				animation.selectItem(at: index)
			} else {
				animation.selectItem(at: 0)
				animation.isEnabled = false
			}
		}
		
		self.type.select(currentMove.type)
		self.targets.select(currentMove.target)
		self.effectType.select(currentMove.effectType)

		if XGDolPatcher.isClassSplitImplemented() {
			self.category.select(currentMove.category)
		} else {
			self.category.select(currentMove.type.category)
		}

		self.contact.state = currentMove.contactFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.mirror.state = currentMove.mirrorMoveFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.protect.state = currentMove.protectFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.kings.state = currentMove.kingsRockFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.magic.state = currentMove.magicCoatFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.sound.state = currentMove.soundBasedFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.snatch.state = currentMove.snatchFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		self.hm.state = currentMove.HMFlag ? NSControl.StateValue.on : NSControl.StateValue.off
		
		
	}
	
	override func numberOfRows(in tableView: NSTableView) -> Int {
		return filteredMoves.count
	}
	
	override func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return 50
	}
	
	override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let move = filteredMoves[row]
		
		let cell = (tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) ?? GoDTableCellView(title: "", colour: GoDDesign.colourBlack(), fontSize: 16, width: widthForTable())) as! GoDTableCellView
		
		cell.setBackgroundImage(move.isShadow ? XGMoveTypes.shadowImage : move.type.image)
		cell.setTitle(move.name)
		
		cell.identifier = NSUserInterfaceItemIdentifier(rawValue: "cell")
		cell.translatesAutoresizingMaskIntoConstraints = false
		
		cell.alphaValue = self.table.selectedRow == row ? 1 : 0.75
		if self.table.selectedRow == row {
			cell.addBorder(colour: GoDDesign.colourBlack(), width: 1)
		} else {
			cell.removeBorder()
		}
		
		return cell
	}
	
	override func tableView(_ tableView: GoDTableView, didSelectRow row: Int) {
		super.tableView(tableView, didSelectRow: row)
		if row >= 0 {
			let move = filteredMoves[row]
			self.currentMove = XGMove(index: move.index)
		}
	}

	override func searchBarBehaviourForTableView(_ tableView: GoDTableView) -> GoDSearchBarBehaviour {
		.onTextChange
	}

	override func tableView(_ tableView: GoDTableView, didSearchForText text: String) {

		defer {
			tableView.reloadData()
		}

		guard !text.isEmpty else {
			filteredMoves = moves
			return
		}

		filteredMoves = moves.filter({ (move) -> Bool in
			move.name.simplified.contains(text.simplified)
		})
	}
	
	
	@IBAction func setMoveName(_ sender: NSTextField) {
		if nameID.stringValue.integerValue != nil {
			var value = nameID.stringValue.integerValue!
			value = value < 0 ? 0 : value
			value = value > kMaxStringID ? kMaxStringID : value
			
			self.currentMove.nameID = value
			
			if currentMove.nameID == 0 {
				return
			}
			if sender.stringValue.length == 0 {
				sender.stringValue = self.currentMove.name.string
				return
			}

			let table = currentMove.name.table
			let prefix = game == .PBR ? "[0xF001][0xF101]" : ""
			let string = XGString(string: prefix + sender.stringValue, file: table, sid: currentMove.nameID)
			if game == .PBR {
				if !table.stringTable.replaceString(string, save: true, increaseLength: true) {
					printg("Failed to set move name:", sender.stringValue)
				}
			} else {
				if !table.stringTable.addString(string, increaseSize: false, save: true) {
					printg("Failed to set move name:", sender.stringValue)
					if table.stringTable.extraCharacters < string.dataLength {
						printg("Try shortening some strings in \(table.fileName)'s string table.")
					}
				}
			}
		}
		
		self.table.reloadData()
	}
	
	@IBAction func setMoveNameID(_ sender: NSTextField) {
		
		if let id = sender.stringValue.integerValue {
			var value = id
			value = value < 0 ? 0 : value
			value = value > kMaxStringID ? kMaxStringID : value
			
			self.currentMove.nameID = value
		}
		
		self.reloadViewWithActivity()
		self.table.reloadData()
	}
	
	@IBAction func setDescriptionID(_ sender: NSTextField) {
		
		if let id = sender.stringValue.integerValue {
			var value = id
			value = value < 0 ? 0 : value
			value = value > kMaxStringID ? kMaxStringID : value
			
			self.currentMove.descriptionID = value
		}
		
		self.reloadViewWithActivity()
		
	}
	
	@IBAction func setMoveDescription(_ sender: NSTextField) {
		
		if descID.stringValue.integerValue != nil {
			var value = descID.stringValue.integerValue!
			value = value < 0 ? 0 : value
			value = value > kMaxStringID ? kMaxStringID : value
			
			self.currentMove.descriptionID = value
			
			if currentMove.descriptionID == 0 {
				return
			}
			if sender.stringValue.length == 0 {
				sender.stringValue = self.currentMove.mdescription.stringWithEscapedNewlines
				return
			}

			let table = currentMove.mdescription.table
			let prefix = game == .PBR ? "[0xF001][0xF101]" : ""
			let string = XGString(string: prefix + sender.stringValue, file: table, sid: currentMove.descriptionID)
			if game == .PBR {
				if !table.stringTable.replaceString(string, save: true, increaseLength: true) {
					printg("Failed to set move name:", sender.stringValue)
				}
			} else {
				if !table.stringTable.addString(string, increaseSize: false, save: true) {
					printg("Failed to set move description:", sender.stringValue)
					if table.stringTable.extraCharacters < string.dataLength {
						printg("Try shortening some strings in \(table.fileName)'s string table.")
					}
				}
			}
		}
		
		self.reloadViewWithActivity()
		
	}
	
	@IBAction func newType(_ sender: GoDTypePopUpButton) {
		let value = sender.selectedValue
		
		self.currentMove.type = value
	}
	
	@IBAction func newCategory(_ sender: GoDCategoryPopUpButton) {
		let value = sender.selectedValue
		
		self.currentMove.category = value
	}
	
	@IBAction func newTargets(_ sender: GoDTargetsPopUpButton) {
		let value = sender.selectedValue
		
		self.currentMove.target = value
	}
	
	@IBAction func newEffectType(_ sender: GoDMoveEffectTypesPopUpButton) {
		let value = sender.selectedValue
		
		self.currentMove.effectType = value
	}
	
	
	@IBAction func newAnimation(_ sender: GoDOriginalMovesPopUpButton) {
		var value = sender.indexOfSelectedItem

		if game == .PBR {
			let idsJSON = XGFiles.json("WZX ids")
			guard idsJSON.exists, let ids = idsJSON.json as? [Int], value < ids.count else {
				return
			}

			value = ids[value]
		}
		
		currentMove.animationID = value
		if game != .PBR {
			currentMove.animation2ID = value - (value < 0x164 ? 0 : 1)
		}
	}
	
	@IBAction func newEffect(_ sender: GoDEffectsPopUpButton) {
		let value = sender.selectedValue
		
		self.currentMove.effect = value
	}
	
	@IBAction func newPower(_ sender: NSTextField) {
		let value = sender.integerValue
		
		self.currentMove.basePower = value
	}
	
	@IBAction func newAccuracy(_ sender: NSTextField) {
		let value = sender.integerValue
		
		self.currentMove.accuracy = value
	}
	
	@IBAction func newPP(_ sender: NSTextField) {
		let value = sender.integerValue
		
		self.currentMove.pp = value
	}
	
	@IBAction func newPriority(_ sender: NSTextField) {
		var val = sender.integerValue
		val = val < -128 ? -128 : val
		val = val > 127 ? 127 : val
		
		self.currentMove.priority = val
	}
	
	@IBAction func newEffectAcc(_ sender: NSTextField) {
		let value = sender.integerValue
		
		self.currentMove.effectAccuracy = value
	}
	
	@IBAction func toggleHMFlag(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.HMFlag = value
	}
	
	@IBAction func toggleSound(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.soundBasedFlag = value
	}
	
	@IBAction func toggleContact(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.contactFlag = value
	}
	
	@IBAction func toggleKings(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.kingsRockFlag = value
	}
	
	@IBAction func toggleProtect(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.protectFlag = value
	}
	
	@IBAction func toggleSnatch(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.snatchFlag = value
	}
	
	@IBAction func toggleMagic(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.magicCoatFlag = value
	}
	
	@IBAction func toggleMirror(_ sender: NSButton) {
		let value = sender.state == NSControl.StateValue.on
		
		self.currentMove.mirrorMoveFlag = value
	}
	
	func prepareForSave() {
		for view in [power!, accuracy!, effectAcc!, pp! ] {
			if let val = view.stringValue.integerValue {
				if val > 0xFF {
					view.stringValue = "255"
				}
				if val < 0 {
					view.stringValue = "0"
				}
			} else {
				view.stringValue = "0"
			}
		}
		for view in [nameID!, descID!] {
			if let val = view.stringValue.integerValue {
				if val > kMaxStringID {
					view.stringValue = kMaxStringID.string
				}
				if val < 0 {
					view.stringValue = "0"
				}
			} else {
				view.stringValue = "0"
			}
		}
		
		newPP(pp)
		newPower(power)
		newPriority(priority)
		newEffectAcc(effectAcc)
		newAccuracy(accuracy)
		setMoveName(name)
		setMoveDescription(desc)
		
	}
	
	@IBAction func save(_ sender: Any) {
		prepareForSave()
		currentMove.save()
		
		moves[currentMove.moveIndex].name = currentMove.name.string
		moves[currentMove.moveIndex].isShadow = currentMove.isShadowMove
		moves[currentMove.moveIndex].type = currentMove.type
		
		reloadViewWithActivity()
		table.reloadData()
	}
	
}

































