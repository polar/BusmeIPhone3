//
//  FormController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 2/17/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation


class LoginForm : NSObject, FXForm {
    var email : String = ""
    var password : String = ""
    func fields() -> NSArray {
        return [
            [FXFormFieldKey : "email", FXFormFieldTitle: "Email", FXFormFieldType : FXFormFieldTypeEmail],
            [FXFormFieldKey : "password", FXFormFieldTitle: "Password", FXFormFieldType : FXFormFieldTypePassword]
        ]
    }
}

class LoginFormController : FXFormViewController {
    
    var loginManager : LoginManager
    var loginForm : LoginForm
    var button : UIBarButtonItem!
    init(loginManager : LoginManager) {
        self.loginManager = loginManager
        self.loginForm = LoginForm()

        super.init(nibName: nil, bundle: nil)
        self.button = UIBarButtonItem(title: "Login", style: UIBarButtonItemStyle.Plain, target: self, action: "login")
        self.formController.form = loginForm
        self.formController.delegate = self
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Are you kidding me? Why isn't this done on the navigation controller?
        self.navigationItem.title = "Login"
        self.navigationItem.rightBarButtonItem = button!
    }
    
    func login() {
        navigationController?.popToRootViewControllerAnimated(true)
        loginManager.login.loginState = LoginState.LS_LOGIN
        loginManager.login.email = loginForm.email
        loginManager.login.password = loginForm.password
        var evd = LoginEventData(loginManager: loginManager)
        loginManager.api.bgEvents.postEvent("LoginEvent", data: evd)
    }
}

class RegisterForm : NSObject, FXForm {
    var email : String = ""
    var password : String = ""
    var passwordConfirmation = ""
    var driverAuthCode : String = ""
    
    func fields() -> NSArray {
        return [
            [FXFormFieldKey : "email", FXFormFieldTitle: "Email", FXFormFieldType : FXFormFieldTypeEmail],
            [FXFormFieldKey : "password", FXFormFieldTitle: "Password", FXFormFieldType : FXFormFieldTypePassword],
            [FXFormFieldKey : "passwordConfirmation", FXFormFieldTitle: "Confirm", FXFormFieldType : FXFormFieldTypePassword],
            [FXFormFieldKey : "driverAuthCode", FXFormFieldTitle: "Driver Auth Code", FXFormFieldType : FXFormFieldTypeText],
        ]
    }

}

class RegisterFormController : FXFormViewController {
    var loginManager : LoginManager
    var loginForm : RegisterForm
    var button : UIBarButtonItem!
    init(loginManager : LoginManager) {
        self.loginManager = loginManager
        self.loginForm = RegisterForm()
        
        super.init(nibName: nil, bundle: nil)
        self.button = UIBarButtonItem(title: "Register", style: UIBarButtonItemStyle.Plain, target: self, action: "register")
        self.formController.form = loginForm
        self.formController.delegate = self
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Are you kidding me? Why isn't this done on the navigation controller?
        self.navigationItem.title = "Register"
        self.navigationItem.rightBarButtonItem = button!
    }
    
    func register() {
        navigationController?.popToRootViewControllerAnimated(true)
        loginManager.login.loginState = LoginState.LS_REGISTER
        loginManager.login.email = loginForm.email
        loginManager.login.password = loginForm.password
        loginManager.login.passwordConfirmation = loginForm.passwordConfirmation
        loginManager.login.driverAuthCode = loginForm.driverAuthCode
        if loginForm.driverAuthCode.isEmpty {
            loginManager.login.roleIntent = "passenger"
        } else {
            loginManager.login.roleIntent = "driver"
        }
        var evd = LoginEventData(loginManager: loginManager)
        loginManager.api.bgEvents.postEvent("LoginEvent", data: evd)
    }
}

