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
        temperatureLabel.font = UIFont.systemFont(ofSize: 26)
        temperatureLabel.numberOfLines = 0
        view.addSubview(temperatureLabel)

        cityLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        cityLabel.center = CGPoint(x: view.center.x, y: view.center.y + 50)
        cityLabel.textAlignment = .center
        cityLabel.font = UIFont.systemFont(ofSize: 22)
        cityLabel.numberOfLines = 0
        view.addSubview(cityLabel)

        weatherIconImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        weatherIconImageView.center = CGPoint(x: view.center.x, y: view.center.y - 100)
        view.addSubview(weatherIconImageView)
        
        /// FORECAST
        
        let forecastLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        forecastLabel.center = CGPoint(x: view.center.x, y: view.center.y + 200)
        forecastLabel.textAlignment = .center
        forecastLabel.font = UIFont.systemFont(ofSize: 18)
        forecastLabel.numberOfLines = 0
        forecastLabel.lineBreakMode = .byWordWrapping
        forecastLabel.text = "Weather forecast for the next 6 hours"
        view.addSubview(forecastLabel)
        
        // firstForecast +1 hour
        
        let firstForecastView = UIImageView(frame: CGRect(x: 16, y: 650, width: 30, height: 30))
        firstForecastView.contentMode = .scaleAspectFit
        firstForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(firstForecastView)

        let firstTimeForecast = UILabel(frame: CGRect(x: 16, y: 650 - 20, width: 30, height: 20))
        firstTimeForecast.textAlignment = .center
        firstTimeForecast.font = UIFont.systemFont(ofSize: 12)
        firstTimeForecast.textColor = .black
        firstTimeForecast.text = "+1"
        view.addSubview(firstTimeForecast)

        let firstTemperatureForecast = UILabel(frame: CGRect(x: 16, y: 650 + 30, width: 30, height: 20))
        firstTemperatureForecast.textAlignment = .center
        firstTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        firstTemperatureForecast.textColor = .black
        firstTemperatureForecast.text = "25°C"
        view.addSubview(firstTemperatureForecast)
        
        // secondForecast +2 hour
        
        let secondForecastView = UIImageView(frame: CGRect(x: 80, y: 650, width: 30, height: 30))
        secondForecastView.contentMode = .scaleAspectFit
        secondForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(secondForecastView)

        let secondTimeForecast = UILabel(frame: CGRect(x: 80, y: 650 - 20, width: 30, height: 20))
        secondTimeForecast.textAlignment = .center
        secondTimeForecast.font = UIFont.systemFont(ofSize: 12)
        secondTimeForecast.textColor = .black
        secondTimeForecast.text = "+2"
        view.addSubview(secondTimeForecast)

        let secondTemperatureForecast = UILabel(frame: CGRect(x: 80, y: 650 + 30, width: 30, height: 20))
        secondTemperatureForecast.textAlignment = .center
        secondTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        secondTemperatureForecast.textColor = .black
        secondTemperatureForecast.text = "25°C"
        view.addSubview(secondTemperatureForecast)
        
        // thirdForecast +3 hour
        
        let thirdForecastView = UIImageView(frame: CGRect(x: 144, y: 650, width: 30, height: 30))
        thirdForecastView.contentMode = .scaleAspectFit
        thirdForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(thirdForecastView)

        let thirdTimeForecast = UILabel(frame: CGRect(x: 144, y: 650 - 20, width: 30, height: 20))
        thirdTimeForecast.textAlignment = .center
        thirdTimeForecast.font = UIFont.systemFont(ofSize: 12)
        thirdTimeForecast.textColor = .black
        thirdTimeForecast.text = "+3"
        view.addSubview(thirdTimeForecast)

        let thirdTemperatureForecast = UILabel(frame: CGRect(x: 144, y: 650 + 30, width: 30, height: 20))
        thirdTemperatureForecast.textAlignment = .center
        thirdTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        thirdTemperatureForecast.textColor = .black
        thirdTemperatureForecast.text = "25°C"
        view.addSubview(thirdTemperatureForecast)
        
        // fourthForecast +4 hour
        
        let fourthForecastView = UIImageView(frame: CGRect(x: 208, y: 650, width: 30, height: 30))
        fourthForecastView.contentMode = .scaleAspectFit
        fourthForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(fourthForecastView)

        let fourthTimeForecast = UILabel(frame: CGRect(x: 208, y: 650 - 20, width: 30, height: 20))
        fourthTimeForecast.textAlignment = .center
        fourthTimeForecast.font = UIFont.systemFont(ofSize: 12)
        fourthTimeForecast.textColor = .black
        fourthTimeForecast.text = "+4"
        view.addSubview(fourthTimeForecast)

        let fourthTemperatureForecast = UILabel(frame: CGRect(x: 208, y: 650 + 30, width: 30, height: 20))
        fourthTemperatureForecast.textAlignment = .center
        fourthTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        fourthTemperatureForecast.textColor = .black
        fourthTemperatureForecast.text = "25°C"
        view.addSubview(fourthTemperatureForecast)
        
        // fifthForecast +5 hour
        
        let fifthForecastView = UIImageView(frame: CGRect(x: 272, y: 650, width: 30, height: 30))
        fifthForecastView.contentMode = .scaleAspectFit
        fifthForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(fifthForecastView)

        let fifthTimeForecast = UILabel(frame: CGRect(x: 272, y: 650 - 20, width: 30, height: 20))
        fifthTimeForecast.textAlignment = .center
        fifthTimeForecast.font = UIFont.systemFont(ofSize: 12)
        fifthTimeForecast.textColor = .black
        fifthTimeForecast.text = "+5"
        view.addSubview(fifthTimeForecast)

        let fifthTemperatureForecast = UILabel(frame: CGRect(x: 272, y: 650 + 30, width: 30, height: 20))
        fifthTemperatureForecast.textAlignment = .center
        fifthTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        fifthTemperatureForecast.textColor = .black
        fifthTemperatureForecast.text = "25°C"
        view.addSubview(fifthTemperatureForecast)
        
        // sixthForecast +6 hour
        
        let sixthForecastView = UIImageView(frame: CGRect(x: 336, y: 650, width: 30, height: 30))
        sixthForecastView.contentMode = .scaleAspectFit
        sixthForecastView.image = UIImage(named: "test_image_1")
        view.addSubview(sixthForecastView)

        let sixthTimeForecast = UILabel(frame: CGRect(x: 336, y: 650 - 20, width: 30, height: 20))
        sixthTimeForecast.textAlignment = .center
        sixthTimeForecast.font = UIFont.systemFont(ofSize: 12)
        sixthTimeForecast.textColor = .black
        sixthTimeForecast.text = "+6"
        view.addSubview(sixthTimeForecast)

        let sixthTemperatureForecast = UILabel(frame: CGRect(x: 336, y: 650 + 30, width: 30, height: 20))
        sixthTemperatureForecast.textAlignment = .center
        sixthTemperatureForecast.font = UIFont.systemFont(ofSize: 12)
        sixthTemperatureForecast.textColor = .black
        sixthTemperatureForecast.text = "25°C"
        view.addSubview(sixthTemperatureForecast)
        
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
