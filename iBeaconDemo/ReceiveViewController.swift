//
//  ReceiveViewController.swift
//  iBeaconDemo
//
//  Created by SCS on 2019/6/18.
//  Copyright © 2019 SCS. All rights reserved.
//
import UIKit
import CoreLocation
class ReceiveViewController: UIViewController,CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource {
    fileprivate var beaconRegion: [CLBeaconRegion]=[]
    fileprivate var locationManager: CLLocationManager!
    let beaconIdentifier = UIDevice.current.name
    let switchLabel = UILabel()//发射开关的label
    let LogArea = UITextView()//临时加一块显示定位log的区域
    var logTxt:String = ""
    let deviceListTableView = UITableView()
    var deviceList : [CLBeacon] = []
    @objc dynamic var lastSeenBeacon: CLBeacon!
    static func ==(item: beaconRegion, beacon: CLBeacon) -> Bool {
        return ((beacon.proximityUUID.UUIDString == item.uuid.UUIDString)
            && (Int(beacon.major) == Int(item.majorValue))
            && (Int(beacon.minor) == Int(item.minorValue)))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //初始化,UUID必须与发送时的一致，notifyEntryStateOnDisplay设置为true作用是每次点亮屏幕扫描一次beacon，经测试，如果APP未运行，或运行在后台，如果不设置为true，则系统扫描时间为15分钟左右，也就是你将APP杀死，进入beacon区域后系统最长15分钟才能唤醒你的APP。如果APP运行在前台，那么不管这个值是什么都是1s扫描一次，关于beacon扫描有一篇资料Beacon Monitoring in the Background and Foreground(https://developer.radiusnetworks.com/2013/11/13/ibeacon-monitoring-in-the-background-and-foreground.html)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        //请求一直允许定位
        locationManager.requestAlwaysAuthorization()
        for i in 0...Settings.senderUUID.count-1{
          print(Settings.senderUUID[i])
          beaconRegion.append(CLBeaconRegion(proximityUUID: UUID(uuidString: Settings.senderUUID[i])!, identifier: beaconIdentifier))
          beaconRegion[i].notifyEntryStateOnDisplay = true
        }
        //开关控制ibeacon发射启动
        let beaconSwitch = UISwitch(frame:CGRect(x: 5, y: 30, width: 0, height: 0))
        //开关回调事件
        beaconSwitch.addTarget(self,action: #selector(switchStateDidChange(_:)), for: .valueChanged)
        //beaconSwitch.onTintColor = UIColor.red//设置开关按钮的颜色
        //beaconSwitch.onImage = UIImage(named: "group_icon@2x.png")//自定义设置开关图片无效果
        //beaconSwitch.setOn(true, animated: false)//设初始为ON打开状态,否则默认是关着的
        self.view.addSubview(beaconSwitch)
        
        //发射开关的label
        switchLabel.frame = CGRect(x: 60, y: 30, width: 280, height: 30)
        switchLabel.text = "iBeacon Distance Detection switch"
        self.view.addSubview(switchLabel)
        
        //log框
        LogArea.frame = CGRect(x: 5, y: 70, width: Settings.screenWidth-10, height: (Settings.screenHeight-140)/3)
        LogArea.font = UIFont.systemFont(ofSize: 12)
        LogArea.textAlignment = .justified//最后一行自然对齐
        LogArea.layer.borderWidth = 1
        LogArea.layer.cornerRadius = 5//设置圆角
        LogArea.layer.masksToBounds = true
        LogArea.isEditable = false
        LogArea.text = logTxt
        self.view.addSubview(LogArea)
        
        //建个tableView的list,存多个设备的uuid,右侧实时显示当前距离
        //文档list
        deviceListTableView.frame = CGRect(x:5, y:(Settings.screenHeight-140)/3 + 80, width: Settings.screenWidth-10, height: (Settings.screenHeight-140)*2/3)
        deviceListTableView.backgroundColor = UIColor.clear
        deviceListTableView.layer.borderWidth = 1
        deviceListTableView.layer.cornerRadius = 5//设置圆角
        deviceListTableView.layer.masksToBounds = true
        deviceListTableView.delegate = self
        deviceListTableView.dataSource = self
        //当有副标题时,下面register其实和dequeueReusableCell冲突的,加了register的话cellForRowAtIndexPath中的[tableView dequeueReusableCellWithIdentifier:］返回的都不是nil,这样下面if里面设副标题就走不到
        //deviceListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "docListCell")
        deviceListTableView.bounces = true //允许或禁止拉动
        let view = UIView()
        //deviceListTableView.tableFooterView = view//去掉分割线
        deviceListTableView.tableHeaderView = view
        self.view.addSubview(deviceListTableView)
    }
    
    //进入beacon区域
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        for i in 0...Settings.senderUUID.count-1{
            locationManager.startRangingBeacons(in: beaconRegion[i])
        }
        print( "进入beacon区域")
    }
    
    //离开beacon区域
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        for i in 0...Settings.senderUUID.count-1{
            locationManager.stopRangingBeacons(in: beaconRegion[i])
        }
        print("离开beacon区域")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        //返回是扫描到的beacon设备数组
        print("beacons.count",beacons.count)
        guard beacons.count > 0 else { return }
        for beacon in beacons {
            for item in beaconRegion {
                // TODO: Determine if item is equal to ranged beacon
            }
        }
        deviceList = beacons
        DispatchQueue.main.async{//异步调用刷新主界面UI记得要用dispatch_get_main_queue
            self.deviceListTableView.reloadData()
        }
        let beacon = beacons.first!//这里取第一个设备
        //accuracy可以获取到当前距离beacon设备距离
        let location = String(format: "%.3f", beacon.accuracy)
        if beacon.accuracy >= 0 {//如果检测不到发送端,accuracy会变成-1
            print("距离beacon\(location)m")
            logTxt = logTxt + "距离第一个beacon设备\(location)m\n"
        }else{
            print("There is no ibeacon sender now")
            logTxt = logTxt + "There is no ibeacon sender now\n"
        }
        LogArea.text = logTxt//这句不加,区域里不会随时更新log
        let nsra:NSRange = NSMakeRange((LogArea.text.lengthOfBytes(using: String.Encoding.utf8))-1, 1)//读取textview的range
        LogArea.scrollRangeToVisible(nsra)//将textview滚动到最后一栏
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Failed monitoring region: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager failed: \(error.localizedDescription)")
    }

    //开关回调事件，注意“_”下划线与sender之间要有空格
    @objc func switchStateDidChange(_ sender : UISwitch){
        if(sender.isOn == true){
            print("开始扫描监控两设备距离")
            //开始扫描
            for i in 0...Settings.senderUUID.count-1{
                locationManager.startMonitoring(for: beaconRegion[i])
                locationManager.startRangingBeacons(in: beaconRegion[i])
            }
        }else{
            print("停止扫描监控两设备距离")
            //停止扫描
            for i in 0...Settings.senderUUID.count-1{
                locationManager.stopMonitoring(for: beaconRegion[i])
                locationManager.stopRangingBeacons(in: beaconRegion[i])
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    //cell行高
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Settings.SingleTableRowHeight)
    }
    //cell行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return deviceList.count
    }
    //cell内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //var cell = tableView.dequeueReusableCell(withIdentifier: "deviceListCell")
        //dequeueReusableCell这种重用cell方式如不register,在reload单一row或单一section时会造成cell重叠,改成下面这种
        var cell = tableView.cellForRow(at: indexPath)
        if cell == nil
        {//此处参数style 需要设置为 Subtitle或value1 才可以展示出来副标题
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "deviceListCell")
        }
        //        if (cell == nil){// 判断为空进行初始化  --（当拉动页面显示超过主页面内容的时候就会重用之前的cell，而不会再次初始化）
        //            cell = UITableViewCell.init(style: UITableViewCellStyle.subtitle,reuseIdentifier: "docListCell")
        //        }else{//当页面拉动的时候 当cell存在并且最后一个存在 把它进行删除就出来一个独特的cell我们在进行数据配置即可避免
        //            while (cell.contentView.subviews.last != nil) {
        //                cell.contentView.subviews.last?.removeFromSuperview()
        //            }
        //        }
        //cell选中时的变色
        cell?.selectedBackgroundView = UIView(frame: (cell?.frame)!)
        cell?.selectedBackgroundView?.backgroundColor = UIColor.lightGray
        cell?.textLabel?.highlightedTextColor = UIColor.darkText
        //背景色,字体等
        cell?.textLabel?.backgroundColor = UIColor.clear
        cell?.backgroundColor = UIColor.clear
        cell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        cell?.textLabel?.numberOfLines = 1
        cell?.textLabel?.text = "离\(deviceList[indexPath.row].proximityUUID)有"+"\(String(format: "%.3f", deviceList[indexPath.row].accuracy))米"
        cell?.textLabel?.lineBreakMode = .byTruncatingMiddle
        return cell!
    }
    //点击事件
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("第\(indexPath.row)条Selected")
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)//不加可能在慢手机上显示有问题?
        tableView.deselectRow(at: indexPath, animated: true)//手指离开那刻cell色变为未选中色
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
