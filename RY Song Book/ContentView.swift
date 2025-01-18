//
//  ContentView.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-07-28.
//

import SwiftUI

struct ContentView: View {
//    @Environment(\.managedObjectContext) var viewContext
//    @FetchRequest(sortDescriptors: []) var songs: FetchedResults<Song>
    @EnvironmentObject var songs: Songs
    @State var showSongSheet = false
    @State var filter1 = "All"
    @State var filter2 = "All"
    @State var inverseFilter = ""
    @State var randomized = false
    @State var random: Song? = nil
    @State private var searchText = ""
    @State private var inverseSearch = false
    @State private var privateMode = false
    @FocusState var searchFocus: Bool
    var body: some View {
        NavigationStack {
            HStack {
                Text("\(privateMode ? "" : "RY ")Song Book").font(.system(size: 34, weight: .bold))
                    .onTapGesture {
                        privateMode.toggle()
                        songs.refresh(private: privateMode)
                    }
                Spacer()
            }.padding(.horizontal)
            HStack {
                Button(action: {
                    randomized = true
                    random = songs.list.randomElement()!
                }, label: { Text("Random") })
                if (randomized) {
                    Button(action: {
                        randomized = false
                    }, label: { Image(systemName: "x.circle")} )
                }
            }
            List {
                ForEach(songs.list.filter{
                    searchText.isEmpty ?
                        randomized ?
                            $0.id == random!.id :
                            (inverseSearch ?
                                !$0.origin.contains(inverseFilter) :
                                true) &&
                            (filter1 == "All" ?
                                true :
                                filter2 == "All" ?
                                    $0.origin.contains(filter1) :
                                    $0.origin.contains(filter1) && $0.origin.contains(filter2)) :
                        $0.title.contains(searchText)
                }) { song in
                    NavigationLink {
                        SongView(song: song, $privateMode)
                            .navigationBarTitleDisplayMode(.inline)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(song.title).font(.title3).bold()
                            Text(song.origin).font(.caption)
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            searchFocus.toggle()
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .imageScale(.medium)
                        })
                        TextField("", text: $searchText)
                            .focused($searchFocus)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 0) {
                        Picker("Filter", selection: $filter1) {
                            Text("All").tag("All")
                            ForEach(Array(Set(songs.list.map{$0.origin.components(separatedBy: "-")[0]}).sorted()), id: \.self) { i in
                                Text("\(i)").tag(i)
                            }
                        }.labelsHidden()
                        if (inverseSearch) {
                            Picker("Filter", selection: $inverseFilter) {
                                Text("-").tag("")
                                ForEach(Array(Set(songs.list.map{$0.origin.components(separatedBy: "-")[0]}).sorted()), id: \.self) { i in
                                    Text("\(i)").tag(i)
                                }
                            }.labelsHidden()
                            .onTapGesture(count: 2) {
                                inverseSearch.toggle()
                            }
                        } else {
                            Text("-")
                                .onTapGesture(count: 2) {
                                    inverseSearch.toggle()
                                }
                                .padding(.horizontal, 12)
                        }
                        Picker("Filter", selection: $filter2) {
                            Text("All").tag("All")
                            ForEach(Array(Set(songs.list.filter{$0.origin.contains("-") && $0.origin.contains(filter1)}.map{$0.origin.components(separatedBy: "-")[1]}).sorted()), id: \.self) { i in
                                Text("\(i)").tag(i)
                            }
                        }.labelsHidden()
                        if (privateMode) {
                            Button(action: {
                                showSongSheet = true
                            }, label: {
                                Image(systemName: "plus.circle")
                                    .imageScale(.large)
                            })
                        }
                    }
                }
            }
            .sheet(isPresented: $showSongSheet, content: {
                AddSongView()
            })
            .onAppear {songs.refresh(private: privateMode)}
            .refreshable {songs.refresh(private: privateMode)}
        }
    }
    
//    private func loadSongs() {
//        CKSong.fetch { (results) in
//            switch results {
//                case .success(let newSongs):
//                    self.songs.list = newSongs
//                case .failure(let error):
//                    print(error)
//            }
//        }
//    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let songs = Songs()
        return ContentView().environmentObject(songs)
    }
}
