//
//  FGLoginPresentController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/18/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class FGLoginPresentController : BuspassEventListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        api.uiEvents.registerForEvent("LoginEvent", listener: self)
    }
    
    func unregisterForEvents() {
        api.uiEvents.unregisterForEvent("LoginEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? LoginEventData
        if eventData != nil {
            let login = eventData!.loginManager.login
            switch (login.loginState) {
            case LoginState.LS_LOGGED_IN:
                Toast(title: "Logged In", message: "You are already logged in", duration: 4).show()
                break
                
            case LoginState.LS_LOGGED_OUT:
                Toast(title: "Logged Out", message: "You are now logged out", duration: 4).show()
                break
                
            case LoginState.LS_AUTHTOKEN_FAILURE, LoginState.LS_LOGIN_FAILURE, LoginState.LS_REGISTER_FAILURE:
                
                presentError(eventData!)
                break
                
            case LoginState.LS_LOGIN_SUCCESS, LoginState.LS_REGISTER_SUCCESS, LoginState.LS_AUTHTOKEN_SUCCESS:
                
                presentConfirmation(eventData!)
                break
                
            default:
                if (BLog.ERROR) { BLog.logger.error("Bad LoginState \(login.loginState)") }
            }
            eventData!.loginManager.exitProtocol()
        }
    }
    
    func presentError(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        var message : String = "Unknown Error"
        switch login.loginState {
        case LoginState.LS_LOGIN_FAILURE:
            if (login.status == "NetworkProblem") {
                message = "There was a network problem. Please check your wireless connection."
            } else if (login.status == "InvalidPassword") {
                message = "Invalid Password. Please try again"
            } else if (login.status == "NotAuthorized") {
                message = "Not authorized for the \(login.roleIntent) role."
            } else if (login.status == "NotRegistered") {
                message = "Not registered. Please register."
            } else if (login.status == "InvalidToken") {
                message = "Invalid Login Token. Please try again"
            } else {
                if (BLog.ERROR) { BLog.logger.error("Bad Login Status: \(login.status)") }
            }
            if !login.quiet {
                UIAlertView(title: "Login Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
            }
            break
        case LoginState.LS_REGISTER_FAILURE:
            
            if (login.status == "NetworkProblem") {
                message = "There was a network problem. Please check your wireless connection."
            } else if (login.status == "InvalidPassword") {
                message = "You are already registered and your password is invalid. Please login"
            } else if (login.status == "InvalidPasswordConfirmation") {
                message = "Invalid password confirmation. Please try again."
            } else if (login.status == "NotAuthorized") {
                message = "You are not authorized for the \(login.roleIntent) role."
            } else if (login.status == "NotRegistered") {
                message = "You are not registered. Please try again"
            } else if (login.status == "InvalidToken") {
                message = "Invalid Login Token. Please try again."
            } else if (login.status == "InvalidAuthCode") {
                message = "Invalid Driver Auth Code. Please try again."
            } else {
                if (BLog.ERROR) { BLog.logger.error("Bad Login Status: \(login.status)") }
            }
            if !login.quiet {
                UIAlertView(title: "Registration Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
            }
            break
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState \(login.loginState)") }
        }
    }
    
    func presentConfirmation(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        switch login.loginState {
        case LoginState.LS_LOGIN_SUCCESS:
            Toast(title: "Logged In", message: "You are logged in as \(login.roleIntent)", duration: 4).show()
            break
        case LoginState.LS_REGISTER_SUCCESS:
            Toast(title: "Registered", message: "You are registered and logged in as \(login.roleIntent)", duration: 4).show()
            break
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState \(login.loginState)") }
        }
    }
}
