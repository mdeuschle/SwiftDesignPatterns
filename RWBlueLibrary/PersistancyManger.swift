import UIKit

final class PersistancyManager {

  private var albums = [Album]()
  private var cache: URL {
    return FileManager.default.urls(for: .cachesDirectory,
                                    in: .userDomainMask)[0]
  }
  private var documents: URL {
    return FileManager.default.urls(for: .documentDirectory,
                                    in: .userDomainMask)[0]
  }
  private enum FileName {
    static var albums = "albums.json"
  }

  init() {
    let savedUrl = documents.appendingPathComponent(FileName.albums)
    var data = try? Data(contentsOf: savedUrl)
    if data == nil, let bundleUrl = Bundle.main.url(forResource: FileName.albums,
                                                    withExtension: nil) {
      data = try? Data(contentsOf: bundleUrl)
    }
    if let albumData = data,
      let decodedAlbums = try? JSONDecoder().decode([Album].self, from: albumData) {
      albums = decodedAlbums
      saveAlbums()
    }



//    let album1 = Album(title: "Best of Bowie",
//                       artist: "David Bowie",
//                       genre: "Pop",
//                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_david_bowie_best_of_bowie.png",
//                       year: "1992")
//
//    let album2 = Album(title: "It's My Life",
//                       artist: "No Doubt",
//                       genre: "Pop",
//                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_no_doubt_its_my_life_bathwater.png",
//                       year: "2003")
//
//    let album3 = Album(title: "Nothing Like The Sun",
//                       artist: "Sting",
//                       genre: "Pop",
//                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_sting_nothing_like_the_sun.png",
//                       year: "1999")
//
//    let album4 = Album(title: "Staring at the Sun",
//                       artist: "U2",
//                       genre: "Pop",
//                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_u2_staring_at_the_sun.png",
//                       year: "2000")
//
//    let album5 = Album(title: "American Pie",
//                       artist: "Madonna",
//                       genre: "Pop",
//                       coverUrl: "https://s3.amazonaws.com/CoverProject/album/album_madonna_american_pie.png",
//                       year: "2000")
//
//    albums = [album1, album2, album3, album4, album5]
  }

  private func saveAlbums() {
    let url = documents.appendingPathComponent(FileName.albums)
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(albums) else { return }
    try? data.write(to: url)
  }

  func saveImage(_ image: UIImage, fileName: String) {
    let url = cache.appendingPathComponent(fileName)
    guard let data = UIImagePNGRepresentation(image) else { return }
    try? data.write(to: url)
  }

  func getImage(with fileName: String) -> UIImage? {
    let url = cache.appendingPathComponent(fileName)
    guard let data = try? Data(contentsOf: url) else { return nil }
    return UIImage(data: data)
  }

  func getAlbums() -> [Album] {
    return albums
  }

  func addAlbum(_ album: Album, at index: Int) {
    if albums.count >= index {
      albums.insert(album, at: index)
    } else {
      albums.append(album)
    }
  }

  func removeAlbum(at index: Int) {
    if albums.count >= index {
      albums.remove(at: index)
    }
  }
}

















