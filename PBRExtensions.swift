//
//  PBRExtensions.swift
//  GoDToolCL
//
//  Created by The Steez on 24/12/2018.
//

import Foundation

enum XGRegions : UInt32 {
	
	case US = 0x52504245 // RPBE
	case EU = 0x52504250 // RPBP
	case JP = 0x5250424A // RPBJ
	
	var index : Int {
		switch self {
		// arbitrary values
		case .US: return 0
		case .EU: return 1
		case .JP: return 2
		}
	}
	
}

enum XGGame {
	case Colosseum
	case XD
	case PBR
}

let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/Revolution-Tool"
let region = XGRegions.US
let game = XGGame.PBR


var verbose = false
var increaseFileSizes = true
let date = Date(timeIntervalSinceNow: 0)
var logString = ""


func printg(_ args: Any...) {
	for arg in args {
		print(arg, separator: " ", terminator: " ")
	}
	print("") // automatically adds new line
	
	for arg in args {
		logString = logString + String(describing: arg) + " "
	}
	logString = logString + "\n"
	
	XGUtility.saveString(logString, toFile: .log(date))
}

class XGUtility {
	class func saveObject(_ obj: AnyObject, toFile file: XGFiles) {
		if !file.folder.exists {
			file.folder.createDirectory()
		}
		NSKeyedArchiver.archiveRootObject(obj, toFile: file.path)
	}
	
	class func saveData(_ data: Data, toFile file: XGFiles) -> Bool {
		if !file.folder.exists {
			file.folder.createDirectory()
		}
		do {
			try data.write(to: URL(fileURLWithPath: file.path), options: [.atomic])
		} catch {
			return false
		}
		return true
	}
	
	class func saveString(_ str: String, toFile file: XGFiles) {
		
		if let string = str.data(using: String.Encoding.utf8) {
			if !saveData(string, toFile: file) {
				// if printging to a log fails, don't keep printging :)
				if file.folder.name != XGFolders.Logs.name {
					printg("Couldn't save string to file: \(file.path)")
				} else {
					print("Couldn't save string to file: \(file.path)")
				}
			}
		} else {
			// if printging to a log fails, don't keep printging :)
			if file.folder.name != XGFolders.Logs.name {
				printg("Couldn't encode string for file: \(file.path)")
			} else {
				print("Couldn't encode string for file: \(file.path)")
			}
		}
	}
	
	class func saveJSON(_ json: AnyObject, toFile file: XGFiles) {
		if !file.folder.exists {
			file.folder.createDirectory()
		}
		do {
			try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted).write(to: URL(fileURLWithPath: file.path), options: [.atomic])
		} catch {
			printg("couldn't save json to file: \(file.path)")
		}
	}
	
	class func loadJSONFromFile(_ file: XGFiles) -> AnyObject? {
		do {
			let json = try JSONSerialization.jsonObject(with: file.data!.data as Data, options: [])
			return json as AnyObject?
		} catch {
			printg("couldn't load json from file: \(file.path)")
			return nil
		}
	}
	
	// extraction
	class func extractMainFiles() {
		XGFolders.setUpFolderFormat()
		
		printg("extracting required files...")
		let requiredFiles : [XGFiles] = [.dol, .fsys("common"), .fsys("mes_common"), .fsys("deck")]
		var fileMissing = false
		for file in requiredFiles {
			if !file.exists {
				printg("Error: required file '\(file.path)' doesn't exist")
				fileMissing = true
			}
		}
		if fileMissing { return }
		
		let fsys = XGFiles.fsys("deck").fsysData
		for i in 0 ... 25 {
			if !XGFiles.dckt(i).exists {
				let data = fsys.decompressedDataForFileWithIndex(index: i)!
				data.file = .dckt(i)
				data.save()
			}
		}
		for i in 26 ... 44 {
			if !XGFiles.dckp(i - 26).exists {
				let data = fsys.decompressedDataForFileWithIndex(index: i)!
				data.file = .dckp(i - 26)
				data.save()
			}
		}
		if !XGFiles.dcka.exists {
			let data = fsys.decompressedDataForFileWithIndex(index: 45)!
			data.file = .dcka
			data.save()
		}
		
		let common = XGFiles.fsys("common").fsysData
		for i in 0 ... 32 {
			if !XGFiles.common(i).exists {
				let data = common.decompressedDataForFileWithIndex(index: i)!
				data.file = .common(i)
				data.save()
			}
		}
		
		if !XGFiles.msg("mes_common").exists {
			let msg = XGFiles.fsys("mes_common").fsysData.decompressedDataForFileWithIndex(index: 1)!
			msg.file = .msg("mes_common")
			msg.save()
		}
		printg("extraction complete!")
		
	}
	
	class func extractAllFiles() {
		XGFolders.setUpFolderFormat()
		extractMainFiles()
//		XGThreadManager.manager.runInBackgroundAsync {
			printg("extracting fsys files...")
			for file in XGFolders.FSYS.files where file.fileType == .fsys {
				let fsys = file.fsysData
				if let msg = fsys.decompressedDataForFileWithFiletype(type: .msg) {
					if msg.get2BytesAtOffset(12) == 0x5553 { // US in unicode
						msg.file = .msg(msg.file.fileName.removeFileExtensions())
						msg.save()
					}
				}
				let folder = XGFolders.ISOExport(fsys.fileName.removeFileExtensions())
				folder.createDirectory()
				fsys.extractFilesToFolder(folder: folder, decode: true)
			}
			printg("extraction complete!")
//		}
	}
	
	class func getFSYSForIdentifier(id: UInt32) -> XGFsys? {
		for file in XGFolders.FSYS.files where file.fileName.contains(".fsys") {
			let fsys = file.data!
			let entries = fsys.get4BytesAtOffset(kNumberOfEntriesOffset)
			
			for i in 0 ..< entries {
				let details = fsys.get4BytesAtOffset(0x60)
				let identifier = fsys.getWordAtOffset(details + (i * kSizeOfArchiveEntry))
				if identifier == id {
					return file.fsysData
				}
			}
			
		}
		return nil
	}
}


var allStringTables = [XGStringTable]()
var stringsLoaded = false

func loadAllStrings() {
	
	if !stringsLoaded {
		
		// very specific order based on the id at index 0xb in the .msg file
		// files with the same id are identical but may be loaded at different times
		// the first stringid in the next file is one greater than the last stringid of the previous file
		allStringTables = [XGFiles.msg("mes_common").stringTable, XGFiles.msg("mes_fight_e").stringTable, XGFiles.msg("mes_name_e").stringTable]
		
		stringsLoaded = true
	}
	
}

func getStringWithID(id: Int) -> XGString? {
	loadAllStrings()
	
	if id == 0 {
		return nil
	}
	
	var currentID = id
	for table in allStringTables {
		if table.containsStringWithId(currentID) {
			if let s = table.stringWithID(currentID) {
				return s
			}
		} else {
			currentID -= table.numberOfEntries
		}
	}
	return nil
}

func getStringSafelyWithID(id: Int) -> XGString {
	loadAllStrings()
	
	return getStringWithID(id: id) ?? XGString(string: "-", file: nil, sid: nil)
}

func getStringsContaining(substring: String) -> [XGString] {
	loadAllStrings()
	
	var found = [XGString]()
	for table in allStringTables {
		for str in table.allStrings() where str.containsSubstring(substring) {
			found.append(str)
		}
	}
	
	return found
}















