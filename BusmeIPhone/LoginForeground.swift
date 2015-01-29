//
//  LoginForeground.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class LoginEventData {
    var loginManager : LoginManager
    init(loginManager : LoginManager) {
        self.loginManager = loginManager
    }
}

class LoginForeground : BuspassEventListener {
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
            case LoginState.LS_LOGIN:
                passwordLogin(eventData!)
                break
            case LoginState.LS_REGISTER:
                registerLogin(eventData!)
                break
            case LoginState.LS_LOGGED_IN, LoginState.LS_LOGGED_OUT:
                dismiss(eventData!)
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
        }
        
    }
    
    func passwordLogin(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        if !login.quiet {
            presentPassordLogin(eventData)
        }
    }
    
    func presentPassordLogin(eventData : LoginEventData) {
        // Collect User/DriverAuthCode
        onSubmit(eventData)
    }
    
    func registerLogin(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        if !login.quiet {
            presentRegisterLogin(eventData)
        }
    }
    
    func presentRegisterLogin(eventData : LoginEventData) {
        // Collect User/Password/DriverAuthCode
        onSubmit(eventData)
    }
    
    func dismiss(eventData : LoginEventData) {
        
    }
    func presentError(eventData : LoginEventData) {
        onContinue(eventData)
    }
    
    func presentConfirmation(eventData : LoginEventData) {
        onContinue(eventData)
    }
    
    func onCancel(eventData : LoginEventData) {
        
    }
    
    func onSubmit(eventData : LoginEventData) {
        dismiss(eventData)
        api.bgEvents.postEvent("LoginEvent", data: eventData)
    }

    func onContinue(eventData : LoginEventData) {
        dismiss(eventData)
        eventData.loginManager.exitProtocol()
        api.uiEvents.postEvent("LoginEvent", data: eventData)
    }
}

class LoginBackground : BuspassEventListener {
    var api : BuspassApi
    
    init(api : BuspassApi) {
        self.api = api
        api.bgEvents.registerForEvent("LoginEvent", listener: self)
    }
    
    func unregisterForEvents() {
        api.bgEvents.unregisterForEvent("LoginEvent", listener: self)
    }
    
    func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? LoginEventData
        if (eventData != nil) {
            let loginManager = eventData!.loginManager
            let login = loginManager.login
            loginManager.enterProtocol(newLogin: login)
            api.uiEvents.postEvent("LoginEvent", data: eventData!)
        }
    }
}