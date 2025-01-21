//
//  Network.swift
//  TicTacToe
//
//  Created by Келлер Дмитрий on 21.01.2025.
//

import Foundation

final class Network {
    let session: URLSession
    let decoder: JSONDecoder
    
    init(session: URLSession, decoder: JSONDecoder) {
        self.session = session
        self.decoder = decoder
    }
}
