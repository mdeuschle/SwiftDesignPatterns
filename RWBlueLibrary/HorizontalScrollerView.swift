import UIKit

protocol HorizontalScrollerViewDataSource: AnyObject {
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, at indexPath: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate: AnyObject {
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectAt indexPath: Int)
}

class HorizontalScrollerView: UIView {

  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?

  private enum ViewConstant {
    static let padding: CGFloat = 10
    static let dimensions: CGFloat = 100
    static let offSet: CGFloat = 100
  }

  private let scrollView = UIScrollView()
  private var contentViews = [UIView]()

  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }

  private func initializeScrollView() {
    scrollView.delegate = self
    addSubview(scrollView)
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scrollView.topAnchor.constraint(equalTo: self.topAnchor),
      scrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ]
    )
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scrollView.addGestureRecognizer(tapGesture)
  }

  @objc private func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scrollView)
    guard let index = contentViews.index(where: { $0.frame.contains(location) }) else { return }
    delegate?.horizontalScrollerView(self, didSelectAt: index)
    scrollToView(at: index)
  }

  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffCenterX = targetCenter.x - (scrollView.bounds.width / 2)
    let cgPoint = CGPoint(x: targetOffCenterX, y: 0)
    scrollView.setContentOffset(cgPoint, animated: animated)
  }

  func view(at index: Int) -> UIView {
    return contentViews[index]
  }

  func reload() {
    guard let dataSource = dataSource else { return }
    contentViews.forEach { $0.removeFromSuperview() }
    var xValue = ViewConstant.offSet
    contentViews = (0..<dataSource.numberOfViews(in: self)).map { index in
      xValue += ViewConstant.padding
      let view = dataSource.horizontalScrollerView(self, at: index)
      view.frame = CGRect(x: CGFloat(xValue),
                          y: ViewConstant.padding,
                          width: ViewConstant.dimensions,
                          height: ViewConstant.dimensions)
      scrollView.addSubview(view)
      xValue += ViewConstant.dimensions + ViewConstant.padding
      return view
    }
    scrollView.contentSize = CGSize(width: CGFloat(xValue + ViewConstant.offSet),
                                    height: frame.size.height)
  }

  private func centerCurrentView() {
    let centerRect = CGRect(origin: CGPoint(x: scrollView.bounds.midX - ViewConstant.padding, y: 0),
                            size: CGSize(width: ViewConstant.padding, height: bounds.height))
    guard let selectedIndex = contentViews.index(where: { $0.frame.intersects(centerRect) }) else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scrollView.bounds.width / 2)
    let cgPoint = CGPoint(x: targetOffsetX, y: 0)
    scrollView.setContentOffset(cgPoint, animated: true)
    delegate?.horizontalScrollerView(self, didSelectAt: selectedIndex)
  }
}

extension HorizontalScrollerView: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}

