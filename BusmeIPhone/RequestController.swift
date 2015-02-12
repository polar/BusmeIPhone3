//
//  RequestController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/13/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct RequestState {
    static let S_START = 0
    
    static let S_INQUIRE_START = 10
    static let S_INQUIRE_IN_PROGRESS = 11
    static let S_INQUIRE_FINISH = 12
    
    static let S_ANSWER_START = 20
    static let S_ANSWER_IN_PROGRESS = 21
    static let S_ANSWER_FINISH = 22
    
    static let S_REQUEST_START = 30
    static let S_REQUEST_IN_PROGRESS = 31
    static let S_REQUEST_FINISH = 32
    
    static let S_RESPONSE_START = 40
    static let S_RESPONSE_IN_PROGRESS = 41
    static let S_RESPONSE_FINISH = 42
    
    static let S_NOTIFY_START = 50
    static let S_NOTIFY_IN_PROGRESS = 51
    static let S_NOTIFY_FINISH = 52
    
    static let S_ACK_START = 60
    static let S_ACK_IN_PROGRESS = 61
    static let S_ACK_FINISH = 62
    
    var state : Int = S_START
}

class RequestStateEventData {
    var state : Int = RequestState.S_START
}

class RequestController {
    
    func onRequestState( requestState : RequestStateEventData ) {
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
    
    func onInquire(requestState : RequestStateEventData) {
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
    func onInquireStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the dialog is being put up.
    func onInquireInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the dialog is up.
    func onInquireFinish(requestState : RequestStateEventData) {
        
    }
    
    func onAnswer(requestState : RequestStateEventData) {
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
    func onAnswerStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the user answering the dialog
    func onAnswerInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the user answer is ready
    func onAnswerFinish(requestState : RequestStateEventData) {
        
    }
    
    func onRequest(requestState : RequestStateEventData) {
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
    func onRequestStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the request is in process, possibly
    // on another thread.
    func onRequestInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the background request is completed.
    func onRequestFinish(requestState : RequestStateEventData) {
        
    }

    
    func onResponse(requestState : RequestStateEventData) {
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
    func onResponseStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the response is being processed
    func onResponseInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the response has been processed.
    func onResponseFinish(requestState : RequestStateEventData) {
        
    }
    
    
    func onNotify(requestState : RequestStateEventData) {
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
    func onNotifyStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement is up.
    func onNotifyInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement has been
    // dismissed.
    func onNotifyFinish(requestState : RequestStateEventData) {
        
    }
    
    
    
    func onAck(requestState : RequestStateEventData) {
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
    func onAckStart(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement is up.
    func onAckInProgress(requestState : RequestStateEventData) {
        
    }
    
    // This method is called to signify that the acknowledgement has been
    // dismissed.
    func onAckFinish(requestState : RequestStateEventData) {
        
    }
    
    deinit {
        if BLog.DEALLOC { Eatme.add(self); BLog.logger.debug("DEALLOC") }
    }

}