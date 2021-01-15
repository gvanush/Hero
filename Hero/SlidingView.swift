//
//  SlidingView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 1/14/21.
//

import UIKit
import SwiftUI

enum SlidingViewState {
    case open
    case sliding
    case closed
}

protocol SlidingViewControllerDelegate {
    func slidingViewControllerWillChangeState(newState: SlidingViewState)
}

class SlidingViewController<Content: View>: UIViewController {
    
    init(content: Content) {
        self.content = content
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        contentView = UIView(frame: view.bounds)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .cyan
        view.addSubview(contentView)
        
        // Setup layout
        setupPositionContraint(isOpen: state == .open)
        let constraints = [
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan(panGR:)))
        contentView.addGestureRecognizer(panGR)
        
        setupContent()
    }
    
    private func setupContent() {
        let contentVC = UIHostingController(rootView: content)
        addChild(contentVC)
        contentVC.view.backgroundColor = .clear
        contentVC.view.frame = contentView.bounds
        contentVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(contentVC.view)
        contentVC.didMove(toParent: self)
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            wasOpen = (state == .open)
            internalState = .sliding
            startPos = contentPos
        case .changed:
            let translation = panGR.translation(in: view)
            contentPos = startPos + translation.y
        case .ended, .cancelled:
            let velocity = panGR.velocity(in: view)
            
            let kSpeedThreshold: CGFloat = 500.0
            let shouldOpen = (abs(velocity.y) <= kSpeedThreshold ? normContentPos < 0.5 : velocity.y <= 0.0)
            
            let remainingDistance: CGFloat
            let speed: CGFloat
            if shouldOpen {
                remainingDistance = contentPos
                speed = -min(velocity.y, 0.0)
            } else {
                remainingDistance = slidingRange - contentPos
                speed = max(velocity.y, 0.0)
            }
            
            let duration = TimeInterval(min(0.3, remainingDistance / speed))
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut) {
                self.internalState = (shouldOpen ? .open : .closed)
                self.view.layoutIfNeeded()
            }

            break
        default:
            break
        }
    }
    
    public var delegate: SlidingViewControllerDelegate?
    public var bottomInset: CGFloat = 100.0
    
    public var state: SlidingViewState {
        set {
            guard newValue != .sliding else { return }
            internalState = newValue
        }
        get { internalState }
    }
    
    private func setupPositionContraint(isOpen: Bool) {
        if contentPosLayoutConstraint != nil {
            contentPosLayoutConstraint.isActive = false
        }
        if isOpen {
            contentPosLayoutConstraint = contentView.topAnchor.constraint(equalTo: view.topAnchor)
        } else {
            contentPosLayoutConstraint = contentView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -bottomInset)
        }
        contentPosLayoutConstraint.isActive = true
    }
    
    private var slidingRange: CGFloat {
        view.bounds.height - bottomInset
    }
    
    // Is 0 when view is open and 'slidingRange' when closed
    private var contentPos: CGFloat {
        set {
            assert(state == .sliding)
            if wasOpen {
                contentPosLayoutConstraint.constant = clamp(newValue, min: 0.0, max: slidingRange)
            } else {
                contentPosLayoutConstraint.constant = clamp(newValue - view.bounds.height, min: -view.bounds.height, max: -bottomInset)
            }
        }
        get {
            assert(state == .sliding)
            return contentPosLayoutConstraint.constant + (wasOpen ? 0.0 : view.bounds.height)
        }
    }
    
    private var normContentPos: CGFloat {
        set { contentPos = newValue * slidingRange }
        get { contentPos / slidingRange }
    }
    
    private var internalState = SlidingViewState.open {
        willSet {
            guard internalState != newValue, isViewLoaded else { return }
            
            delegate?.slidingViewControllerWillChangeState(newState: newValue)
            
            guard newValue != .sliding else { return }
            
            setupPositionContraint(isOpen: newValue == .open)
        }
    }
    
    private let content: Content
    private var contentView: UIView!
    private var contentPosLayoutConstraint: NSLayoutConstraint!
    private var panGR: UIGestureRecognizer!
    private var startPos: CGFloat = 0.0
    private var wasOpen = false
}

struct SlidingView<Content: View>: UIViewControllerRepresentable {
    
    @Binding var state: SlidingViewState
    let content: Content
    
    func makeUIViewController(context: Context) -> SlidingViewController<Content> {
        let vc = SlidingViewController(content: content)
        vc.delegate = context.coordinator
        vc.state = state
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SlidingViewController<Content>, context: Context) {
        uiViewController.state = state
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(slidingView: self)
    }
    
    typealias UIViewControllerType = SlidingViewController<Content>
    
    final class Coordinator: SlidingViewControllerDelegate {
        
        var slidingView: SlidingView
        
        init(slidingView: SlidingView) {
            self.slidingView = slidingView
        }
        
        func slidingViewControllerWillChangeState(newState: SlidingViewState) {
            slidingView.state = newState
        }
        
    }
    
}
