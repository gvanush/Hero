//
//  NumberField.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/23/21.
//

import UIKit

protocol NumberFieldDelegate: class {
    func numberFieldTextForValue(_ numberField: NumberField) -> String
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
    
    enum ContinuousEditingState {
        case adding
        case subtracting
        case idle
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
        configViews()
        setupUpdater()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
        configViews()
        setupUpdater()
    }
    
    private func setupFromNib() {
        let nib = UINib(nibName: "NumberField", bundle: Bundle(for: Self.self))
        let content = nib.instantiate(withOwner: self, options: nil).first as! UIView
        content.frame = bounds
        content.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(content)
    }
    
    private func configViews() {
        continuousEditingGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(continuousEditingGestureRecognizer)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        addGestureRecognizer(tapGestureRecognizer)
        
        textField.text = "\(NumberField.initialValue)"
        textField.delegate = self
        textField.setupInputAccessoryToolbar(onDone: (self, #selector(onTextFieldDonePressed)), onCancel: (self, #selector(onTextFieldCancelPressed)))
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: textField.frame.union(titleLabel.frame).height)
    }
    
    static let initialValue: CGFloat = 0.0
    
    var value: CGFloat = NumberField.initialValue {
        didSet {
            sendActions(for: .valueChanged)
            textField.text = delegate?.numberFieldTextForValue(self) ?? "\(value)"
        }
    }
    
    var valueText: String? {
        textField.text
    }
    
    weak var delegate: NumberFieldDelegate?
    
    // MARK: Continuous editing
    var continuousEditingUpdater: Updater = DisplayLinkUpdater() {
        willSet {
            continuousEditingUpdater.stop()
            continuousEditingUpdater.callback = nil
        }
        didSet {
            setupUpdater()
        }
    }
    
    private func setupUpdater() {
        continuousEditingUpdater.callback = { [unowned self] deltaTime in
            let offset = continuousEditingOffset
            guard abs(offset) >= NumberField.continuousEditingMinOffset else {
                return
            }
            let normSpeed = (abs(offset) - NumberField.continuousEditingMinOffset) / (0.5 * bounds.size.width - NumberField.continuousEditingMinOffset)
            let speed = (offset <= 0.0 ? -1.0 : 1.0) * easeInOut(normValue: normSpeed) * self.continuousEditingMaxSpeed
            self.value += CGFloat(deltaTime) * speed
        }
    }
    
    var isContinuousEditingEnabled: Bool = true {
        didSet {
            guard isContinuousEditingEnabled != oldValue else { return }
            
            continuousEditingGestureRecognizer.cancel()
            
            continuousEditingGestureRecognizer.isEnabled = isContinuousEditingEnabled
            minusLabel.isHidden = !isContinuousEditingEnabled
            plusLabel.isHidden = !isContinuousEditingEnabled
            panLeftImageView.isHidden = !isContinuousEditingEnabled
            panRightImageView.isHidden = !isContinuousEditingEnabled
        }
    }
    
    var continuousEditingMaxSpeed: CGFloat = 1.0
    
    private(set) var continuousEditingState = ContinuousEditingState.idle {
        willSet {
            switch newValue {
            case .adding:
                plusLabel.textColor = .label
                minusLabel.textColor = .tertiaryLabel
            case .subtracting:
                minusLabel.textColor = .label
                plusLabel.textColor = .tertiaryLabel
            case .idle:
                plusLabel.textColor = .tertiaryLabel
                minusLabel.textColor = .tertiaryLabel
            }
        }
    }
    static private let continuousEditingMinOffset: CGFloat = 10.0
    
    private var continuousEditingOffset: CGFloat {
        continuousEditingGestureRecognizer.location(in: self).x - bounds.midX
    }
    
    var continuousEditingGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var minusLabel: UILabel!
    @IBOutlet weak var plusLabel: UILabel!
    @IBOutlet weak var panLeftImageView: UIImageView!
    @IBOutlet weak var panRightImageView: UIImageView!
    
    // MARK: Title
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBInspectable
    var title: String? {
        set {
            titleLabel.text = newValue
        }
        get {
            titleLabel.text
        }
    }
    
    // MARK: TextField handling
    @IBOutlet weak private var textField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    
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
            if let text = textField.text, let newValue = Double(text), didEndEditingReason == .comitted {
                value = CGFloat(newValue)
            } else {
                (value = value)
            }
        }
    }
    
    private var didEndEditingReason = DidEndEditingReason.comitted
    
    // MARK: UIGestureRecognizerDelegate
    @objc func onPan(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            continuousEditingUpdater.start()
            delegate?.numberFieldDidBeginContinuousEditing(self)
            feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator!.prepare()
            UIView.animate(withDuration: 0.3) {
                self.plusLabel.alpha = 1.0
                self.minusLabel.alpha = 1.0
                self.panLeftImageView.alpha = 0.0
                self.panRightImageView.alpha = 0.0
            }
            break
        case .changed:
            let oldState = continuousEditingState
            if (abs(continuousEditingOffset) < NumberField.continuousEditingMinOffset) {
                continuousEditingState = .idle
            } else {
                continuousEditingState = (continuousEditingOffset < 0.0 ? .subtracting : .adding)
            }
            if continuousEditingState == .idle && continuousEditingState != oldState {
                feedbackGenerator!.impactOccurred()
                feedbackGenerator!.prepare()
            }
            
            break
        case .ended, .cancelled, .failed:
            continuousEditingUpdater.stop()
            delegate?.numberFieldDidEndContinuousEditing(self)
            continuousEditingState = .idle
            feedbackGenerator = nil
            UIView.animate(withDuration: 0.3) {
                self.plusLabel.alpha = 0.0
                self.minusLabel.alpha = 0.0
                self.panLeftImageView.alpha = 1.0
                self.panRightImageView.alpha = 1.0
            }
            break
        default:
            break
        }
    }
    
    private var feedbackGenerator: UIImpactFeedbackGenerator?
    
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    @objc func onTap(_ sender: UITapGestureRecognizer) {
        guard sender.state == .recognized else { return }
        textField.becomeFirstResponder()
    }
    
    // MARK: UIGestureRecognizerDelegate
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if continuousEditingGestureRecognizer === gestureRecognizer {
            // Limit to horizontal scrolling
            let velocity = continuousEditingGestureRecognizer.velocity(in: self)
            return abs(velocity.y) < abs(velocity.x)
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        false
    }
    
}
