import Foundation
import Combine

protocol iTunesAPIService {
    func fetchSongs(for query: String, offset: UInt, count: UInt) -> AnyPublisher<iTunesResponseModel, Error>
}

final class iTunesAPIServiceImpl: iTunesAPIService {
    private let session = URLSession.shared
    private let decoder = JSONDecoder()

    func fetchSongs(for query: String, offset: UInt, count: UInt) -> AnyPublisher<iTunesResponseModel, Error> {
        let baseURL = URL(string: "https://itunes.apple.com/search")!
        let params = [
            URLQueryItem(name: "term", value: query),
            URLQueryItem(name: "entity", value: "song"),
            URLQueryItem(name: "limit", value: "\(count)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        let endpoint = baseURL.appending(queryItems: params)

        return session.dataTaskPublisher(for: endpoint)
            .map(\.data)
            .decode(type: iTunesResponseModel.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
    
}

final class iTunesAPIServiceMock: iTunesAPIService {
    static let songsResponse = {
        let songURL = URL(string: "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview118/v4/68/34/3a/68343a81-007a-6401-fa3a-ec15ceea11b6/mzaf_7978572351299469140.plus.aac.p.m4a")!
        let songArtworkURL = URL(string: "https://is5-ssl.mzstatic.com/image/thumb/Music118/v4/35/7a/f1/357af137-a1fc-0810-ff15-4aa190b360d1/191924570042.jpg/100x100bb.jpg")!

        return iTunesResponseModel(
            resultCount: 2,
            results: [
                iTunesResponseSongModel(artistName: "Artist 1", trackName: "Song 1", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 2", trackName: "Song 2", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 3", trackName: "Song 3", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 4", trackName: "Song 4", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 5", trackName: "Song 5", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 6", trackName: "Song 6", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 7", trackName: "Song 7", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 8", trackName: "Song 8", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 9", trackName: "Song 9", previewUrl: songURL, artworkUrl100: songArtworkURL),
                iTunesResponseSongModel(artistName: "Artist 10", trackName: "Song 10", previewUrl: songURL, artworkUrl100: songArtworkURL)
            ]
        )
    }()

    func fetchSongs(for query: String, offset: UInt, count: UInt) -> AnyPublisher<iTunesResponseModel, Error> {
        Fail(error: NSError(domain: "", code: 1)).eraseToAnyPublisher()
    }

}
