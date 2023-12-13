//
//  ViewController.swift
//  WeatherApp
//
//  Created by Alexandr Filovets on 7.12.23.
//

import UIKit
import CoreLocation

final class MainVC: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties

    private var temperatureLabel: UILabel!
    private var cityLabel: UILabel!
    private var weatherIconImageView: UIImageView!
    private var weatherData: Weather?
    
    private let locationManager = CLLocationManager()
    private let serverManager = ServerManager()

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
        temperatureLabel.numberOfLines = 0
        view.addSubview(temperatureLabel)

        cityLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        cityLabel.center = CGPoint(x: view.center.x, y: view.center.y + 50)
        cityLabel.textAlignment = .center
        cityLabel.font = UIFont.systemFont(ofSize: 18)
        cityLabel.numberOfLines = 0
        view.addSubview(cityLabel)

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
            serverManager.getWeatherData(latitude: latitude, longitude: longitude) { [weak self] weatherData in
                if let weatherData = weatherData {
                    self?.updateUI(with: weatherData)
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print("Не удалось получить местоположение пользователя: \(error.localizedDescription)") }

    // MARK: - UI Update

    private func updateUI(with weatherData: Weather) {
        self.weatherData = weatherData
        serverManager.updateUI(with: weatherData, cityLabel: cityLabel, temperatureLabel: temperatureLabel, weatherIconImageView: weatherIconImageView)
    }
}
