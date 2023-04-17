import Foundation
import Combine
import AVFoundation

final class MainViewModel: ObservableObject {
    private let apiService: iTunesAPIService
    private var currentPlayer: AVPlayer?

    @Published var queryText = ""
    @Published var songs = [iTunesResponseSongModel]()
    @Published var isLoading = false

    private let fetchingCount: UInt = 50
    private var currentOffset: UInt = 0
    private var hasMoreSongs = true
    private var cancellables = Set<AnyCancellable>()

    init(apiService: iTunesAPIService) {
        self.apiService = apiService
    }

    func onAppear() {
        $queryText
            .debounce(for: .seconds(1.5), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.isLoading = true
            })
            .flatMap { [weak self] query -> AnyPublisher<iTunesResponseModel, Error> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return apiService.fetchSongs(for: query, offset: 0, count: fetchingCount)
            }
            .catch { _ in
                Just(iTunesResponseModel(resultCount: 0, results: []))
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                hasMoreSongs = !result.results.isEmpty
                currentOffset = result.resultCount
                songs = result.results
                isLoading = false
            }
            .store(in: &cancellables)
    }

    func didReachBottom() {
        guard hasMoreSongs && !isLoading else { return }

        isLoading = true

        apiService
            .fetchSongs(for: queryText, offset: currentOffset, count: fetchingCount)
            .catch { _ in
                Just(iTunesResponseModel(resultCount: 0, results: []))
            }
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                hasMoreSongs = !result.results.isEmpty
                currentOffset += result.resultCount
                songs += result.results
                isLoading = false
            }
            .store(in: &cancellables)
    }

    func play(_ song: iTunesResponseSongModel) {
        currentPlayer?.pause()
        
        currentPlayer = AVPlayer(url: song.previewUrl)
        currentPlayer?.play()
    }

}
