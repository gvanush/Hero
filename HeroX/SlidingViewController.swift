//
//  SlidingViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/19/21.
//

import UIKit

enum SlidingViewState {
    case open
    case sliding
    case closed
}

protocol SlidingViewControllerDelegate {
    func slidingViewControllerWillChangeState(newState: SlidingViewState)
}

class SlidingViewController: UIViewController {
    
    private class ContentHitTestView: UIView {
        
        var contentView: UIView?
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let contentView = self.contentView else { return nil }
            
            let pointInContentView = contentView.convert(point, from: self)
            
            if contentView.bounds.contains(pointInContentView) {
                return contentView.hitTest(pointInContentView, with: event)
            }
            
            return nil
        }
    }
    
    override func loadView() {
        self.view = ContentHitTestView()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        setupContentView()
        
        if let headerView = self.headerView {
            setupHeaderView(headerView)
        }
        
        if let contentVC = bodyViewController {
            setupBodyViewController(contentVC)
        }
    }
    
    private func setupContentView() {
        contentView = UIView(frame: view.bounds)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        view.addSubview(contentView)
        
        // Setup layout
        setupPositionContraint(isOpen: state == .open)
        let constraints = [
            contentView.heightAnchor.constraint(equalTo: view.heightAnchor),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
        let hitTestView = view as! ContentHitTestView
        hitTestView.contentView = contentView
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan(panGR:)))
        contentView.addGestureRecognizer(panGR)
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        self.bodyViewController = vc
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
            contentPosLayoutConstraint = contentView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -headerHeight)
        }
        contentPosLayoutConstraint.isActive = true
    }
    
    private var slidingRange: CGFloat {
        view.bounds.height - headerHeight
    }
    
    // Is 0 when view is open and 'slidingRange' when closed
    private var contentPos: CGFloat {
        set {
            assert(state == .sliding)
            if wasOpen {
                contentPosLayoutConstraint.constant = clamp(newValue, min: 0.0, max: slidingRange)
            } else {
                contentPosLayoutConstraint.constant = clamp(newValue - view.bounds.height, min: -view.bounds.height, max: -headerHeight)
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
    
    // MARK: Body
    var bodyViewController: UIViewController? {
        willSet {
            if let contentViewController = self.bodyViewController {
                uninstallViewController(contentViewController)
            }
            if let newContentVC = newValue {
                setupBodyViewController(newContentVC)
            }
        }
    }
    
    private func setupBodyViewController(_ bodyViewController: UIViewController) {
        guard isViewLoaded else { return }
        
        installViewController(bodyViewController) { bodyView in
            bodyView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(bodyView)
            let constraints = [
                bodyView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: headerHeight),
                bodyView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
                bodyView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                bodyView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
            ]
            NSLayoutConstraint.activate(constraints)
        }
    }
    
    // MARK: Header
    var headerHeight: CGFloat = 100.0 {
        willSet {
            if let constraint = headerViewHeightLayoutConstraint {
                constraint.constant = newValue
            }
        }
    }
    
    var headerView: UIView? {
        willSet {
            if let headerView = self.headerView {
                headerView.removeFromSuperview()
            }
            if let newHeaderView = newValue {
                setupHeaderView(newHeaderView)
            }
        }
    }
    
    private func setupHeaderView(_ headerView: UIView) {
        guard isViewLoaded else { return }
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerView)
        headerViewHeightLayoutConstraint = headerView.heightAnchor.constraint(equalToConstant: self.headerHeight)
        let constraints = [
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerViewHeightLayoutConstraint!,
            headerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            headerView.widthAnchor.constraint(equalTo: contentView.widthAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private var headerViewHeightLayoutConstraint: NSLayoutConstraint?
    
    private var contentView: UIView!
    private var contentPosLayoutConstraint: NSLayoutConstraint!
    private var panGR: UIGestureRecognizer!
    private var startPos: CGFloat = 0.0
    private var wasOpen = false
}
