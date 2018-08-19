import UIKit

final class LibraryAPI {

  static let shared = LibraryAPI()
  private let httpClient = HTTPClient()
  private let persistancyManger = PersistancyManager()
  private let isOnline = false
  private init() {
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(downloadImage(with:)),
                                           name: .DownloadImage,
                                           object: nil)

  }

  @objc private func downloadImage(with notification: Notification) {
    guard let userInfo = notification.userInfo,
    let coverImageView = userInfo["coverImageView"] as? UIImageView,
    let coverUrl = userInfo["coverUrl"] as? String,
      let fileName = URL(string: coverUrl)?.lastPathComponent else { return }

    if let savedImage = persistancyManger.getImage(with: fileName) {
      coverImageView.image = savedImage
      return
    }

    DispatchQueue.global().async {
      let downloadedImage = self.httpClient.downloadImage(coverUrl) ?? UIImage()
      DispatchQueue.main.async {
        coverImageView.image = downloadedImage
        self.persistancyManger.saveImage(downloadedImage, fileName: fileName)
      }
    }
  }

  func getAlbums() -> [Album] {
    return persistancyManger.getAlbums()
  }

  func addAlbum(_ album: Album, at index: Int) {
    persistancyManger.addAlbum(album, at: index)
    if isOnline {
      httpClient.postRequest("/api/addAlbum", body: album.description)
    }
  }

  func removeAlbum(at index: Int) {
    persistancyManger.removeAlbum(at: index)
    if isOnline {
      httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
    }
  }
}


