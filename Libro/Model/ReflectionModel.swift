//
//  ReflectionModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 03/06/2026.
//

import Foundation
import SwiftData


@Model
final class BookReflection {

    var rating: Int
    var reflectionText: String
    var createdAt: Date

    init(rating: Int, reflectionText: String, createdAt: Date = .now) {
        self.rating = rating
        self.reflectionText = reflectionText
        self.createdAt = createdAt
    }
}
