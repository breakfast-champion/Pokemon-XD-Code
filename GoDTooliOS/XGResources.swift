////
////  XGResources.swift
////  XG Tool
////
////  Created by The Steez on 01/06/2015.
////  Copyright (c) 2015 Ovation International. All rights reserved.
////
//
import Foundation

enum XGResources {
	
	case JSON(String)
	case png(String)
	case bin(String)
	case nameAndFileType(String, String)
	
	var path : String {
		get{
			return Bundle.main.path(forResource: name, ofType: fileType) ?? ""
		}
	}
	
	var name : String {
		get {
			switch self {
				case .JSON(let name)							: return name
				case .png(let name)								: return name
				case .bin(let name)								: return name
				case .nameAndFileType(let name, _)	: return name
			}
		}
	}
	
	var fileType : String {
		get {
			switch self {
				case .JSON									: return ".json"
				case .png									: return ".png"
				case .bin									: return ".bin"
				case .nameAndFileType( _, let filetype)		: return filetype
			}
		}
	}
	
	var fileName : String {
		get {
			return name + fileType
		}
	}
	
	var fileSize : Int {
		get {
			return self.data.length
		}
	}
	
	var data : XGMutableData {
		get {
			return XGMutableData(contentsOfFile: self.path)
		}
	}
	
	var json : AnyObject {
		get {
			return try! JSONSerialization.jsonObject(with: self.data.data as Data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
		}
	}
	
	
	
	
}


















