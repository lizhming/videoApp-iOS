//
//  Log.swift
//  SudaKorean
//
//  Created by LiZhongMing on 30/11/2017.
//  Copyright © 2017 LiZhongMing. All rights reserved.
//

import Foundation

enum LogLevel{
    case info, debug, error, none
}
class Log{
    static let logLevel = LogLevel.info
    static let logFile = true
    class func debug(_ string:Any){
        if logLevel == .info || logLevel == LogLevel.debug{
            print("[Debug] \(string)")
            writeLogToFile("[Debug] \(string)\n")
        }
    }
    class func info(_ string:Any){
        if logLevel != LogLevel.none{
            print("[Info] \(string)")
            writeLogToFile("[Info] \(string)\n")
        }
    }
    class func error(_ string:Any){
        if logLevel != LogLevel.none{
            print("[Error] \(string)")
            writeLogToFile("[Error] \(string)\n")
        }
    }
    
    class func writeLogToFile(_ string: Any){
        if !logFile{
            return;
        }
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateStr = formatter.string(from: date)
        
        let file = "Moview-\(dateStr).log" //this is the file. we will write to and read from it
        let text = "\(string)" //just a text
        
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            
            let fileURL = dir.appendingPathComponent(file)
            
            if FileManager.default.fileExists(atPath: fileURL.path){
                if let fileHandle1 = try? FileHandle(forWritingTo: fileURL){
                    fileHandle1.seekToEndOfFile()
                    let data = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                    fileHandle1.write(data)
                    fileHandle1.closeFile()
                }
            }
            else{
                //writing
                do {
                    try text.write(to: fileURL, atomically: false, encoding: .utf8)
                }
                catch {/* error handling here */}
            }
            //reading
            //            do {
            //                let text2 = try String(contentsOf: fileURL, encoding: .utf8)
            //            }
            //            catch {}
        }
    }
}
