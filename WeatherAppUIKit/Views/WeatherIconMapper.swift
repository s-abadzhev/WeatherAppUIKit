//
//  WeatherIconMapper.swift
//  WeatherAppUIKit
//
//  Created by Sergey Abadzhev on 31.03.26.
//

import Foundation

enum WeatherIconMapper {

    static func sfSymbol(for code: Int) -> String {
        switch code {

        // MARK: - Ясно / Облачно
        case 1000: return "sun.max.fill"        // Sunny / Clear
        case 1003: return "cloud.sun.fill"      // Partly cloudy
        case 1006: return "cloud.fill"          // Cloudy
        case 1009: return "cloud.fill"          // Overcast

        // MARK: - Туман / Дымка
        case 1030: return "cloud.fog.fill"      // Mist
        case 1135: return "cloud.fog.fill"      // Fog
        case 1147: return "cloud.fog.fill"      // Freezing fog

        // MARK: - Метель / Поземок
        case 1114: return "wind.snow"           // Blowing snow
        case 1117: return "wind.snow"           // Blizzard

        // MARK: - Гроза (без осадков)
        case 1087: return "cloud.bolt.fill"     // Thundery outbreaks possible

        // MARK: - Морось / Лёгкий дождь
        case 1063: return "cloud.drizzle.fill"  // Patchy rain possible
        case 1150: return "cloud.drizzle.fill"  // Patchy light drizzle
        case 1153: return "cloud.drizzle.fill"  // Light drizzle
        case 1180: return "cloud.drizzle.fill"  // Patchy light rain
        case 1183: return "cloud.drizzle.fill"  // Light rain

        // MARK: - Ледяная морось / Ледяной дождь
        case 1072: return "cloud.sleet.fill"    // Patchy freezing drizzle possible
        case 1168: return "cloud.sleet.fill"    // Freezing drizzle
        case 1171: return "cloud.sleet.fill"    // Heavy freezing drizzle
        case 1198: return "cloud.sleet.fill"    // Light freezing rain
        case 1201: return "cloud.sleet.fill"    // Moderate or heavy freezing rain

        // MARK: - Умеренный / Сильный дождь
        case 1186: return "cloud.rain.fill"     // Moderate rain at times
        case 1189: return "cloud.rain.fill"     // Moderate rain
        case 1240: return "cloud.rain.fill"     // Light rain shower
        case 1192: return "cloud.heavyrain.fill" // Heavy rain at times
        case 1195: return "cloud.heavyrain.fill" // Heavy rain
        case 1243: return "cloud.heavyrain.fill" // Moderate or heavy rain shower
        case 1246: return "cloud.heavyrain.fill" // Torrential rain shower

        // MARK: - Дождь со снегом (мокрый снег)
        case 1069: return "cloud.sleet.fill"    // Patchy sleet possible
        case 1204: return "cloud.sleet.fill"    // Light sleet
        case 1207: return "cloud.sleet.fill"    // Moderate or heavy sleet
        case 1249: return "cloud.sleet.fill"    // Light sleet showers
        case 1252: return "cloud.sleet.fill"    // Moderate or heavy sleet showers

        // MARK: - Снег
        case 1066: return "cloud.snow.fill"     // Patchy snow possible
        case 1210: return "cloud.snow.fill"     // Patchy light snow
        case 1213: return "cloud.snow.fill"     // Light snow
        case 1216: return "cloud.snow.fill"     // Patchy moderate snow
        case 1219: return "cloud.snow.fill"     // Moderate snow
        case 1222: return "cloud.snow.fill"     // Patchy heavy snow
        case 1225: return "cloud.snow.fill"     // Heavy snow
        case 1255: return "cloud.snow.fill"     // Light snow showers
        case 1258: return "cloud.snow.fill"     // Moderate or heavy snow showers

        // MARK: - Ледяные осадки / Град
        case 1237: return "cloud.hail.fill"     // Ice pellets
        case 1261: return "cloud.hail.fill"     // Light showers of ice pellets
        case 1264: return "cloud.hail.fill"     // Moderate or heavy showers of ice pellets

        // MARK: - Гроза с дождём
        case 1273: return "cloud.bolt.rain.fill" // Patchy light rain with thunder
        case 1276: return "cloud.bolt.rain.fill" // Moderate or heavy rain with thunder

        // MARK: - Гроза со снегом
        case 1279: return "cloud.bolt.fill"     // Patchy light snow with thunder
        case 1282: return "cloud.bolt.fill"     // Moderate or heavy snow with thunder

        default:
            assertionFailure("⚠️ WeatherIconMapper: необработанный код условия \(code). Добавь его в sfSymbol(for:).")
            return "cloud.fill"
        }
    }
}
