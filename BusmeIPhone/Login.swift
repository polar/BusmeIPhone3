//
//  Login.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

struct LoginState {
    static let LS_LOGIN = 1
    static let LS_LOGIN_FAILURE = 25
    static let LS_LOGIN_SUCCESS = 27
    static let LS_REGISTER = 5
    static let LS_REGISTER_SUCCESS = 55
    static let LS_REGISTER_FAILURE = 56
    static let LS_LOGGED_IN = 6
    static let LS_LOGGED_OUT = 7
    static let LS_AUTHTOKEN = 9
    static let LS_AUTHTOKEN_FAILURE = 10
    static let LS_AUTHTOKEN_SUCCESS = 11
}

class Login {
    
    let LS_TRY_LIMIT : Int = 3

    
    var status : String?
    var reason : String?
    var url : String?
    var name : String?
    var email : String?
    var password : String?
    var passwordConfirmation : String?
    var driverAuthCode : String?
    var roleIntent : String = "passenger"
    var rolesLiteral : String?
    var roles : [String] = [String]()
    var authToken : String?
    var loginState : Int = 0
    var loginTries : Int = 0
    var quiet : Bool = false
    
    init() {
        
    }
    
    func hasRole(role : String) -> Bool {
        for r in roles {
            if r == role {
                return true
            }
        }
        return false
    }
}