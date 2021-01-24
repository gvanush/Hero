//
//  NumberField.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/23/21.
//

import UIKit

protocol NumberFieldDelegate: class {
    func numberField(_ numberField: NumberField, textFor value: CGFloat) -> String
    func numberFieldDidBeginEditing(_ numberField: NumberField) -> (valueText: String?, placeHolder: String?)?
    func numberFieldDidEndEditing(_ numberField: NumberField, reason: NumberField.DidEndEditingReason) -> CGFloat?
    func numberFieldDidBeginContinuousEditing(_ numberField: NumberField)
    func numberFieldDidEndContinuousEditing(_ numberField: NumberField)
}

@IBDesignable
class NumberField : UIControl, UIGestureRecognizerDelegate, UITextFieldDelegate {
    
    enum DidEndEditingReason {
        case comitted
        case cancelled
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        configSubviews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        configSubviews()
    }
    
    private func setupFromNib() {
        let nib = UINib(nibName: "NumberField", bundle: Bundle(for: Self.self))
        let content = nib.instantiate(withOwner: self, options: nil).first as! UIView
        content.frame = bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(content)
    }
    
    private func configSubviews() {
        textField.text = "\(NumberField.initialValue)"
        textField.delegate = self
        textField.setupInputAccessoryToolbar(onDone: (self, #selector(onTextFieldDonePressed)), onCancel: (self, #selector(onTextFieldCancelPressed)))
        
        handleImageView.isHidden = !isContinuousEditingEnabled
        panGestureRecognizer.isEnabled = isContinuousEditingEnabled
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: textField.frame.size.height + (isContinuousEditingEnabled ? handleImageView.frame.size.height : 0.0))
    }
    
    static let initialValue: CGFloat = 0.0
    
    var value: CGFloat = NumberField.initialValue {
        willSet {
            textField.text = delegate?.numberField(self, textFor: newValue) ?? "\(newValue)"
        }
        didSet {
            sendActions(for: .valueChanged)
        }
    }
    
    // MARK: Continuous editing
    var continuousEditingUpdater: Updater? {
        willSet {
            panGestureRecognizer.cancel()
            
            if let updater = continuousEditingUpdater {
                updater.stop()
                updater.callback = nil
            }
            
            if let newUpdater = newValue {
                newUpdater.callback = { [unowned self] deltaTime in
                    self.value += CGFloat(deltaTime) * self.continuousEditingNormSpeed * self.continuousEditingMaxSpeed
                }
            }
        }
        didSet {
            handleImageView.isHidden = !isContinuousEditingEnabled
            panGestureRecognizer.isEnabled = isContinuousEditingEnabled
            if (isContinuousEditingEnabled && oldValue == nil) || (!isContinuousEditingEnabled && oldValue != nil) {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    var isContinuousEditingEnabled: Bool {
        continuousEditingUpdater != nil
    }
    
    var continuousEditingMaxSpeed: CGFloat = 1.0
    private var continuousEditingNormSpeed: CGFloat {
        handleImageViewPositionLayoutConstraint.constant / (0.5 * bounds.size.width)
    }
    
    weak var delegate: NumberFieldDelegate?
    
    @IBOutlet weak private var handleImageViewPositionLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak private var handleImageView: UIImageView!
    @IBOutlet weak private var panGestureRecognizer: UIPanGestureRecognizer!
    
    // MARK: TextField handling
    @objc func onTextFieldDonePressed(_ barButtonItem: UIBarButtonItem) {
        textField.resignFirstResponder()
    }
    
    @objc func onTextFieldCancelPressed(_ barButtonItem: UIBarButtonItem) {
        didEndEditingReason = .cancelled
        textField.resignFirstResponder()
    }
    
    // UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didEndEditingReason = .comitted
        if let result = delegate?.numberFieldDidBeginEditing(self) {
            textField.text = result.valueText
            textField.placeholder = result.placeHolder
        } else {
            textField.text = "\(value)"
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let newValue = delegate?.numberFieldDidEndEditing(self, reason: didEndEditingReason) {
            value = newValue
        } else {
            if let text = textField.text, let newValue = Double(text) {
                value = CGFloat(newValue)
            } else {
                (value = value)
            }
        }
    }
    
    private var didEndEditingReason = DidEndEditingReason.comitted
    
    // MARK: UIGestureRecognizerDelegate
    @IBAction func onPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            continuousEditingUpdater!.start()
            delegate?.numberFieldDidBeginContinuousEditing(self)
            break
        case .changed:
            let x = sender.translation(in: self).x
            let halfWidth = 0.5 * bounds.size.width
            handleImageViewPositionLayoutConstraint.constant = clamp(x, min: -halfWidth, max: halfWidth)
        case .ended, .cancelled:
            sender.isEnabled = false
            UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut) {
                self.handleImageViewPositionLayoutConstraint.constant = 0.0
                self.layoutIfNeeded()
            } completion: { _ in
                sender.isEnabled = true
            }
            continuousEditingUpdater!.stop()
            delegate?.numberFieldDidEndContinuousEditing(self)
            break
        default:
            break
        }
    }
    
    // MARK: UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        assert(panGestureRecognizer == gestureRecognizer)
        // Limit to horizontal scrolling
        let velocity = panGestureRecognizer.velocity(in: self)
        return abs(velocity.y) < abs(velocity.x)
    }
    
}
