//
//  StoageSerializeController.swift
//  BusmeIPhone
//
//  Created by Polar Humenn on 1/12/15.
//  Copyright (c) 2015 Polar Humenn. All rights reserved.
//

import Foundation

class StorageSerializeController {
    var api : BuspassApi
    var externalStorageController : ExternalStorageController
    
    init(api : BuspassApi, externalStorageController : ExternalStorageController) {
        self.api = api
        self.externalStorageController = externalStorageController
    }
    
    func retrieveStorage(filename : String, api : BuspassApi) -> Storage? {
        if externalStorageController.isAvailable() {
            let store = externalStorageController.deserializeObjectFromFile(filename)
            if store != nil {
                store!.postSerialize(api, time: UtilsTime.current())
                return store!
            }
        }
        return nil
    }
    
    func cacheStorage(storage :Storage, filename : String, api : BuspassApi) -> Bool {
        if externalStorageController.isAvailable() {
            if externalStorageController.isWriteable() {
                storage.preSerialize(api, time: UtilsTime.current())
                let result = externalStorageController.serializeObjectToFile(storage, file: filename)
                storage.postSerialize(api, time: UtilsTime.current())
                return result
            }

        }
        return false
    }
    
}