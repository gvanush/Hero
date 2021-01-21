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
    
    private class HitTestView: UIView {
        
        var targetView: UIView?
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard let contentView = self.targetView, !isHidden else { return nil }
            
            let pointInContentView = contentView.convert(point, from: self)
            
            if contentView.bounds.contains(pointInContentView) {
                return contentView.hitTest(pointInContentView, with: event)
            }
            
            return nil
        }
    }
    
    override func loadView() {
        self.view = HitTestView()
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .clear
        
        setupViews()
        
        if let bgrView = backgroundView {
            setupBackgroundView(bgrView)
        }
        
        if let headerView = self.headerView {
            setupHeaderView(headerView)
        }
        
        if let contentVC = bodyViewController {
            setupBodyViewController(contentVC)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setupPositionContraint(isOpen: state == .open)
    }
    
    private func setupViews() {
        
        // Setup sliding view
        slidingView = UIView(frame: view.bounds)
        slidingView.translatesAutoresizingMaskIntoConstraints = false
        slidingView.backgroundColor = .clear
        view.addSubview(slidingView)
        
        let hitTestView = view as! HitTestView
        hitTestView.targetView = slidingView
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan(panGR:)))
        slidingView.addGestureRecognizer(panGR)
        
        // Setup content view
        contentView = UIView(frame: slidingView.bounds)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        slidingView.addSubview(contentView)
    }
    
    private func setupPositionContraint(isOpen: Bool) {
        // Layout sliding view
        if slidingViewPosLayoutConstraint == nil {
            let slidingViewConstraints = [
                slidingView.heightAnchor.constraint(equalTo: view.heightAnchor),
                slidingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                slidingView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ]
            NSLayoutConstraint.activate(slidingViewConstraints)
        } else {
            slidingViewPosLayoutConstraint.isActive = false
        }
        if isOpen {
            slidingViewPosLayoutConstraint = slidingView.topAnchor.constraint(equalTo: view.topAnchor)
        } else {
            slidingViewPosLayoutConstraint = slidingView.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -headerHeight)
        }
        slidingViewPosLayoutConstraint.isActive = true
        
        // Layout content view
        if contentViewPosLayoutConstraint == nil {
            let contentViewConstraints = [
                contentView.heightAnchor.constraint(equalTo: slidingView.heightAnchor, constant: -view.safeAreaLayoutGuide.layoutFrame.minY),
                contentView.centerXAnchor.constraint(equalTo: slidingView.centerXAnchor),
                contentView.widthAnchor.constraint(equalTo: slidingView.widthAnchor)
            ]
            NSLayoutConstraint.activate(contentViewConstraints)
        } else {
            contentViewPosLayoutConstraint.isActive = false
        }
        
        contentViewPosLayoutConstraint = contentView.topAnchor.constraint(equalTo: slidingView.topAnchor, constant: (isOpen ? view.safeAreaLayoutGuide.layoutFrame.minY : 0.0))
        
        contentViewPosLayoutConstraint.isActive = true
        
    }
    
    override func show(_ vc: UIViewController, sender: Any?) {
        self.bodyViewController = vc
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            wasOpen = (state == .open)
            internalState = .sliding
            startPos = slidingViewPos
        case .changed:
            let translation = panGR.translation(in: view)
            slidingViewPos = startPos + translation.y
        case .ended, .cancelled:
            let velocity = panGR.velocity(in: view)
            
            let kSpeedThreshold: CGFloat = 500.0
            let shouldOpen = (abs(velocity.y) <= kSpeedThreshold ? normSlidingViewPos < 0.5 : velocity.y <= 0.0)
            
            let remainingDistance: CGFloat
            let speed: CGFloat
            if shouldOpen {
                remainingDistance = slidingViewPos
                speed = -min(velocity.y, 0.0)
            } else {
                remainingDistance = slidingRange - slidingViewPos
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
    
    private var slidingRange: CGFloat {
        view.bounds.height - headerHeight
    }
    
    // Is 0 when view is open and 'slidingRange' when closed
    private var slidingViewPos: CGFloat {
        set {
            assert(state == .sliding)
            if wasOpen {
                slidingViewPosLayoutConstraint.constant = clamp(newValue, min: 0.0, max: slidingRange)
            } else {
                slidingViewPosLayoutConstraint.constant = clamp(newValue - view.bounds.height, min: -view.bounds.height, max: -headerHeight)
            }
            contentViewPosLayoutConstraint.constant = (1.0 - normSlidingViewPos) * view.safeAreaLayoutGuide.layoutFrame.minY
        }
        get {
            assert(state == .sliding)
            return slidingViewPosLayoutConstraint.constant + (wasOpen ? 0.0 : view.bounds.height)
        }
    }
    
    private var normSlidingViewPos: CGFloat {
        set { slidingViewPos = newValue * slidingRange }
        get { slidingViewPos / slidingRange }
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
            if let bodyViewController = self.bodyViewController {
                uninstallViewController(bodyViewController)
            }
            if let newBodyVC = newValue {
                setupBodyViewController(newBodyVC)
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
    
    // MARK: Background
    var backgroundView: UIView? {
        willSet {
            if let bgrView = backgroundView {
                bgrView.removeFromSuperview()
            }
            if let newBgr = newValue {
                setupBackgroundView(newBgr)
            }
        }
    }
    
    private func setupBackgroundView(_ bgrView: UIView) {
        guard isViewLoaded else { return }
        bgrView.frame = slidingView.bounds
        bgrView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        slidingView.insertSubview(bgrView, at: 0)
    }
    
    private var headerViewHeightLayoutConstraint: NSLayoutConstraint?
    
    private var slidingView: UIView!
    private var contentView: UIView!
    private var slidingViewPosLayoutConstraint: NSLayoutConstraint!
    private var contentViewPosLayoutConstraint: NSLayoutConstraint!
    private var panGR: UIGestureRecognizer!
    private var startPos: CGFloat = 0.0
    private var wasOpen = false
}
