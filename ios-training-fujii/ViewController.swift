//
//  ViewController.swift
//  ios-training-fujii
//
//  Created by 藤井 紗良 on 2023/12/11.
//

import UIKit
import YumemiWeather

final class ViewController: UIViewController {
    
    
    @IBOutlet @ViewLoading private var weatherImageView: UIImageView
    @IBOutlet @ViewLoading private var minTemperatureLabel: UILabel
    @IBOutlet @ViewLoading private var maxTemperatureLabel: UILabel
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadWeather(area: "tokyo")
    }
    
    @IBAction func weatherReloadButton() {
        
        reloadWeather(area: "tokyo")
    }
    
    func reloadWeather(area: String) -> Void {
        do {
            let weatherData = try fetchWeatherAPI(area: area)
            setWeatherUI(weatherData: weatherData)
        } catch {
            switch error {
            case is EncodingError:
                print("エンコードエラー:\(error)")
                showAlert(title: "エンコードエラー", error: error)
            case is DecodingError:
                print("デコードエラー：\(error)")
                showAlert(title: "デコードエラー", error: error)
            default:
                print("APIエラー:\(error)")
                showAlert(title: "APIエラー", error: error)
            }
        }
    }
    
    private func encodeAPIRequest(request: WeatherAPIRequest) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(request)
        return String(data: data, encoding: .utf8)!
    }
    
    private func decodeAPIResponse(responseData: String) throws -> WeatherDataModel {
        let jsonData = responseData.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
        let weatherData = try decoder.decode(WeatherDataModel.self, from: jsonData)
        return weatherData
    }
    
    private func fetchWeatherAPI(area: String) throws -> WeatherDataModel {
        let date = Date()
        let weatherAPIRequest = WeatherAPIRequest(area: area, date: date)
        let requestAPIData = try encodeAPIRequest(request: weatherAPIRequest)
        let responseAPIData = try YumemiWeather.fetchWeather(requestAPIData)
        let weatherData = try decodeAPIResponse(responseData: responseAPIData)
        return weatherData
    }
    
    private func showAlert(title: String, error: Error) {
        let alert = UIAlertController(title: title, message: "\(error)が発生しました。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "閉じる", style: .default))
        self.present(alert, animated: true)
    }
    
    private func setWeatherUI(weatherData: WeatherDataModel) {
        let weatherCondition = weatherData.weatherCondition
        let mimTemperature = String(weatherData.minTemperature)
        let maxTemperature = String(weatherData.maxTemperature)
        
        weatherImageView.image = weatherCondition.weatherImage
        weatherImageView.tintColor = weatherCondition.tintColor
        minTemperatureLabel.text = mimTemperature
        maxTemperatureLabel.text = maxTemperature
    }
    
    
    
}

