import Foundation

struct iTunesResponseModel: Decodable {
    let resultCount: UInt
    let results: [iTunesResponseSongModel]
}

struct iTunesResponseSongModel: Decodable, Identifiable {
    let id = UUID()
    let artistName: String
    let trackName: String
    let previewUrl: URL
    let artworkUrl100: URL

    enum CodingKeys: String, CodingKey {
        case artistName
        case trackName
        case previewUrl
        case artworkUrl100
    }
}
