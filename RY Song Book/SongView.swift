//
//  SongView.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-07-28.
//

import SwiftUI

@MainActor
struct SongView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.displayScale) var displayScale
    let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let capos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    @State var chords: [String] = []
    var song: Song
    @State var showChords: Bool = false
    @State var hideChords: Bool = false
    @State var autoScroll: Bool = false
    @State var showCapoChange: Bool = false
    @State var capoKey: Int
    @State var showSongSheet = false
    @State var showConfirmation = false
    @State var textSize: CGFloat = 17
    @Binding var privateMode: Bool
    init(song: Song, _ privateMode: Binding<Bool>) {
        self.song = song
        self._capoKey = State<Int>(initialValue: capos[Int(song.capo)])
        self._privateMode = privateMode
    }
    var body: some View {
        VStack {
            VStack {
//                #if targetEnvironment(macCatalyst)
//                ZStack {
//                    Text(song.title).font(.largeTitle)
//                    HStack {
//                        Spacer()
//                        Stepper("", value: $textSize, in: 10...50)
//                    }.padding(.horizontal)
//                }
//                #else
//                ZStack(alignment: .trailing) {
//                    Text(song.title).font(.largeTitle)
//                    Stepper("", value: $textSize, in: 10...32)
//                        .scaleEffect(0.75)
//                }
//                #endif
                VStack {
                    Text(song.title).font(.largeTitle)
                }
                HStack {
                    Text("Capo \(song.capo)").font(.system(size: 17))
                    Image(systemName: "chevron.up")
                        .rotationEffect(showChords ? .zero : .degrees(180))
                }.onTapGesture {
                    showChords.toggle()
                }
                if showChords {
                    //Chords
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(chords, id: \.self) { chord in
                            let image = FileManager.default.getImageInBundle(bundlePath: "Chords.bundle/\(chord.replacingOccurrences(of: "/", with: "-"))")
                            #if os(iOS)
                            Image(uiImage: image ?? UIImage(systemName: "questionmark.app")!)
                                .resizable()
                                .scaledToFit()
                            #elseif os(macOS)
                            Image(nsImage: image ?? NSImage(systemSymbolName: "questionmark.app", accessibilityDescription: nil)!)
                                .resizable()
                                .scaledToFit()
                            #endif
                        }
                    }
                    #if targetEnvironment(macCatalyst)
                    .frame(maxWidth: 300)
                    #endif
                    //Strumming
                    if song.strummingpattern != "" {
                        Text("Strumming:").bold()
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ]) {
                            ForEach(Array(song.strummingpattern)[0..<Array(song.strummingpattern).count].indices, id: \.self) { i in
                                VStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2))
                                            .frame(width: 35, height: 35)
                                        VStack {
                                            Image(systemName: Array(song.strummingpattern)[i] == "D" ? "chevron.down" : Array(song.strummingpattern)[i] == "U" ? "chevron.up" : "line.3.horizontal")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    Text("\(((i % 2) != 0) ? "&" : "\(i/2+1)")")
                                }
                            }
                        }.padding(.horizontal)
                        #if targetEnvironment(macCatalyst)
                        .frame(maxWidth: 500)
                        #endif

//                        HStack {
//                            ForEach(Array(song.strummingpattern!)[0..<Array(song.strummingpattern!).count/2].indices, id: \.self) { i in
//                                VStack {
//                                    HStack {
//                                        let strum1 = Array(song.strummingpattern!)[i+i*1]
//                                        let strum2 = Array(song.strummingpattern!)[i+i*1+1]
//                                        Image(systemName: strum1=="D" ? "arrow.down" : strum1=="U" ? "arrow.up" : "directcurrent")
//                                            .frame(width: 10, height: 5)
//                                        Image(systemName: strum2=="D" ? "arrow.down" : strum2=="U" ? "arrow.up" : "directcurrent")
//                                            .frame(width: 10, height: 5)
//                                    }
//                                    Text("\(i+1)  &")
//                                    Image(systemName: "space")
//                                }
//                            }
//                        }
                    }
                }
            }
            HStack {
                ScrollView {
                    ChordView(song: song, chords: $chords, capoKey: $capoKey, hideChords: $hideChords)
                }.padding(.leading, 5)
                .font(.system(size: textSize))
                Spacer()
            }
            ZStack(alignment: .top) {
                VStack {
                    Image(systemName: "chevron.up")
                        .rotationEffect(showCapoChange ? .degrees(180) : .zero)
                        .onTapGesture {
                            withAnimation {
                                showCapoChange.toggle()
                            }
                        }
                        .padding(.vertical, 5)
                    if showCapoChange {
                        Text("Capo:")
                        Picker(selection: $capoKey, label: EmptyView()) {
                            ForEach(capos, id: \.self) { i in
                                Text("\(i)")
                            }
                        }.pickerStyle(SegmentedPickerStyle())
                    }
                }.padding(.horizontal)
                HStack {
                    ShareLink("", item: render(), preview: SharePreview("Shared image", image: render()))
                    Spacer()
//                    HStack {
//                        Text("Auto Scroll")
//                        Toggle("", isOn: $autoScroll).labelsHidden().toggleStyle(.switch)
//                    }.disabled(true).foregroundStyle(.gray)
                    Stepper("", value: $textSize, in: 10...32)
                        .scaleEffect(0.85)
                        .labelsHidden()
                }.padding(.horizontal, 20).padding(.bottom)
            }
        }
        .toolbar {
            if (privateMode) {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu(content: {
                        Button(action: {
                            showSongSheet = true
                        }, label: {
                            HStack {
                                Text("Copy")
                                Image(systemName: "doc.on.doc")
                            }
                        })
                        Button(action: {
                            showConfirmation = true
                        }, label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                            }
                        })
                    }, label: {
                        Image(systemName: "square.and.pencil.circle")
                    })
                }
            }
            ToolbarItem(placement: .principal) {
                Toggle("Hide Chords", isOn: $hideChords)
            }
//            ToolbarItem(placement: .topBarTrailing) {
//                Stepper("", value: $textSize, in: 10...32)
//                    .scaleEffect(0.75)
//            }
        }
        .sheet(isPresented: $showSongSheet, content: {
            AddSongView(song: song)
        })
        .confirmationDialog("Delete?", isPresented: $showConfirmation) {
            Button(action: {
                if (privateMode) {
                    dismiss()
                    CKSong.delete(song: song)
                }
            }, label: {
                HStack {
                    Text("Delete")
                    Image(systemName: "trash")
                }.foregroundStyle(.red)
            })
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this song?")
        }
    }
    
    func render() -> Image {
        let renderer = ImageRenderer(content:
            VStack {
                Text(song.title).font(.largeTitle)
                Text("Capo \(song.capo)")
                HStack {
                    ChordView(song: song, chords: $chords, capoKey: $capoKey, hideChords: $hideChords)
                    Spacer()
                }
            }.padding()
            .frame(width: CGFloat(song.song.count))
            .padding(.horizontal, 50)
        )
        renderer.scale = displayScale
        if let uiimage = renderer.uiImage {
            return Image(uiImage: uiimage)
        } else {
            return Image(systemName: "photo")
        }
    }
    
//    func render() -> URL {
//        let renderer = ImageRenderer(content:
//            VStack {
//                Text(song.title).font(.largeTitle)
//                Text("Capo \(song.capo)")
//                HStack {
//                    ChordView(song: song, chords: $chords, capoKey: $capoKey, hideChords: $hideChords)
//                    Spacer()
//                }
//            }
//        )
//        let url = URL.documentsDirectory.appending(path: "output.pdf")
//        renderer.render { size, context in
//            var box = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//            guard let pdf = CGContext(url as CFURL, mediaBox: &box, nil) else {
//                return
//            }
//            pdf.beginPDFPage(nil)
//            context(pdf)
//            pdf.endPDFPage()
//            pdf.closePDF()
//        }
//        return url
//    }
}

struct SongView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SongView(song: Song(title: "Somewhere"), .constant(true))
        }
    }
}
