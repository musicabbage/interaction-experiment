//
//  ExperimentGestureView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/10.
//

import UIKit
import SwiftUI

struct ExperimentGestureView: UIViewRepresentable {
    
    private var pencilPanClosure: (GestureView.State, DrawingModel) -> Void = { _, _ in }
    private var twoFingersSwipeClosure: (GestureView.SwipeDirection) -> Void = { _ in }
    
    func makeUIView(context: Context) -> GestureView {
        let gestureView = GestureView()
        gestureView.pencilPanClosure = pencilPanClosure
        gestureView.swipeClosure = twoFingersSwipeClosure
        return gestureView
    }
    
    func updateUIView(_ gestureView: GestureView, context: Context) {
        gestureView.pencilPanClosure = pencilPanClosure
        gestureView.swipeClosure = twoFingersSwipeClosure
    }
    
    func onPencilDraw(perform action: @escaping(GestureView.State, DrawingModel) -> Void) -> Self {
        var copy = self
        copy.pencilPanClosure = action
        return copy
    }
    
    func onTwoFingersSwipe(perform action: @escaping(GestureView.SwipeDirection) -> Void) -> Self {
        var copy = self
        copy.twoFingersSwipeClosure = action
        return copy
    }
}

class GestureView: UIView {
    enum State {
        case began, update, end
    }
    
    enum SwipeDirection {
        case up, left, right
    }
    
    private var isPencilInput: Bool = false
    var pencilPanClosure: (GestureView.State, DrawingModel) -> Void = { _, _ in }
    var swipeClosure: (SwipeDirection) -> Void = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        addGestureRecognizer(createSwipeGesture(direction: .up))
        addGestureRecognizer(createSwipeGesture(direction: .right))
        addGestureRecognizer(createSwipeGesture(direction: .left))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
#if targetEnvironment(simulator)
        isPencilInput = true
        if let window, let touchCount = event?.touches(for: window)?.count {
            isPencilInput = touchCount == 1
        }
#else
        isPencilInput = touches.first?.type == .pencil
#endif
        if isPencilInput, let touch = touches.first {
            let drawing = DrawingModel(timestamp: Date.now.timeIntervalSince1970,
                                       point: touch.preciseLocation(in: self),
                                       force: touch.force / sin(touch.altitudeAngle),
                                       azimuth: touch.azimuthAngle(in: self),
                                       altitude: touch.altitudeAngle)
            pencilPanClosure(.began, drawing)
        }
    }
    
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard isPencilInput, let touch = touches.first else { return }
        
        let drawing = DrawingModel(timestamp: Date.now.timeIntervalSince1970,
                                   point: touch.preciseLocation(in: self),
                                   force: touch.force,
                                   azimuth: touch.azimuthAngle(in: self),
                                   altitude: touch.altitudeAngle)
        pencilPanClosure(.update, drawing)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard isPencilInput, let touch = touches.first else { return }
        
        let drawing = DrawingModel(timestamp: Date.now.timeIntervalSince1970,
                                   point: touch.preciseLocation(in: self),
                                   force: touch.force,
                                   azimuth: touch.azimuthAngle(in: self),
                                   altitude: touch.altitudeAngle)
        pencilPanClosure(.end, drawing)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension GestureView {
    @objc func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            swipeClosure(.up)
        case .right:
            swipeClosure(.right)
        case .left:
            swipeClosure(.left)
        default:
            break
        }
    }
    
    func createSwipeGesture(direction: UISwipeGestureRecognizer.Direction) -> UISwipeGestureRecognizer {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        gesture.numberOfTouchesRequired = 2
        gesture.direction = direction
        return gesture
    }
}
