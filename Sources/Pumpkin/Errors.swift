//
//  Errors.swift
//  Pumpkin
//
//  Created by Cody Kerns on 11/22/25.
//

import Foundation

public enum PumpkinError: Error {
    case invalidURL
    case noData
    case decodingError(Error)
    case httpError(statusCode: Int, data: Data?)
    case requestFailed(Error)
}
