//
//  sesstionInfoModel.swift
//  Libro
//
//  Created by Eatzaz Hafiz on 18/05/2026.
//


import Foundation


struct BookNote: Identifiable {
    let id = UUID()
    let text: String
    let page: Int
}

struct BookSession {
    let bookName: String
    let date: Date
    let timeSpent: TimeInterval
    let stoppedPage: Int
    let notes: [BookNote]
}
