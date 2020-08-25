//
//  Settings.swift
//  iBeaconDemo
//
//  Created by SCS on 2019/6/18.
//  Copyright © 2019 SCS. All rights reserved.
//
import UIKit
public class Settings{
    //UI
    static let screenWidth = UIScreen.main.bounds.width
    static let screenHeight = UIScreen.main.bounds.height
    static let SingleTableRowHeight :CGFloat = 30.0
    //Init
    static let myUUID = UIDevice.current.identifierForVendor!.uuidString
    //static let senderUUID = "4EA4EE73-BEA5-46D6-9C10-1F8C56DED1A1"
    static let senderUUID:[String] = ["E8A5BB1D-4A4F-426C-B5B0-FCFF8F8704A7","4EA4EE73-BEA5-46D6-9C10-1F8C56DED1A1","E41BB142-E903-4CB9-9C47-890AEB6999C9"]
}
