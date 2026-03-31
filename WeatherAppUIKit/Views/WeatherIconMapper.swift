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
        case 1000: return "sun.max.fill"
        case 1003: return "cloud.sun.fill"
        case 1006: return "cloud.fill"
        case 1009: return "smoke.fill"
        case 1030, 1135, 1147: return "cloud.fog.fill"
        case 1063, 1150, 1153, 1180, 1183: return "cloud.drizzle.fill"
        case 1066, 1210, 1213: return "cloud.snow.fill"
        case 1069, 1204, 1207, 1249, 1252: return "cloud.sleet.fill"
        case 1072, 1168, 1171: return "cloud.hail.fill"
        case 1087: return "cloud.bolt.fill"
        case 1114, 1117: return "wind.snow"
        case 1186, 1189: return "cloud.rain.fill"
        case 1192, 1195, 1243, 1246: return "cloud.heavyrain.fill"
        case 1198, 1201: return "cloud.rain.fill"
        case 1216, 1219, 1222, 1225, 1255, 1258: return "cloud.snow.fill"
        case 1237, 1261, 1264: return "cloud.hail.fill"
        case 1240: return "cloud.rain.fill"
        case 1273: return "cloud.bolt.rain.fill"
        case 1276: return "cloud.bolt.rain.fill"
        case 1279, 1282: return "cloud.bolt.fill"
        default: return "cloud.fill"
        }
    }
}
