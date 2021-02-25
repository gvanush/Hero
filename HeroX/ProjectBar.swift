//
//  ProjectBar.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 2/24/21.
//

import UIKit

@IBDesignable
class ProjectBar: UIView {
    
    @IBOutlet public weak var projectsButton: UIButton!
    @IBOutlet public weak var actionsButton: UIButton!
    @IBOutlet public weak var projectNameLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackgroundView()
        setupNib(ProjectBar.nibName)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackgroundView()
        setupNib(ProjectBar.nibName)
    }
    
    private func setupBackgroundView() {
        let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterial))
        effectView.frame = bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(effectView)
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: ProjectBar.contentHeight + safeAreaInsets.top)
    }
    
    override func safeAreaInsetsDidChange() {
        invalidateIntrinsicContentSize()
    }
    
    static let nibName = "ProjectBar"
    static let contentHeight: CGFloat = 44.0
    
}
