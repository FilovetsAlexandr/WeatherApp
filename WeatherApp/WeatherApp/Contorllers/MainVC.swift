//
//  ViewController.swift
//  WeatherApp
//
//  Created by Alexandr Filovets on 7.12.23.
//

import UIKit
import CoreLocation
import Kingfisher

final class MainVC: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties
    
    private var temperatureLabel: UILabel!
    private var cityLabel: UILabel!
    private var weatherIconImageView: UIImageView!
    private var weatherData: Weather?
    private var shouldUpdateWeatherBasedOnLocation = true
    
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
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
        // Button
        let changeCityButton = UIButton(type: .system)
        changeCityButton.frame = CGRect(x: 50, y: 50, width: 100, height: 50)
        changeCityButton.setTitle("Change City", for: .normal)
        changeCityButton.addTarget(self, action: #selector(changeCityButtonTapped), for: .touchUpInside)
        view.addSubview(changeCityButton)
        // Labels
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
        forecastLabel.center = CGPoint(x: view.center.x, y: view.center.y + 240)
        forecastLabel.textAlignment = .center
        forecastLabel.font = UIFont.systemFont(ofSize: 18)
        forecastLabel.numberOfLines = 0
        forecastLabel.lineBreakMode = .byWordWrapping
        forecastLabel.text = "Weather forecast for the next hours"
        view.addSubview(forecastLabel)
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
        guard let location = locations.last else { return }
        
        if shouldUpdateWeatherBasedOnLocation {
            serverManager.getWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude) { [weak self] weatherData in
                if let weatherData = weatherData {
                    DispatchQueue.main.async {
                        self?.updateUI(with: weatherData)
                    }
                }
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) { print("Не удалось получить местоположение пользователя: \(error.localizedDescription)") }

    // MARK: - UI Update

    @objc func changeCityButtonTapped() {
        let alert = UIAlertController(title: "City", message: "Enter city name", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "City Name"
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if let textField = alert.textFields?.first, let cityName = textField.text {
                self?.activityIndicator.startAnimating()

                self?.serverManager.getWeatherForCity(city: cityName) { [weak self] weatherData in
                    self?.activityIndicator.stopAnimating()

                    if let weatherData = weatherData {
                        // Обновление интерфейса с данными о текущей погоде
                        DispatchQueue.main.async {
                            self?.updateUI(with: weatherData)
                        }

                        // Запрос прогноза погоды
                        self?.serverManager.getWeatherForecast(for: cityName) { forecastList in
                            if let forecastList = forecastList {
                                // Обновление интерфейса с данными о прогнозе погоды
                                DispatchQueue.main.async {
                                    self?.updateForecastUI(with: forecastList)
                                }
                            } else {
                                // Обработка случая, когда не удалось получить прогноз погоды
                                // Например, отображение сообщения об ошибке пользователю
                            }
                        }
                    } else {
                        // Обработка случая, когда не удалось получить данные о погоде
                        // Например, отображение сообщения об ошибке пользователю
                    }
                }
            }
        }
        alert.addAction(okAction)

        present(alert, animated: true, completion: nil)
    }

    private func updateUI(with weatherData: Weather) {
        self.weatherData = weatherData
        DispatchQueue.main.async {
            self.temperatureLabel.text = "\(weatherData.main.temp)°C"
            self.cityLabel.text = "\(weatherData.name), \(weatherData.sys.country)"
            if let weatherElement = weatherData.weather.first {
                let iconURLString = "https://openweathermap.org/img/wn/\(weatherElement.icon)@2x.png"
                if let iconURL = URL(string: iconURLString) {
                    self.weatherIconImageView.kf.setImage(with: iconURL)
                }
            }
        }
        shouldUpdateWeatherBasedOnLocation = false
    }

    func updateForecastUI(with forecastList: [Forecast.List]) {
        // Очищаем предыдущие представления с прогнозом погоды
        for subview in self.view.subviews {
            if subview.tag == 100 {
                subview.removeFromSuperview()
            }
        }

        let xOffset: CGFloat = 16
        let yOffset: CGFloat = self.view.bounds.height - 150
        let spacing: CGFloat = 80

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"

        for (index, forecast) in forecastList.enumerated() {
            let xPosition = xOffset + CGFloat(index) * spacing

            // Создание представления с изображением погоды
            if let weather = forecast.weather.first, let iconURL = URL(string: "https://openweathermap.org/img/w/\(weather.icon).png") {
                let imageView = UIImageView(frame: CGRect(x: xPosition + 10, y: yOffset, width: 30, height: 30))
                imageView.contentMode = .scaleAspectFit
                imageView.kf.setImage(with: iconURL)
                imageView.tag = 100 // Используем тег для последующего удаления представлений
                self.view.addSubview(imageView)
            }

            // Создание метки со временем
            let timeLabel = UILabel(frame: CGRect(x: xPosition, y: yOffset - 25, width: 60, height: 20))
            timeLabel.textAlignment = .center
            timeLabel.font = UIFont.systemFont(ofSize: 12)
            timeLabel.textColor = .black
            let date = Date(timeIntervalSince1970: TimeInterval(forecast.dt))
            timeLabel.text = dateFormatter.string(from: date)
            timeLabel.tag = 100 // Используем тег для последующего удаления представлений
            self.view.addSubview(timeLabel)

            // Создание метки с температурой
            let temperatureLabel = UILabel(frame: CGRect(x: xPosition, y: yOffset + 40, width: 60, height: 20))
            temperatureLabel.textAlignment = .center
            temperatureLabel.font = UIFont.systemFont(ofSize: 12)
            temperatureLabel.textColor = .black
            let temperatureCelsius = forecast.main.temp - 273.15
            let roundedTemperature = String(format: "%.2f", temperatureCelsius)
            temperatureLabel.text = "\(roundedTemperature)°C"
            temperatureLabel.tag = 100 // Используем тег для последующего удаления представлений
            self.view.addSubview(temperatureLabel)
        }
    }
}
