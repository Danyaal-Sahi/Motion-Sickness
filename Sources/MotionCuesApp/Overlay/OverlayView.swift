import AppKit
import Combine

final class OverlayView: NSView {
    private struct Dot {
        let base: CGPoint
        let edge: Edge
    }

    private enum Edge {
        case top
        case bottom
        case left
        case right
    }

    private let model: AppModel
    private var dots: [Dot] = []
    private var displayLink: DisplayLink?
    private var cancellables = Set<AnyCancellable>()

    init(frame: CGRect, model: AppModel) {
        self.model = model
        super.init(frame: frame)
        wantsLayer = true
        layer?.masksToBounds = false
        buildDots()
        bindModel()
        startDisplayLink()
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func layout() {
        super.layout()
        buildDots()
    }

    override func draw(_ dirtyRect: NSRect) {
        guard model.isEnabled else { return }
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.clear(bounds)

        let color = NSColor.white.withAlphaComponent(model.dotOpacity)
        context.setFillColor(color.cgColor)

        let offset = currentOffset()
        let radius = model.dotSize / 2.0

        for dot in dots {
            let edgeOffset = offsetForEdge(dot.edge, offset: offset)
            let center = CGPoint(x: dot.base.x + edgeOffset.x, y: dot.base.y + edgeOffset.y)
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: model.dotSize, height: model.dotSize)
            context.fillEllipse(in: rect)
        }
    }

    private func bindModel() {
        model.$dotsPerEdge
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.buildDots()
            }
            .store(in: &cancellables)

        model.$dotSize
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        model.$dotOpacity
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)

        model.$motionVector
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.needsDisplay = true
            }
            .store(in: &cancellables)
    }

    private func startDisplayLink() {
        displayLink = DisplayLink()
        displayLink?.start { [weak self] _ in
            self?.needsDisplay = true
        }
    }

    private func buildDots() {
        let count = max(2, model.dotsPerEdge)
        let inset: CGFloat = 24
        let width = bounds.width
        let height = bounds.height

        guard width > 0, height > 0 else { return }

        var newDots: [Dot] = []

        let topY = height - inset
        let bottomY = inset
        let leftX = inset
        let rightX = width - inset

        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count - 1)
            let x = inset + t * (width - inset * 2)
            let y = inset + t * (height - inset * 2)

            newDots.append(Dot(base: CGPoint(x: x, y: topY), edge: .top))
            newDots.append(Dot(base: CGPoint(x: x, y: bottomY), edge: .bottom))
            newDots.append(Dot(base: CGPoint(x: leftX, y: y), edge: .left))
            newDots.append(Dot(base: CGPoint(x: rightX, y: y), edge: .right))
        }

        dots = newDots
        needsDisplay = true
    }

    private func currentOffset() -> CGPoint {
        let maxOffset = min(bounds.width, bounds.height) * 0.04 * model.intensity
        let vector = model.motionVector
        return CGPoint(x: vector.x * maxOffset, y: vector.y * maxOffset)
    }

    private func offsetForEdge(_ edge: Edge, offset: CGPoint) -> CGPoint {
        switch edge {
        case .top, .bottom:
            return CGPoint(x: offset.x * 0.6, y: offset.y)
        case .left, .right:
            return CGPoint(x: offset.x, y: offset.y * 0.6)
        }
    }
}
