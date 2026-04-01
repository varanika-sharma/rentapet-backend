//
//  SupabaseJSON.swift
//  Rent a Pet
//
//  Created by Loranika Sharma on 1/5/26.
//

import Foundation

enum SupabaseJSON {
    static let isoWithFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    static let isoNoFractional: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    static let dateOnly: DateFormatter = {
        let df = DateFormatter()
        df.calendar = Calendar(identifier: .gregorian)
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = TimeZone(secondsFromGMT: 0)
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()

    static func decoder() -> JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .custom { decoder in
            let c = try decoder.singleValueContainer()

            // Supabase sometimes sends dates as strings
            if let s = try? c.decode(String.self) {
                if let dt = isoWithFractional.date(from: s) { return dt }
                if let dt = isoNoFractional.date(from: s) { return dt }
                if let dt = dateOnly.date(from: s) { return dt }
                if let t = Double(s) { return Date(timeIntervalSince1970: t) }
            }

            // Sometimes numeric timestamps
            if let t = try? c.decode(Double.self) {
                return Date(timeIntervalSince1970: t)
            }

            throw DecodingError.dataCorruptedError(in: c, debugDescription: "Unrecognized date format")
        }
        return d
    }
}
