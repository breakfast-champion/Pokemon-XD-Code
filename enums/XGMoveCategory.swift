//
//  XGMoveClass.swift
//  XG Tool
//
//  Created by StarsMmd on 19/05/2015.
//  Copyright (c) 2015 StarsMmd. All rights reserved.
//

import Foundation

enum XGMoveCategories : Int, XGDictionaryRepresentable, Codable {
	
	case none	   = 0x0
	case physical  = 0x1
	case special   = 0x2
	
	var string : String {
		get {
			switch self {
				case .none:			return "Neither"
				case .physical:		return "Physical"
				case .special:		return "Special"
			}
		}
	}
	
	func cycle() -> XGMoveCategories {
		
		return XGMoveCategories(rawValue: self.rawValue + 1) ?? XGMoveCategories(rawValue: 0)!
		
	}
	
	var dictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.rawValue as AnyObject]
		}
	}
	
	var readableDictionaryRepresentation: [String : AnyObject] {
		get {
			return ["Value" : self.string as AnyObject]
		}
	}
	
	enum CodingKeys: String, CodingKey {
		case type, name
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.rawValue, forKey: .type)
		try container.encode(self.string, forKey: .name)
	}
}




