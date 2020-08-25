//
//  ViewController.swift
//  iBeaconDemo
//
//  Created by SCS on 2019/6/18.
//  Copyright © 2019 SCS. All rights reserved.
//
import UIKit
import CoreBluetooth
import CoreLocation
class SendViewController: UIViewController,CBPeripheralManagerDelegate {
    fileprivate var beaconRegion: CLBeaconRegion!
    fileprivate var beaconPeripheralData: NSDictionary!
    fileprivate var peripheraManager: CBPeripheralManager!
    let beaconIdentifier = UIDevice.current.name
    let switchLabel = UILabel()//发射开关的label
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheral.state:",peripheral.state.rawValue)
        switch peripheral.state {
        case .poweredOn:
            peripheraManager.startAdvertising(beaconPeripheralData as? [String : Any])//开始对外发出信号
            print("ibeacon UUID:",beaconRegion.proximityUUID)
            //print(beaconRegion.major)
            //print(beaconRegion.minor)
            print("ibeacon ID:",beaconRegion.identifier)
            print("开始发射信号")
        default:
            peripheraManager.stopAdvertising()//停止发出信号
            print("停止发出信号stop Advertising")//可print一下
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化beacon,UUID随便定义,在监听beacon消息时必须与此UUID一致,major,minor也随意,监听beacon消息可以不带这两个参数或只带major参数以筛选监听的beacon设备。
        beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: Settings.myUUID)!, major: 1, minor: 1, identifier: beaconIdentifier)

        //开关控制ibeacon发射启动
        let beaconSwitch = UISwitch(frame:CGRect(x: 150, y: 150, width: 0, height: 0))
        //开关回调事件
        beaconSwitch.addTarget(self,action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        //beaconSwitch.onTintColor = or.red//设置开关按钮的颜色
        //beaconSwitch.onImage = UIImage(named: "group_icon@2x.png")//自定义设置开关图片无效果
        //beaconSwitch.setOn(true, animated: false)//设初始为ON打开状态,否则默认是关着的
        self.view.addSubview(beaconSwitch)
        
        //发射开关的label
        switchLabel.frame = CGRect(x: 100, y: 110, width: 180, height: 50)
        switchLabel.text = "iBeacon sender switch"
        self.view.addSubview(switchLabel)
        //显示UUID
        let uuidLabel = UILabel(frame: CGRect(x: 10, y: 180, width: 365, height: 50))
        uuidLabel.text = "device uuid:" + Settings.myUUID
        print(Settings.myUUID)
        self.view.addSubview(uuidLabel)
    }

    //开关回调事件，注意“_”下划线与sender之间要有空格
    @objc func switchStateDidChange(_ sender : UISwitch){
        if(sender.isOn == true){
            //发射信号并将peripheraManager代理设置为self
            beaconPeripheralData = beaconRegion.peripheralData(withMeasuredPower: nil)
            peripheraManager = CBPeripheralManager(delegate: self, queue: nil)
        }else{
            peripheraManager.stopAdvertising()//停止发出信号
            print("停止发出信号stop Advertising")//可print一下
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
