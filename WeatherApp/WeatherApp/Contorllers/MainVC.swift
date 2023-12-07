//
//  ViewController.swift
//  WeatherApp
//
//  Created by Alexandr Filovets on 7.12.23.
//

import UIKit
import CoreLocation
import Alamofire
import Kingfisher

final class MainVC: UIViewController, CLLocationManagerDelegate {
    
    // MARK: - Properties
    
    private var temperatureLabel: UILabel!
    private var weatherIconImageView: UIImageView!
    private var weatherData: Weather?
    
    private let locationManager = CLLocationManager()
    private let apiKey = "ce2b6bfb4294fea9633ac8079482caec"
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupLocationManager()
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        temperatureLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        temperatureLabel.center = view.center
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = UIFont.systemFont(ofSize: 24)
        view.addSubview(temperatureLabel)
        
        weatherIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        weatherIconImageView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        view.addSubview(weatherIconImageView)
    }
    
    // MARK: - Setup Location Manager
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
    
     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            getWeatherData(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Не удалось получить местоположение пользователя: \(error.localizedDescription)")
    }
    
    // MARK: - Network Request
    
    private func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longitude.description)&appid=\(apiKey)&units=metric"
        
        AF.request(urlString).responseData { response in
            if let data = response.data {
                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(Weather.self, from: data)
                    print(weatherData)
                    self.updateUI(with: weatherData)
                } catch {
                    print("Ошибка декодирования данных о погоде: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - UI Update
    
    private func updateUI(with weatherData: Weather) {
        self.weatherData = weatherData
        let temperature = weatherData.main.temp
        
        DispatchQueue.main.async {
            self.temperatureLabel.text = "\(temperature)°C"

            if let weatherElement = weatherData.weather.first {
                let iconURLString = "https://openweathermap.org/img/wn/\(weatherElement.icon)@2x.png"
                if let iconURL = URL(string: iconURLString) {
                    self.weatherIconImageView.kf.setImage(with: iconURL)
                }
            }
        }
    }
}
