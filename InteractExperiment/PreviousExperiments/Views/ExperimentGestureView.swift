//
//  ExperimentGestureView.swift
//  InteractExperiment
//
//  Created by cabbage on 2023/7/10.
//

import UIKit
import SwiftUI

struct ExperimentGestureView: UIViewRepresentable {
    
    private var dragClosure: (GestureView.State, CGPoint) -> Void = { _, _ in }
    private var twoFingersSwipeClosure: (GestureView.SwipeDirection) -> Void = { _ in }
    
    func makeUIView(context: Context) -> GestureView {
        let gestureView = GestureView()
        gestureView.panClosure = dragClosure
        gestureView.swipeClosure = twoFingersSwipeClosure
        return gestureView
    }
    
    func updateUIView(_ gestureView: GestureView, context: Context) {
        gestureView.panClosure = dragClosure
        gestureView.swipeClosure = twoFingersSwipeClosure
    }
    
    func onDrag(perform action: @escaping(GestureView.State, CGPoint) -> Void) -> Self {
        var copy = self
        copy.dragClosure = action
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
    
    var panClosure: (State, CGPoint) -> Void = { _, _ in }
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
        let translation = gesture.location(in: self)
        switch gesture.state {
        case .began:
            panClosure(.began, translation)
        case .ended:
            panClosure(.end, translation)
        case .changed:
            panClosure(.update, translation)
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
