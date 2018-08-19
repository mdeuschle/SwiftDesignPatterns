import UIKit

final class ViewController: UIViewController {

  @IBOutlet var tableView: UITableView!
  @IBOutlet var undoBarButtonItem: UIBarButtonItem!
  @IBOutlet var trashBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var horizontalScrollerView: HorizontalScrollerView!
    
  private var currentAlbumIndex = 0
  private var currentAlbumData: [AlbumData]?
  private var allAlbums = [Album]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    allAlbums = LibraryAPI.shared.getAlbums()
    tableView.dataSource = self
    horizontalScrollerView.dataSource = self
    horizontalScrollerView.delegate = self
    horizontalScrollerView.reload()
    showDataForAlbum(at: currentAlbumIndex)
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    horizontalScrollerView.scrollToView(at: currentAlbumIndex, animated: false)
  }

  override func encodeRestorableState(with coder: NSCoder) {
    coder.encode(currentAlbumIndex, forKey: Constant.indexRestorationKey)
    super.encodeRestorableState(with: coder)
  }

  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    currentAlbumIndex = coder.decodeInteger(forKey: Constant.indexRestorationKey)
    showDataForAlbum(at: currentAlbumIndex)
    horizontalScrollerView.reload()
  }
}

extension ViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let albumData = currentAlbumData else { return 0 }
    return albumData.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constant.cellIdentifier, for: indexPath)
    guard let currentAlbumData = currentAlbumData else { return UITableViewCell() }
    let albumData = currentAlbumData[indexPath.row]
    cell.textLabel?.textColor = .white
    cell.detailTextLabel?.textColor = .white
    cell.textLabel?.text = albumData.title
    cell.detailTextLabel?.text = albumData.value
    return cell
  }

  private func showDataForAlbum(at indexPath: Int) {
    if indexPath < allAlbums.count && indexPath > -1 {
      let album = allAlbums[indexPath]
      currentAlbumData = album.tableRepresentation
    } else {
      currentAlbumData = nil
    }
    tableView.reloadData()
  }
}

extension ViewController: HorizontalScrollerViewDelegate {
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectAt indexPath: Int) {
    let previousAlbumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    previousAlbumView.highlightAlbum(false)
    currentAlbumIndex = indexPath
    let albumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    albumView.highlightAlbum(true)
    showDataForAlbum(at: indexPath)
  }
}

extension ViewController: HorizontalScrollerViewDataSource {
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
    return allAlbums.count
  }

  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, at index: Int) -> UIView {
    let album = allAlbums[index]
    let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), coverUrl: album.coverUrl)
    if currentAlbumIndex == index {
      albumView.highlightAlbum(true)
    } else {
      albumView.highlightAlbum(false)
    }
    return albumView
  }
}

private enum Constant {
  static let cellIdentifier = "Cell"
  static let indexRestorationKey = "currentAlbumIndex"
}

