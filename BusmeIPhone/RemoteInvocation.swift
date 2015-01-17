//
//  RemoteInvocation.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public protocol ArgumentPreparer {
    func getArguments() -> [String:[String]]?
}
public protocol ResponseProcessor {
    func onResponse(response : Tag) -> Void
}

public protocol InvocationProgress {
    func onUpdateStart(time : TimeValue64, isForced : Bool)
    func onArgumentsStart()
    func onArgumentsFinish(makeRequest : Bool)
    func onRequestStart(time : TimeValue64)
    func onRequestIOError(status : HttpStatusLine)
    func onRequestFinish(time : TimeValue64)
    func onResponseStart()
    func onResponseFinish()
    func onUpdateFinish(makeRequest : Bool, time : TimeValue64)
}

public struct InvocationProgressEvent {
    public static let U_START = 1
    public static let U_ARG_START = 2
    public static let U_ARG_FIN = 3
    public static let U_REQ_START = 4
    public static let U_REQ_IOERROR = 5
    public static let U_REQ_FIN = 6
    public static let U_RESP_START = 7
    public static let U_RESP_FIN = 8
    public static let U_FINISH = 9
}

public class InvocationProgressListener : InvocationProgress {
    let U_START = InvocationProgressEvent.U_START
    let U_ARG_START = InvocationProgressEvent.U_ARG_START
    let U_ARG_FIN = InvocationProgressEvent.U_ARG_FIN
    let U_REQ_START = InvocationProgressEvent.U_REQ_START
    let U_REQ_IOERROR = InvocationProgressEvent.U_REQ_IOERROR
    let U_REQ_FIN = InvocationProgressEvent.U_REQ_FIN
    let U_RESP_START = InvocationProgressEvent.U_RESP_START
    let U_RESP_FIN = InvocationProgressEvent.U_RESP_FIN
    let U_FINISH = InvocationProgressEvent.U_FINISH

    public func onUpdateStart(time : TimeValue64, isForced : Bool) { }
    public func onArgumentsStart() { }
    public func onArgumentsFinish(makeRequest : Bool) { }
    public func onRequestStart(time : TimeValue64) { }
    public func onRequestIOError(status : HttpStatusLine) { }
    public func onRequestFinish(time : TimeValue64) { }
    public func onResponseStart() { }
    public func onResponseFinish() { }
    public func onUpdateFinish(makeRequest : Bool, time : TimeValue64) { }
}

public class RemoteInvocation {
    public var api : ApiBase
    public var requestUrl : String?
    public var argumentPreparers : [ArgumentPreparer] = [ArgumentPreparer]()
    public var responseProcessors : [ResponseProcessor] = [ResponseProcessor]()
    
    public init(api :ApiBase, url : String?) {
        self.api = api
        self.requestUrl = url
    }
    
    public func getRequestUrl() -> String? {
        return requestUrl
    }
    
    public func addArgumentPreparer(ap : ArgumentPreparer) {
        self.argumentPreparers.append(ap)
    }
    
    public func addResponseProcessor(rp :ResponseProcessor) {
        self.responseProcessors.append(rp)
    }
    
    public func invoke(progress : InvocationProgressListener?, isForced : Bool) {
        if (progress != nil) { progress!.onUpdateStart(UtilsTime.current(), isForced: isForced)}
        let requestUrl = getRequestUrl()
        if requestUrl == nil {
            if (progress != nil) {
                let status = HttpStatusLine(statusCode: 1000, reasonPhrase: "No URL")
                progress!.onRequestIOError(status)
                progress!.onRequestFinish(UtilsTime.current())
            }
            return
        }
        var makeRequest = false
        if (progress != nil) { progress!.onArgumentsStart() }
        var parameters = [String:[String]]()
        for preparer in argumentPreparers {
            let args = preparer.getArguments()
            if (args != nil) {
                for key in args!.keys {
                    if (parameters[key] == nil) {
                        parameters[key] = args![key]
                    } else {
                        var values = parameters[key]! as [String]
                        values += args![key]! as [String]
                        parameters[key] = values
                    }
                }
                makeRequest = true
            }
        }
        if (progress != nil) { progress!.onArgumentsFinish(makeRequest) }
        if makeRequest {
            if (progress != nil) { progress!.onRequestStart(UtilsTime.current()) }
            var response = api.postURLResponse(requestUrl!, parameters: parameters)
            var tag : Tag? = nil
            if (response.getStatusLine().statusCode != 200) {
                if (progress != nil) { progress!.onRequestIOError(response.getStatusLine()) }
            } else {
                tag = api.xmlParse(response.getEntity())
            }
            if (progress != nil) { progress!.onRequestFinish(UtilsTime.current()) }
            if (progress != nil) { progress!.onResponseStart() }
            if handleResponse(tag) {
                for rp in responseProcessors {
                    rp.onResponse(tag!)
                }
            }
            if (progress != nil) { progress!.onResponseFinish() }
        }
        if (progress != nil) { progress!.onUpdateFinish(makeRequest, time: UtilsTime.current())}
    }
    
    public func handleResponse( tag : Tag?) -> Bool {
        return tag != nil
    }
}