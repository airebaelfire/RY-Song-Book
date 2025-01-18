//
//  AddSong.swift
//  RY Song Book
//
//  Created by Zayn Noureddin on 2023-08-01.
//

import SwiftUI
import CloudKit

struct AddSongView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var title: String
    @State var origin: String
    @State var capo: Int
    @State var song: String
    @State var strums: [Character]
    let capos = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
    let keys = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
    @State var chords: [String] = []
    @State var deletingStrums: Bool = false
    var chordDiagramsAvailable: [String] = []
    init() {
        self._title = State(initialValue: "")
        self._origin = State(initialValue: "")
        self._capo = State(initialValue: 0)
        self._song = State(initialValue: "")
        self._strums = State(initialValue: Array(""))
        for diagram in FileManager.default.getListFileNameInBundle(bundlePath: "Chords.bundle") {
            chordDiagramsAvailable.append("\(diagram.dropLast(4).replacingOccurrences(of: "-", with: "/"))")
        }
    }
    init(song: Song) {
        self._title = State(initialValue: song.title)
        self._origin = State(initialValue: song.origin)
        self._capo = State(initialValue: Int(song.capo))
        self._song = State(initialValue: song.song)
        self._strums = State(initialValue: Array(song.strummingpattern))
        for diagram in FileManager.default.getListFileNameInBundle(bundlePath: "Chords.bundle") {
            chordDiagramsAvailable.append("\(diagram.dropLast(4).replacingOccurrences(of: "-", with: "/"))")
        }
    }
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Title", text: $title)
                    TextField("Origin", text: $origin)
                }.keyboardType(.default)
                Section(header: Text("Capo")) {
                    Picker(selection: $capo, label: EmptyView()) {
                        ForEach(capos, id: \.self) { i in
                            Text("\(i)")
                        }
                    }.pickerStyle(SegmentedPickerStyle())
                }
                Section(header: Text("Song")) {
                    ScrollView(.horizontal) {
                        HStack {
                            Text("Chords Used:").foregroundColor(.secondary)
                            ForEach(chords, id: \.self) { chord in
                                Text("\(chord)")
                                    .padding(4)
                                    .padding(.horizontal, 7)
                                    .background(chordDiagramsAvailable.contains(chord) ? .green : .red)
                                    .cornerRadius(5)
                            }
                        }.onChange(of: song) { newValue in
                            chords = []
                            for i in newValue.split(separator: "[") {
                                let split = i.split(separator: "]")
                                if split.count > 1 {
                                    let chord = String(split[0])
                                    if !chord.contains("|") && !chords.contains(chord) {
                                        chords.append(chord)
                                    }
                                }
                            }
                        }
                    }
                    TextEditor(text: $song)
                }
                Section(header: Text("Strumming Pattern")) {
                        VStack {
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], alignment: .center, spacing: 20) {
                                ForEach(strums.indices, id: \.self) { i in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0.2))
                                            .frame(width: 35, height: 35)
                                        Image(systemName: strums[i] == "D" ? "chevron.down" : strums[i] == "U" ? "chevron.up" : "line.3.horizontal")
                                            .foregroundColor(deletingStrums ? .red : .blue)
                                    }.onTapGesture {
                                        if deletingStrums {
                                            strums.remove(at: i)
                                        } else {
                                            strums[i] = strums[i] == "D" ? "U" : strums[i] == "U" ? "-" : "D"
                                        }
                                    }
                                }
                            }.padding(.bottom)
                            if (strums.isEmpty) {
                                Text("___________").font(.system(size: 8))
                            }
                            HStack(alignment: .center) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0))
                                        .frame(width: 35, height: 35)
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.green)
                                }.onTapGesture {
                                    strums.append("-")
                                }
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.5, green: 0.5, blue: 0.5, opacity: 0))
                                        .frame(width: 35, height: 35)
                                    Image(systemName: deletingStrums ? "checkmark.circle" : "trash")
                                        .foregroundColor(.red)
                                }.onTapGesture {
                                    deletingStrums = !deletingStrums
                                }
                            }
                        }
                }
//                Section(header: Text("Alternate Chord Displays")) {
//                    ForEach(alternates.keys.sorted(by: <), id: \.self) { key in
//                        ZStack {
//                            HStack {
//                                TextField("", text: Binding<String>(
//                                    get: { key },
//                                    set: {
//                                        if let entry = alternates.removeValue(forKey: key) {
//                                            alternates[$0] = entry
//                                        }
//                                    }
//                                ))
//                                Spacer()
//                                TextField("", text: Binding<String>(
//                                    get: { alternates[key]! },
//                                    set: { alternates[key] = $0 }
//                                )).multilineTextAlignment(.trailing)
//                            }
//                            HStack {
//                                Divider()
//                            }.frame(maxWidth: .infinity)
//                        }.swipeActions {
//                            Button(role: .destructive) {} label: {
//                                Label("Delete", systemImage: "trash.fill")
//                            }.tint(.red)
//                        }
//                    }
//                    Image(systemName: "plus.circle")
//                        .onTapGesture {
//                            alternates[""] = ""
//                        }
//                }
            }
            .toolbar {
                #if targetEnvironment(macCatalyst)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {presentationMode.wrappedValue.dismiss()}, label: {Text("Cancel")})
                }
                #endif
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let record = CKRecord(recordType: "Song")
                        record.setValuesForKeys([
                            "title": self.title,
                            "origin": self.origin,
                            "song": self.song,
                            "capo": self.capo,
                            "strummingpattern": String(self.strums)
                        ])
                        CKSong.append(record: record)
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Text("Save")
                    })
                }
            }
        }
    }
}

#Preview {
    AddSongView()
}

//struct AddSong_Previews: PreviewProvider {
//    static var previews: some View {
//        AddSongView(song: Song(id: 0, title: "Stars", song: """
//            O my [C]lord and my [F]hope!
//            [Am]Help thou Thy [G]loved ones to [C]be
//            stead[F]fast in Thy [Am]mighty Cove[G]nant,
//            to re[C]main faith[F]ful to Thy [Am]manifest Cause[G],
//            and to [C]carry [F]out the com[Am]mandm[G]ents
//            thou di[C]ds[F]t
//            set [Am]down for the[G]m in [C]Th[F]y
//            Book of [Am]Splendou[G]rs;
//            that the[Dm]y
//            [C]may become [Am]banners of [G]guidance
//            [Dm]and lamps of the [C]Compan[Am]y
//            abo[G]ve,
//            well[F]springs of Thine [Am]infinite w[G]isdom,
//            and [Dm]stars that lead [C]aright,
//            as they [Am]shine down from the su[G]pernal sk[C]y[F].
//            [Am]Verily[G],
//            [C]art Thou [F]the In[Am]vincible[G],
//            the Al[C]mighty, [F]the All-[Am]Powerful[G].
//        """, capo: 2, origin: "Richmond", strummingpattern: "D---DUDU"))
//    }
//}
