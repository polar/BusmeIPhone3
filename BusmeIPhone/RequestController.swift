//
//  RequestController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct RequestState {
    public static let S_START = 0
    
    public static let S_INQUIRE_START = 10
    public static let S_INQUIRE_IN_PROGRESS = 11
    public static let S_INQUIRE_FINISH = 12
    
    public static let S_ANSWER_START = 20
    public static let S_ANSWER_IN_PROGRESS = 21
    public static let S_ANSWER_FINISH = 22
    
    public static let S_REQUEST_START = 30
    public static let S_REQUEST_IN_PROGRESS = 31
    public static let S_REQUEST_FINISH = 32
    
    public static let S_RESPONSE_START = 40
    public static let S_RESPONSE_IN_PROGRESS = 41
    public static let S_RESPONSE_FINISH = 42
    
    public static let S_NOTIFY_START = 50
    public static let S_NOTIFY_IN_PROGRESS = 51
    public static let S_NOTIFY_FINISH = 52
    
    public static let S_ACK_START = 60
    public static let S_ACK_IN_PROGRESS = 61
    public static let S_ACK_FINISH = 62
    
    public var state : Int = S_START
}

public class RequestStateEventData {
    public var state : Int = RequestState.S_START
}

public class RequestController {
    
    public func onRequestState( requestState : RequestStateEventData ) {
        switch (requestState.state) {
        case RequestState.S_INQUIRE_START, RequestState.S_INQUIRE_IN_PROGRESS, RequestState.S_INQUIRE_FINISH:
            onInquire(requestState)
            
        case RequestState.S_ANSWER_START, RequestState.S_ANSWER_IN_PROGRESS, RequestState.S_ANSWER_FINISH:
            onAnswer(requestState)
            
        case RequestState.S_REQUEST_START, RequestState.S_REQUEST_IN_PROGRESS, RequestState.S_REQUEST_FINISH:
            onRequest(requestState)
            
            
        case RequestState.S_RESPONSE_START, RequestState.S_RESPONSE_IN_PROGRESS, RequestState.S_RESPONSE_FINISH:
            onResponse(requestState)
            
            
        case RequestState.S_NOTIFY_START, RequestState.S_NOTIFY_IN_PROGRESS, RequestState.S_NOTIFY_FINISH:
            onNotify(requestState)
            
            
        case RequestState.S_ACK_START, RequestState.S_ACK_IN_PROGRESS, RequestState.S_ACK_FINISH:
            onAck(requestState)
            
        default:
            BLog.logger.error("Bad RequestState \(requestState.state)")
        }
    }
    
    public func onInquire(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_INQUIRE_START:
            onInquireStart(requestState)
            break
        case RequestState.S_INQUIRE_IN_PROGRESS:
            onInquireInProgress(requestState)
            break
        case RequestState.S_INQUIRE_FINISH:
            onInquireFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
        
    }
    
    // This method is called to signify the need to present a dialog to the user.
    public func onInquireStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the dialog is being put up.
    public func onInquireInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the dialog is up.
    public func onInquireFinish(requestState : RequestStateEventData) {
        
    }
    
    public func onAnswer(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_ANSWER_START:
            onAnswerStart(requestState)
            break
        case RequestState.S_ANSWER_IN_PROGRESS:
            onAnswerInProgress(requestState)
            break
        case RequestState.S_ANSWER_FINISH:
            onAnswerFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
    }
    
    // This method is called to signify that the user will answer the dialog
    public func onAnswerStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the user answering the dialog
    public func onAnswerInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the user answer is ready
    public func onAnswerFinish(requestState : RequestStateEventData) {
        
    }
    
    public func onRequest(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_REQUEST_START:
            onRequestStart(requestState)
            break
        case RequestState.S_REQUEST_IN_PROGRESS:
            onRequestInProgress(requestState)
            break
        case RequestState.S_REQUEST_FINISH:
            onRequestFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
    }
    
    // This method is called to process the Request with the answer from the user
    public func onRequestStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the request is in process, possibly
    // on another thread.
    public func onRequestInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the background request is completed.
    public func onRequestFinish(requestState : RequestStateEventData) {
        
    }

    
    public func onResponse(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_RESPONSE_START:
            onResponseStart(requestState)
            break
        case RequestState.S_RESPONSE_IN_PROGRESS:
            onResponseInProgress(requestState)
            break
        case RequestState.S_RESPONSE_FINISH:
            onResponseFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
    }
    
    // This method is called to process the response from a request
    public func onResponseStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the response is being processed
    public func onResponseInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the response has been processed.
    public func onResponseFinish(requestState : RequestStateEventData) {
        
    }
    
    
    public func onNotify(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_NOTIFY_START:
            onNotifyStart(requestState)
            break
        case RequestState.S_NOTIFY_IN_PROGRESS:
            onNotifyInProgress(requestState)
            break
        case RequestState.S_NOTIFY_FINISH:
            onNotifyFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
    }
    
    // This method is called to put up an notification to the user that the repsonse is being processed
    public func onNotifyStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement is up.
    public func onNotifyInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement has been
    // dismissed.
    public func onNotifyFinish(requestState : RequestStateEventData) {
        
    }
    
    
    
    public func onAck(requestState : RequestStateEventData) {
        switch (requestState.state) {
        case RequestState.S_ACK_START:
            onAckStart(requestState)
            break
        case RequestState.S_ACK_IN_PROGRESS:
            onAckInProgress(requestState)
            break
        case RequestState.S_ACK_FINISH:
            onAckFinish(requestState)
            break
        default:
            BLog.logger.error("Bad requestState \(requestState.state)")
        }
    }
    
    // This method is called to put up an acknowledgement to the user
    public func onAckStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement is up.
    public func onAckInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement has been
    // dismissed.
    public func onAckFinish(requestState : RequestStateEventData) {
        
    }

}