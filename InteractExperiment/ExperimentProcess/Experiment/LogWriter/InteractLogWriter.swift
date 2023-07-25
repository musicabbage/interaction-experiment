//
//  InteractLogWriter.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/4.
//

import Foundation

struct InteractLogWriter: LogWriterProtocol {
    func write(log: InteractLogModel, configurations: ConfigurationModel, toFolder folderPath: URL) throws {
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
        logString.append("App Version          :\(log.appVersion)\n")
        logString.append("Name                 :\(log.participantId)\n")
        logString.append("Experiment Start     :\(dateFormatter.string(from: log.experimentStart))\n")
        logString.append("Stroke Colour        :\("0,0,0,255")\n")
        logString.append("Background Colour    :\("255,255,255,255")\n")
        logString.append("Stroke Width         :\("1")\n")
        for phase in configurations.phases {
            logString.append("\(phase.name) Files       :\(imageFileNames(phase.images))\n")
        }
        logString.append("Input Mask File      :\("")\n")
        logString.append("Drawing Pad Size     :\(log.drawingPadSize.width),\(log.drawingPadSize.height)\n")
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
            let actionString: String
            switch model.action {
            case let .drawing(_, x, y):
                actionString = String(format: "%03d;%f;%.1f;%.1f;%@\n", index, model.timestamp, x, y, model.action.key)
            default:
                actionString = String(format: "%03d;%f;0;0;%@\n", index, model.timestamp, model.action.key)
            }
            logString.append(actionString)
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

private extension InteractLogWriter {
    func imageFileNames(_ images: [String]) -> String {
        guard !images.isEmpty else { return "" }
        
        var result = images.reduce("") { $0 + $1 + "," }
        result.removeLast()
        return result
    }
}
