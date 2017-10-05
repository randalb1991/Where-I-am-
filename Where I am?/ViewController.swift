//
//  ViewController.swift
//  Where I am?
//
//  Created by Randall Dani Barrientos Alva on 2/10/17.
//  Copyright © 2017 Randall Dani Barrientos Alva. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate/*va a responder a los cambios de localizacion*/ {

    let locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var sitesJSON: JSON!
    
    var headingSteps = 0
    var userHeading = 0.0
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudLabel: UILabel!
    @IBOutlet weak var longitudLabel: UILabel!
    @IBOutlet weak var localizameButton: UIButton!
    @IBOutlet weak var headingLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        localizameButton.isEnabled = false
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: CLLocationManager
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)//Errores. Por ejemplo sin cobertura
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Se ha cambiado la autorización de permisos? Se dispara siempre que se cambia la privacidad
        if status == .authorizedWhenInUse{
            // Solo pedimos la localizacion una vez. Existen metodos del delegado que siguen al usuario
            locationManager.requestLocation()
            
            /*
             Podemos ver una lista de la localizacion del usuario
            locationManager.allowDeferredLocationUpdates(untilTraveled: <#T##CLLocationDistance#>, timeout: 5)
             */
            
        }else{
            print ("no has activado la localizacion")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /*Se dispara cuando se activa la localizacion para conseguir la última localizacion. Ya que solo nos interesa la ultima, pero el array locations tiene todas */
        guard let location = locations.last else {
            return
        }
        userLocation = location
        self.latitudLabel.text = "\(userLocation.coordinate.latitude)"
        self.longitudLabel.text = "\(userLocation.coordinate.longitude)"
        self.localizameButton.isEnabled = true
        DispatchQueue.global().async {
            //Ejecuta la funcion de forma asincrona
            self.updatesites()
        }
    }
    
    func updatesites(){
        let url = "https://es.wikipedia.org/w/api.php?ggscoord=\(userLocation.coordinate.latitude)%7C\(userLocation.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        print(url)
        guard let urlString = URL(string: url) else { return }
        
        if let data = try? Data(contentsOf: urlString){
            sitesJSON = JSON(data)
            print(sitesJSON)
            //Heading es la direccion en la que el usuario esta mirando.
            locationManager.startUpdatingHeading()
            
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        //Para ver si se ha actualizado el heading"a donde esta mirando" del usuario
        
        DispatchQueue.main.async {
            self.userHeading = newHeading.magneticHeading //Obtiene el norte magnetico.
            self.headingLabel.text = "\(self.userHeading)"
            /*
            print("Mi heading is \(newHeading.magneticHeading) y el norte real \(newHeading.headingAccuracy)")
            self.headingSteps += 1
            if self.headingSteps<2 {return }
            self.userHeading = newHeading.magneticHeading //Obtiene el norte magnetico.
            self.locationManager.stopUpdatingHeading()
            //self.*/
            //self.createsites()
        }
    }
    
    
    
    func createsites(){
        // Será llamado cuando se sepa hacia donde esta mirando el usuario
    }
    
    // MARK: MAPS
 
    func centerMapOnLocation(location: CLLocation){
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0
        )
        
        mapView.setCenter(location.coordinate, animated: true)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.showsUserLocation = true
    }
    
    @IBAction func localizameButton(_ sender: Any) {
        guard let location = self.locationManager.location else { return}
        
        self.centerMapOnLocation(location: location)
    }
    
}



