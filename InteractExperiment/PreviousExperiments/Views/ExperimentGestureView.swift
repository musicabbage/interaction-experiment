//
//  ExperimentGestureView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/10.
//

import UIKit
import SwiftUI

struct ExperimentGestureView: UIViewRepresentable {
    
    private var pencilPanClosure: (GestureView.State, CGPoint) -> Void = { _, _ in }
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
    
    func onPencilDraw(perform action: @escaping(GestureView.State, CGPoint) -> Void) -> Self {
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
    var pencilPanClosure: (State, CGPoint) -> Void = { _, _ in }
    var swipeClosure: (SwipeDirection) -> Void = { _ in }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        addGestureRecognizer(panGesture)
        
        addGestureRecognizer(createSwipeGesture(direction: .up))
        addGestureRecognizer(createSwipeGesture(direction: .right))
        addGestureRecognizer(createSwipeGesture(direction: .left))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        isPencilInput = touches.first?.type == .pencil
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
    
    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard isPencilInput else { return }
        
        let translation = gesture.location(in: self)
        switch gesture.state {
        case .began:
            pencilPanClosure(.began, translation)
        case .ended:
            pencilPanClosure(.end, translation)
        case .changed:
            pencilPanClosure(.update, translation)
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
