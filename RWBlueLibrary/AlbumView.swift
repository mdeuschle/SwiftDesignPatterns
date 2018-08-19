import UIKit

class AlbumView: UIView {
  
  private var coverImageView: UIImageView!
  private var indicatorView: UIActivityIndicatorView!
  private var valueObservation: NSKeyValueObservation!
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  init(frame: CGRect, coverUrl: String) {
    super.init(frame: frame)
    commonInit()
    let userInfo: [String: Any] = [
      "coverImageView": coverImageView,
      "coverUrl": coverUrl
    ]
    NotificationCenter.default.post(name: .DownloadImage,
                                    object: self,
                                    userInfo: userInfo)
  }
  
  private func commonInit() {
    backgroundColor = .black
    coverImageView = UIImageView()
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    valueObservation = coverImageView.observe(\.image, options: [.new]) { [unowned self] observed, change in
      if change.newValue is UIImage {
        self.indicatorView.stopAnimating()
      }
    }
    addSubview(coverImageView)
    indicatorView = UIActivityIndicatorView()
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.activityIndicatorViewStyle = .whiteLarge
    indicatorView.startAnimating()
    addSubview(indicatorView)
    
    NSLayoutConstraint.activate([
      coverImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      coverImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      coverImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
      coverImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
      indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
      ])
  }
  
  func highlightAlbum(_ didHighlightView: Bool) {
    if didHighlightView == true {
      backgroundColor = #colorLiteral(red: 0.4508578777, green: 0.9882974029, blue: 0.8376303315, alpha: 1)
    } else {
      backgroundColor = .white
    }
  }
  
}
