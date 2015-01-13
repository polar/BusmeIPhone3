//
//  StoageSerializeController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

public class StoageSerializeController {
    public var api : BuspassApi
    public var externalStorageController : ExternalStorageController
    
    public init(api : BuspassApi, externalStorageController : ExternalStorageController) {
        self.api = api
        self.externalStorageController = externalStorageController
    }
    
    public func retrieveStorage(storage : Storage, filename : String, api : BuspassApi) -> Storage? {
        if externalStorageController.isAvailable() {
            let store = externalStorageController.deserializeObjectFromFile(storage, file: filename)
            if store != nil {
                store!.postSerialize(api, time: UtilsTime.current())
                return store!
            }
        }
        return nil
    }
    
    public func cacheStorage(storage :Storage, filename : String, api : BuspassApi) -> Bool {
        if externalStorageController.isAvailable() {
            if externalStorageController.isWriteable() {
                storage.preSerialize(api, time: UtilsTime.current())
                externalStorageController.serializeObjectToFile(storage, file: filename)
                storage.postSerialize(api, time: UtilsTime.current())
                return true
            }

        }
        return false
    }
    
}