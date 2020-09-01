//
//  TableViewController.swift
//  NearByApp
//
//  Created by Vladimir Terzievski on 8/31/20.
//  Copyright © 2020 Vladimir Terzievski. All rights reserved.
//

import UIKit
import CoreLocation


enum State:  Int {
    case realTime =  0
    case singleTime
}

class ViewController: UIViewController {
    
 
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationButton: UIBarButtonItem!
    
    var state:State = .realTime
    
    @IBAction func navigationButtonAction(_ sender: Any) {
        saveState()
    }
    
    let locationManager = CLLocationManager()
    
    var nearByLocations:[NearByLocations]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkLocation()
        
        registerCell()
        
        self.tableView.dataSource = self
        
        checkState()
        
    }
    
    
    func checkState() {
        
        let checkState = UserDefaults.standard.value(forKey: "state") as? Int
        
        if checkState == 0 {
            state = .realTime
            navigationButton.title = "Realtime"
        }else  if checkState == 1{
            navigationButton.title = "Single update"
            state = .singleTime
        }
        
    }
    
    
    func saveState() {
        
        if state == .realTime {
            state = .singleTime
        }else {
            state = .realTime
        }
        
        UserDefaults.standard.set(state.rawValue, forKey: "state")
        checkState()
        
      
    }
    func registerCell(){
        let cell = UINib(nibName: "NearByLocationTableViewCell", bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: "NearByLocationTableViewCell")
    }
    
    func makeApiCall(cordinates:CLLocation) {
        NetworkManager.shared.makeApiCall(cordinates: cordinates) { (nearByLocations, error) in
            if let error = error {
                //TODO: handle error
                debugPrint(error.localizedDescription)
                return
            }
            self.nearByLocations = nearByLocations
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func checkLocation() {
        let status = CLLocationManager.authorizationStatus()
        locationManager.delegate = self
        locationManager.distanceFilter = 1000
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        switch status {
        case .notDetermined:
            // show the alert view for thes user
            locationManager.requestWhenInUseAuthorization()
            return
        case .denied:
            // show a message to user, that he/she needs to enable location under Settings/privacy
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Warning : location servicies is denied", message: "This app must use location servicies", preferredStyle: .alert)
                
                let settings = UIAlertAction(title: "Go to Settings", style: .default) { (action:UIAlertAction) in
                    if let BUNDLE_IDENTIFIER = Bundle.main.bundleIdentifier,
                        let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(BUNDLE_IDENTIFIER)") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                    print("You've pressed cancel");
                }
                
                alertController.addAction(settings)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            }
            return
        default:
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last {
//            debugPrint("latitude  \(location.coordinate.latitude) --- longitude \(location.coordinate.longitude)")
            
            self.makeApiCall(cordinates: location)
        
            manager.stopUpdatingLocation()
            manager.delegate = nil
        }
    }
}


extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let nearByLocations = nearByLocations {
           return  nearByLocations.count
        }
        return 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "NearByLocationTableViewCell", for: indexPath) as? NearByLocationTableViewCell{
            if let nearByPlaces = nearByLocations {
                cell.populateCellWithModel(model:  nearByPlaces[indexPath.row])
            }
            return cell
        }
        return(UITableViewCell())
        
    }
    
    
}



