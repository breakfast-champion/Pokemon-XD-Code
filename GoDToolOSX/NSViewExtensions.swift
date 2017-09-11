//
//  NSViewExtensions.swift
//  GoD Tool
//
//  Created by The Steez on 29/06/2016.
//  Copyright © 2016 StarsMmd. All rights reserved.
//

import AppKit


extension NSView {
	
	func setBackgroundColour(_ colour: NSColor) {
		self.wantsLayer = true
		self.layer?.backgroundColor = colour.cgColor
	}
	
}