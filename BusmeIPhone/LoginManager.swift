//
//  LoginManager.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class LoginManager : BuspassEventListener {
    public let LOGIN_TRY_LIMIT = 3
    
    public var api : BuspassApi
    public var login : Login
    public var authToken : String?
    public var roleIntent : String = "passenger"
    public var email : String?
    
    public init(api : BuspassApi) {
        self.api = api
        self.login = Login()
        
    }
    
    public func enterProtocol(newLogin : Login? = nil) {
        if (newLogin != nil) { self.login = newLogin! }
        switch(login.loginState) {
        case LoginState.LS_AUTHTOKEN:
            authTokenLogin()
            break;
        case LoginState.LS_LOGIN:
            passwordLogin()
            break;
        case LoginState.LS_REGISTER:
            passwordRegistration()
            break;
        case LoginState.LS_LOGGED_IN:
            break;
        case LoginState.LS_LOGGED_OUT:
            break;
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState: \(login.loginState)") }
        }
    }
    
    public func authTokenLogin() {
        let (response, tag) = api.authTokenLogin(login)
        if tag != nil {
            login.status = tag!.attributes["status"]
            if "OK" == login.status {
                login.name = tag!.attributes["login"]
                let email = tag!.attributes["email"]
                if email != nil {
                    login.email = email
                }
                let roleIntent = tag!.attributes["roleIntent"]
                if roleIntent != nil {
                    login.roleIntent = roleIntent!
                }
                let rolesLiteral = tag!.attributes["roles"]
                if rolesLiteral != nil {
                    login.roles = rolesLiteral!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
                    login.rolesLiteral = rolesLiteral
                }
                login.authToken = tag!.attributes["authToken"]
                login.name = tag!.attributes["name"]
                login.loginState = LoginState.LS_AUTHTOKEN_SUCCESS
                return
            } else {
                let stat = tag!.attributes["reason"]
                if stat != nil {
                    login.reason = stat!
                } else {
                    login.reason = "Unknown"
                }
            }

        }
        login.loginState = LoginState.LS_AUTHTOKEN_FAILURE
    }
    
    public func passwordRegistration() {
        let (response, tag) = api.passwordRegistration(login)
        if tag != nil {
            login.status = tag!.attributes["status"]
            if "OK" == login.status {
                login.name = tag!.attributes["login"]
                let email = tag!.attributes["email"]
                if email != nil {
                    login.email = email
                }
                let roleIntent = tag!.attributes["roleIntent"]
                if roleIntent != nil {
                    login.roleIntent = roleIntent!
                }
                let rolesLiteral = tag!.attributes["roles"]
                if rolesLiteral != nil {
                    login.roles = rolesLiteral!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
                    login.rolesLiteral = rolesLiteral
                }
                login.authToken = tag!.attributes["authToken"]
                login.name = tag!.attributes["name"]
                login.loginState = LoginState.LS_REGISTER_SUCCESS
                return
            } else {
                let stat = tag!.attributes["reason"]
                if stat != nil {
                    login.reason = stat!
                } else {
                    login.reason = "Unknown"
                }
            }
            
        }
        login.loginState = LoginState.LS_REGISTER_FAILURE
    }
    
    public func passwordLogin() {
        let (response, tag) = api.passwordRegistration(login)
        if tag != nil {
            login.status = tag!.attributes["status"]
            if "OK" == login.status {
                login.name = tag!.attributes["login"]
                let email = tag!.attributes["email"]
                if email != nil {
                    login.email = email
                }
                let roleIntent = tag!.attributes["roleIntent"]
                if roleIntent != nil {
                    login.roleIntent = roleIntent!
                }
                let rolesLiteral = tag!.attributes["roles"]
                if rolesLiteral != nil {
                    login.roles = rolesLiteral!.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
                    login.rolesLiteral = rolesLiteral
                }
                login.authToken = tag!.attributes["authToken"]
                login.name = tag!.attributes["name"]
                login.loginState = LoginState.LS_LOGIN_SUCCESS
                return
            } else {
                let stat = tag!.attributes["reason"]
                if stat != nil {
                    login.reason = stat!
                } else {
                    login.reason = "Unknown"
                }
            }
            
        }
        login.loginState = LoginState.LS_LOGIN_FAILURE
    }
    
    public func exitProtocol() {
        switch(login.loginState) {
        case LoginState.LS_AUTHTOKEN_SUCCESS, LoginState.LS_AUTHTOKEN_FAILURE:
            confirmAuthTokenLogin();
            break;
        case LoginState.LS_LOGIN_SUCCESS, LoginState.LS_LOGIN_FAILURE:
            confirmPasswordLogin();
            break;
        case LoginState.LS_REGISTER_SUCCESS, LoginState.LS_REGISTER_FAILURE:
            confirmRegisterLogin();
            break;
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState: \(login.loginState)") }
        }
    }

    public func confirmPasswordLogin() {
        switch (login.loginState) {
        case LoginState.LS_LOGIN_SUCCESS:
            login.loginState = LoginState.LS_LOGGED_IN
            api.loginCredentials = login
            break;
        case LoginState.LS_LOGIN_FAILURE:
            if (login.quiet || login.loginTries >= LOGIN_TRY_LIMIT) {
                login.loginState = LoginState.LS_LOGGED_OUT
                api.loginCredentials = nil
            } else {
                if (login.status == "NetworkProblem") {
                        login.loginState = LoginState.LS_LOGIN
                } else if (login.status == "InvalidPassword") {
                        login.loginState = LoginState.LS_LOGIN
                } else if (login.status == "NotAuthorized") {
                        login.loginState = LoginState.LS_REGISTER
                        login.loginTries = 0
                } else if (login.status == "NotRegistered") {
                        login.loginState = LoginState.LS_REGISTER
                        login.loginTries = 0
                } else if (login.status == "InvalidToken") {
                        login.loginState = LoginState.LS_LOGIN
                } else {
                    if (BLog.ERROR) { BLog.logger.error("Bad Login Status: \(login.status)") }
                }
            }
            break;
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState: \(login.loginState)") }
        }
    }
    
    public func confirmRegisterLogin() {
        switch (login.loginState) {
        case LoginState.LS_REGISTER_SUCCESS:
            login.loginState = LoginState.LS_LOGGED_IN
            api.loginCredentials = login
            break;
        case LoginState.LS_REGISTER_FAILURE:
            if (login.quiet || login.loginTries >= LOGIN_TRY_LIMIT) {
                login.loginState = LoginState.LS_LOGGED_OUT
                api.loginCredentials = nil
            } else {
                if (login.status == "NetworkProblem") {
                    login.loginState = LoginState.LS_REGISTER
                } else if (login.status == "InvalidPassword") {
                    login.loginState = LoginState.LS_REGISTER
                } else if (login.status == "InvalidPasswordConfirmation") {
                    login.loginState = LoginState.LS_LOGIN
                } else if (login.status == "NotAuthorized") {
                    login.loginState = LoginState.LS_REGISTER
                    login.loginTries = 0
                } else if (login.status == "NotRegistered") {
                    login.loginState = LoginState.LS_REGISTER
                    login.loginTries = 0
                } else if (login.status == "InvalidToken") {
                    login.loginState = LoginState.LS_REGISTER
                } else {
                    if (BLog.ERROR) { BLog.logger.error("Bad Login Status: \(login.status)") }
                }
            }
            break;
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState: \(login.loginState)") }
        }
    }
    
    public func confirmAuthTokenLogin() {
        switch (login.loginState) {
        case LoginState.LS_AUTHTOKEN_SUCCESS:
            login.loginState = LoginState.LS_LOGGED_IN
            api.loginCredentials = login
            break;
        case LoginState.LS_AUTHTOKEN_FAILURE:
            if (login.quiet) {
                login.loginState = LoginState.LS_LOGGED_OUT
                api.loginCredentials = nil
            } else {
                login.loginState = LoginState.LS_LOGIN
            }
            break;
        default:
            if (BLog.ERROR) { BLog.logger.error("Bad LoginState: \(login.loginState)") }
        }
    }
    
    public func performLogout() {
        
    }


}