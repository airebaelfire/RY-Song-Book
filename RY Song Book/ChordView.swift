//
//  ChordView.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-11-30.
//

import SwiftUI

struct ChordView: View {
    let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    let capos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    var song: Song
    @Binding var capoKey: Int
    @Binding var chords: [String]
    @Binding var hideChords: Bool
    
    init(song: Song, chords: Binding<[String]>, capoKey: Binding<Int>, hideChords: Binding<Bool>) {
        self.song = song
        self._capoKey = capoKey
        self._chords = chords
        self._hideChords = hideChords
    }
    
    @ViewBuilder
    func InnerGroupView(_ group: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(group.split(separator: "\n"), id: \.self) { line in
                HStack(spacing: 0) {
                    ForEach(line.split(separator: "["), id: \.self) { i in
                        let split = i.split(separator: "]")
                        let lyrics = split.count > 1 ? split[1] : split[0]
                        VStack(alignment: .leading) {
                            if !hideChords {
                                if split.count > 1 {
                                    let chord = String(split[0])
                                    if !chord.contains("|") {
                                        let chor = (Array(chord).count > 1 ? (Array(chord)[1] == "#" ? String(Array(chord)[1]) : "") : "")
                                        let chordIndex = keys.firstIndex(where: {$0 == "\(String(Array(chord)[0]) + chor)"}) ?? 0
                                        let c = chord.dropFirst((Array(chord).count > 1 ? (Array(chord)[1] == "#" ? 2 : 1) : 1))
                                        let _chord = keys[mod((chordIndex + (Int(song.capo) - capoKey)), keys.count)] + c
                                        Text(_chord)
                                            .onAppear {
                                                if !chords.contains(where: {$0 == "\(_chord)"}) {
                                                    chords.append("\(_chord)")
                                                }
                                            }
                                    } else {
                                        Text(chord)
                                            .onAppear {
                                                for s in chord.components(separatedBy: " | ") {
                                                    if !chords.contains(where: {$0 == "\(s)"}) {
                                                        chords.append("\(s)")
                                                    }
                                                }
                                            }
                                    }
                                } else if line.split(separator: "[").count > 1 {
                                    Text(" ")
                                }
                            }
                            Text(lyrics)
                        }
                    }
                }
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(song.song.split(separator: "{"),id: \.self) { group in
                let split = group.split(separator: "}")
                if split.count > 1 {
                    ZStack(alignment: .topTrailing) {
                        GroupBox {
                            InnerGroupView(String(split[0]))
                        }.padding(.horizontal, 5)
                        Text("\(String(split[1]).split(separator: "\n")[0])")
                            .padding(.trailing)
                            .padding(.top, 5)
                            .bold()
//                        if (split[1].first != nil && split[1].first != "\n") {
//                            Text("x\(String(split[1].first!))")
//                                .padding(.trailing)
//                                .padding(.top, 5)
//                                .bold()
//                        }
                    }
                    if (split[1].first != nil) {
                        InnerGroupView(String(String(split[1]).split(separator: "\n").count > 1 ? String(split[1]).split(separator: "\n")[1...].joined(separator: "\n") : ""))
                            .padding(.horizontal)
                    }
                } else {
                    InnerGroupView(String(split[0]))
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
        }
//        VStack(alignment: .leading, spacing: 10) {
//            ForEach(song.song.split(separator: "\n"), id: \.self) { line in
//                HStack(spacing: 0) {
//                    ForEach(line.split(separator: "["), id: \.self) { i in
//                        let split = i.split(separator: "]")
//                        let lyrics = split.count > 1 ? split[1] : split[0]
//                        VStack(alignment: .leading) {
//                            if !hideChords {
//                                if split.count > 1 {
//                                    let chord = String(split[0])
//                                    if !chord.contains("|") {
//                                        let chor = (Array(chord).count > 1 ? (Array(chord)[1] == "#" ? String(Array(chord)[1]) : "") : "")
//                                        let chordIndex = keys.firstIndex(where: {$0 == "\(String(Array(chord)[0]) + chor)"}) ?? 0
//                                        let c = chord.dropFirst((Array(chord).count > 1 ? (Array(chord)[1] == "#" ? 2 : 1) : 1))
//                                        let _chord = keys[mod((chordIndex + (Int(song.capo) - capoKey)), keys.count)] + c
//                                        Text(_chord)
//                                            .onAppear {
//                                                if !chords.contains(where: {$0 == "\(_chord)"}) {
//                                                    chords.append("\(_chord)")
//                                                }
//                                            }
//                                    } else {
//                                        Text(chord)
//                                            .onAppear {
//                                                for s in chord.components(separatedBy: " | ") {
//                                                    if !chords.contains(where: {$0 == "\(s)"}) {
//                                                        chords.append("\(s)")
//                                                    }
//                                                }
//                                            }
//                                    }
//                                } else {
//                                    Text(" ")
//                                }
//                            }
//                            Text(lyrics)
//                        }
//                    }
//                }
//            }
//        }.padding()
//        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ChordView(song: Song(title: "Agapa Me", origin: "?", song: "{A[Am]gapa Me ia na se agap[F]o\nAn den Me [C]agapas i agapi [G]mu\nden bor[Am]i den bori na se [F]ftasi\nMe kanenan t[C]ropo i gnorize to af[G]to o i pireti}x2\nHi\nhi\n{[Am]O i[F]e tis [C]ipark[G]sis}2", capo: 0, strummingpattern: ""), chords: .constant([]), capoKey: .constant(2), hideChords: .constant(false))
}
