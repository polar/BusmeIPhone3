//
//  Login.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/7/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public struct LoginState {
    public static let LS_LOGIN = 1
    public static let LS_LOGIN_FAILURE = 25
    public static let LS_LOGIN_SUCCESS = 27
    public static let LS_REGISTER = 5
    public static let LS_REGISTER_SUCCESS = 55
    public static let LS_REGISTER_FAILURE = 56
    public static let LS_LOGGED_IN = 6
    public static let LS_LOGGED_OUT = 7
    public static let LS_AUTHTOKEN = 9
    public static let LS_AUTHTOKEN_FAILURE = 10
    public static let LS_AUTHTOKEN_SUCCESS = 11
}

public class Login {
    
    public let LS_TRY_LIMIT : Int = 3

    
    public var status : String?
    public var reason : String?
    public var url : String?
    public var name : String?
    public var email : String?
    public var password : String?
    public var passwordConfirmation : String?
    public var driverAuthCode : String?
    public var roleIntent : String = "passenger"
    public var rolesLiteral : String?
    public var roles : [String] = [String]()
    public var authToken : String?
    public var loginState : Int = 0
    public var loginTries : Int = 0
    public var quiet : Bool = false
    
    public init() {
        
    }
    
    public func hasRole(role : String) -> Bool {
        for r in roles {
            if r == role {
                return true
            }
        }
        return false
    }
}