import Foundation
import Combine
import AVFoundation

@MainActor
final class MainViewModel: ObservableObject {
    private let apiService: iTunesAPIService
    private var currentPlayer: AVPlayer?

    @Published var queryText = ""
    @Published var songs = [iTunesResponseSongModel]()
    @Published var isLoading = false

    private let fetchingCount: UInt = 50
    private var currentOffset: UInt = 0
    private var hasMoreSongs = true

    init(apiService: iTunesAPIService) {
        self.apiService = apiService
    }

    func onAppear() async {
        let values = $queryText
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .values

        for await query in values {
            do {
                currentOffset = 0
                songs = []

                let result = try await fetch(query, offset: 0, count: fetchingCount)
                hasMoreSongs = !result.results.isEmpty
                currentOffset = result.resultCount
                songs = result.results
            } catch {
                isLoading = false
                print(error.localizedDescription)
            }
        }
    }

    func didReachBottom() async {
        guard hasMoreSongs && !isLoading else { return }

        do {
            let result = try await fetch(queryText, offset: currentOffset, count: fetchingCount)
            hasMoreSongs = !result.results.isEmpty
            currentOffset += result.resultCount
            songs += result.results
        } catch {
            isLoading = false
            print(error.localizedDescription)
        }
    }

    func play(_ song: iTunesResponseSongModel) {
        currentPlayer?.pause()
        
        currentPlayer = AVPlayer(url: song.previewUrl)
        currentPlayer?.play()
    }

    private func fetch(_ query: String, offset: UInt, count: UInt) async throws -> iTunesResponseModel {
        isLoading = true
        let result = try await apiService.fetchSongs(for: query, offset: offset, count: count)
        isLoading = false

        return result
    }

}
