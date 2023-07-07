//
//  InteractLogWriter.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/4.
//

import Foundation

struct InteractLogWriter: LogWriterProtocol {
    func write(log: InteractLogModel, toFolder folderPath: URL) throws {
        var logString = ""
        /**
         Name                 :Anonymous Participant
         Experiment Start     :04/07/2023 - 17:29:30
         Stroke Colour        :0,0,0,255
         Background Colour    :255,255,255,255
         Stroke Width         :2.0
         Stimulus Files       :S1.png,S2.png,S3.png,S4.png,S5.png,S6.png,S7.png,S8.png
         Familiarisation File :P1.png
         Input Mask File      :
         Drawing Pad Size     :1260,600
         Trial Number         :1
         Trial Start          :04/07/2023 - 17:29:34
         Trial End            :04/07/2023 - 17:29:41
         */
        let dateFormatter = DateFormatter.logDateFormatter
        logString.append("Name                 :\(log.participantId)\n")
        logString.append("Experiment Start     :\(dateFormatter.string(from: log.experimentStart))\n")
        logString.append("Stroke Colour        :\("0,0,0,255")\n")
        logString.append("Background Colour    :\("255,255,255,255")\n")
        logString.append("Stroke Width         :\("1")\n")
        logString.append("Stimulus Files       :\("")\n")
        logString.append("Familiarisation File :\("")\n")
        logString.append("Input Mask File      :\("")\n")
        logString.append("Drawing Pad Size     :\("")\n")
        logString.append("Trial Number         :\(log.trialNumber)\n")
        if let trialStart = log.trialStart {
            logString.append("Trial Start          :\(dateFormatter.string(from: trialStart))\n")
        } else {
            logString.append("Trial Start          :\n")
        }
        
        if let trialEnd = log.trialEnd {
            logString.append("Trial End            :\(dateFormatter.string(from: trialEnd))\n")
        } else {
            logString.append("Trial End            :\n")
        }
        
        //action
        logString.append("\n")
        
        log.actions.enumerated().forEach { (index, model) in
            switch model.action {
            case let .drawing(_, x, y):
                logString.append("\(index);\(model.timestamp.timeIntervalSince1970);\(x);\(y);\(model.action.key)\n")
            default:
                logString.append("\(index);\(model.timestamp.timeIntervalSince1970);0;0;\(model.action.key)\n")
            }
        }
        
        if let logData = logString.data(using: .utf8) {
            //{Name} (Trial {trial number}){experiment start date}
            //> ex. Anonymous Participant (Trial 1) 2023-07-04 - 18-48-10.txt
            let fileDateFormate = DateFormatter.logFileDateFormatter
            let fileName = "\(log.participantId) (Trial \(log.trialNumber)) \(fileDateFormate.string(from: log.experimentStart)).txt"
            let path = folderPath.appending(path: fileName)
            try logData.write(to: path)
        }
    }
}

