//
//  LoginForeground.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/10/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class LoginEventData {
    public var loginManager : LoginManager
    public init(loginManager : LoginManager) {
        self.loginManager = loginManager
    }
}

public class LoginForeground : BuspassEventListener {
    public var api : BuspassApi
    
    
    public init(api : BuspassApi) {
        self.api = api
        api.uiEvents.registerForEvent("LoginEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
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
    
    public func passwordLogin(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        if !login.quiet {
            presentPassordLogin(eventData)
        }
    }
    
    public func presentPassordLogin(eventData : LoginEventData) {
        // Collect User/DriverAuthCode
        onSubmit(eventData)
    }
    
    public func registerLogin(eventData : LoginEventData) {
        let login = eventData.loginManager.login
        if !login.quiet {
            presentRegisterLogin(eventData)
        }
    }
    
    public func presentRegisterLogin(eventData : LoginEventData) {
        // Collect User/Password/DriverAuthCode
        onSubmit(eventData)
    }
    
    public func dismiss(eventData : LoginEventData) {
        
    }
    public func presentError(eventData : LoginEventData) {
        onContinue(eventData)
    }
    
    public func presentConfirmation(eventData : LoginEventData) {
        onContinue(eventData)
    }
    
    public func onCancel(eventData : LoginEventData) {
        
    }
    
    public func onSubmit(eventData : LoginEventData) {
        dismiss(eventData)
        api.bgEvents.postEvent("LoginEvent", data: eventData)
    }

    public func onContinue(eventData : LoginEventData) {
        dismiss(eventData)
        eventData.loginManager.exitProtocol()
        api.uiEvents.postEvent("LoginEvent", data: eventData)
    }
}

public class LoginBackground : BuspassEventListener {
    public var api : BuspassApi
    
    public init(api : BuspassApi) {
        self.api = api
        api.bgEvents.registerForEvent("LoginEvent", listener: self)
    }
    
    public func onBuspassEvent(event: BuspassEvent) {
        let eventData = event.eventData as? LoginEventData
        if (eventData != nil) {
            let loginManager = eventData!.loginManager
            let login = loginManager.login
            loginManager.enterProtocol(newLogin: login)
            api.uiEvents.postEvent("LoginEvent", data: eventData!)
        }
    }
}