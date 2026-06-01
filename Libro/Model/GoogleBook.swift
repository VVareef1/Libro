//
//  Book.swift
//  Libro
//
//  Created by Rana on 15/12/1447 AH.
//

import Foundation

struct GoogleBook: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let thumbnailURL: String?
    let pageCount: Int
}
