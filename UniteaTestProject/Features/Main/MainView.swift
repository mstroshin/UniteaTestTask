import SwiftUI

struct MainView: View {
    @StateObject var viewModel: MainViewModel

    var body: some View {
        NavigationView {
            Group {
                if viewModel.songs.isEmpty {
                    if viewModel.isLoading {
                        loadingView
                    } else {
                        Color.clear
                    }
                } else {
                    listView
                }
            }
            .navigationTitle("iTunes Songs")
        }
        .searchable(text: $viewModel.queryText)
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 4) {
                ForEach(viewModel.songs) { song in
                    Button {
                        viewModel.play(song)
                    } label: {
                        songView(song)
                            .foregroundColor(.black)
                    }
                }

                if viewModel.isLoading {
                    loadingView
                } else {
                    Color.clear
                        .onAppear {
                            viewModel.didReachBottom()
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func songView(_ song: iTunesResponseSongModel) -> some View {
        HStack {
            AsyncImage(url: song.artworkUrl100) { image in
                image.resizable()
            } placeholder: {
                EmptyView()
            }
            .frame(width: 50, height: 50)

            VStack(alignment: .leading) {
                Text(song.trackName)
                    .multilineTextAlignment(.leading)

                Text(song.artistName)
                    .multilineTextAlignment(.leading)
                    .font(.caption2)
            }

            Spacer()

            Image(systemName: "play")
        }
    }

    private var loadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
                .frame(width: 50, height: 50)
            Spacer()
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel(apiService: iTunesAPIServiceMock()))
    }
}
