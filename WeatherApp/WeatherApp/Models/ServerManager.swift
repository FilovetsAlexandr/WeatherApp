//
//  ServerManager.swift
//  WeatherApp
//
//  Created by Alexandr Filovets on 8.12.23.
//
import UIKit
import Alamofire
import Kingfisher
import CoreLocation

final class ServerManager {
    
    private let apiKey = "ce2b6bfb4294fea9633ac8079482caec"
    
    func getWeatherData(latitude: CLLocationDegrees, longitude: CLLocationDegrees, completion: @escaping (Weather?) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude.description)&lon=\(longitude.description)&appid=\(apiKey)&units=metric"
        
        AF.request(urlString).responseData { response in
            if let data = response.data {
                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(Weather.self, from: data)
                    completion(weatherData)
                } catch {
                    print("Ошибка декодирования данных о погоде: \(error.localizedDescription)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func updateUI(with weatherData: Weather, temperatureLabel: UILabel, weatherIconImageView: UIImageView) {
        let temperature = weatherData.main.temp

        DispatchQueue.main.async {
            temperatureLabel.text = "\(temperature)°C"

            if let weatherElement = weatherData.weather.first {
                let iconURLString = "https://openweathermap.org/img/wn/\(weatherElement.icon)@2x.png"
                if let iconURL = URL(string: iconURLString) {
                    weatherIconImageView.kf.setImage(with: iconURL)
                }
            }
        }
    }
}
