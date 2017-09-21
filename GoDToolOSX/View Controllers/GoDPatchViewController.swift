//
//  GoDPatchViewController.swift
//  GoD Tool
//
//  Created by The Steez on 17/09/2017.
//
//

import Cocoa

class GoDPatchViewController: GoDTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
		self.title = "Patches"
    }
	
	var patches = ["Apply Physical/Special move split","Remove Physical/Special move split","Assign default phys/spec categories to moves", "Remove foreign languages from common_rel (very useful if it gets too big to import)","Fix shiny glitch for shadow pokemon","Shadow pokemon can be shiny","Shadow pokemon are never shiny","Shadow pokemon are always shiny","Infinite use TMs",]
	var funcs = [#selector(gen4Categories),#selector(removeGen4Categories),#selector(defaultCategories),#selector(removeLanguages),#selector(fixShinyGlitch),#selector(randomShinyShadows),#selector(neverShinyShadows),#selector(alwaysShinyShadows),#selector(infiniteTMs)]
	
	func infiniteTMs() {
		XGAssembly.infiniteUseTMs()
	}

	func fixShinyGlitch() {
		XGAssembly.fixShinyGlitch()
	}
	
	func alwaysShinyShadows() {
		XGAssembly.setShadowPokemonShininess(value: .always)
	}
	
	func neverShinyShadows() {
		XGAssembly.setShadowPokemonShininess(value: .never)
	}
	
	func randomShinyShadows() {
		XGAssembly.setShadowPokemonShininess(value: .random)
	}
	
	func removeLanguages() {
		XGDolPatcher.applyPatch(.zeroForeignStringTables)
	}
	
	func oneStarter() {
		XGDolPatcher.applyPatch(.betaStartersRemove)
	}
	
	func twoStarters() {
		XGDolPatcher.applyPatch(.betaStartersApply)
	}
	
	func removeGen4Categories() {
		XGDolPatcher.applyPatch(.physicalSpecialSplitRemove)
	}
	
	func gen4Categories() {
		XGDolPatcher.applyPatch(.physicalSpecialSplitApply)
	}
	
	func defaultCategories() {
		XGUtility.defaultMoveCategories()
	}
	
	override func numberOfRows(in tableView: NSTableView) -> Int {
		return patches.count
	}
	
	override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
		
		let colour = row % 2 == 0 ? GoDDesign.colourWhite() : GoDDesign.colourLightGrey()
		
		let view = (tableView.make(withIdentifier: "cell", owner: self) ?? GoDTableCellView(title: patches[row], colour: GoDDesign.colourBlack(), showsImage: false, image: nil, background: nil, fontSize: 10, width: self.table.width)) as! GoDTableCellView
		
		view.setBackgroundColour(colour)
		view.setTitle(patches[row])
		
		return view
	}
	
	override func widthForTable() -> NSNumber {
		return 400
	}
	
	override func tableView(_ tableView: GoDTableView, didSelectRow row: Int) {
		self.showActivityView { 
			self.performSelector(onMainThread: self.funcs[row], with: nil, waitUntilDone: true)
			self.hideActivityView()
		}
		
	}
	
}





