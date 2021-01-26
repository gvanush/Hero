//
//  TransformViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/20/21.
//

import UIKit

protocol TransformViewControllerDelegate {
    func transformViewController(_ transformViewController: TransformViewController, didBeginContinuousEditingOnNumberField numberField: NumberField)
    func transformViewController(_ transformViewController: TransformViewController, didEndContinuousEditingOnNumberField numberField: NumberField)
}

class TransformViewController: UIViewController, NumberFieldDelegate {
    
    var transform: Transform!
    var delegate: TransformViewControllerDelegate?
    
    enum VectorElement: Int {
        case x = 0
        case y = 1
        case z = 2
    }
    
    enum NumberFieldSection {
        
        init?(tag: Int) {
            switch tag / 3 {
            case 0:
                self = .position
            case 1:
                self = .rotation
            case 2:
                self = .scale
            default:
                return nil
            }
        }
        
        case position
        case rotation
        case scale
    }
    
    override func viewDidLoad() {
        
        positionFormatter.numberStyle = .decimal
        scaleFormatter.numberStyle = .decimal
        rotationFormatter.unitStyle = .short
        
        configPositionViews()
        configRotationViews()
        configScaleViews()
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = .zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }

        scrollView.scrollIndicatorInsets = scrollView.contentInset

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        positionXNumberField.value = CGFloat(transform.position.x)
        positionYNumberField.value = CGFloat(transform.position.y)
        positionZNumberField.value = CGFloat(transform.position.z)
        
        rotationXNumberField.value = CGFloat(rad2deg(transform.rotation.x))
        rotationYNumberField.value = CGFloat(rad2deg(transform.rotation.y))
        rotationZNumberField.value = CGFloat(rad2deg(transform.rotation.z))
        rotationModeButton.setTitle(nameFor(transform.rotationMode)!, for: .normal)
        
        scaleXNumberField.value = CGFloat(transform.scale.x)
        scaleYNumberField.value = CGFloat(transform.scale.y)
        scaleZNumberField.value = CGFloat(transform.scale.z)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: NumberFieldDelegate
    func numberFieldTextForValue(_ numberField: NumberField) -> String {
        let section = NumberFieldSection(tag: numberField.tag)!
        let number = NSNumber(value: Double(numberField.value))
        switch section {
        case .position:
            return positionFormatter.string(from: number)!
        case .rotation:
            return "  " + rotationFormatter.string(from: Measurement<UnitAngle>(value: Double(numberField.value), unit: .degrees))
        case .scale:
            return scaleFormatter.string(from: number)!
        }
    }
    
    func numberFieldDidBeginEditing(_ numberField: NumberField) -> (valueText: String?, placeHolder: String?)? {
        let section = NumberFieldSection(tag: numberField.tag)!
        let vectorElemIndex = numberField.tag % 3
        switch section {
        case .position:
            positionFormatter.usesGroupingSeparator = false
            let placeholder = positionFormatter.string(from: NSNumber(value: transform.position[vectorElemIndex]))!
            positionFormatter.usesGroupingSeparator = true
            return (nil, placeholder)
        case .rotation:
            let placeholder = rotationFormatter.numberFormatter.string(from: NSNumber(value: rad2deg(transform.rotation[vectorElemIndex])))!
            return (nil, placeholder)
        case .scale:
            positionFormatter.usesGroupingSeparator = false
            let placeholder = positionFormatter.string(from: NSNumber(value: transform.scale[vectorElemIndex]))!
            positionFormatter.usesGroupingSeparator = true
            return (nil, placeholder)
        }
    }
    
    func numberFieldDidEndEditing(_ numberField: NumberField, reason: NumberField.DidEndEditingReason) -> CGFloat? {
        let section = NumberFieldSection(tag: numberField.tag)!
        let vectorElemIndex = numberField.tag % 3
        switch reason {
        case .comitted:
            if let valueText = numberField.valueText {
                switch section {
                case .position:
                    if let newValue = positionFormatter.number(from: valueText) {
                        return CGFloat(newValue.doubleValue)
                    }
                case .rotation:
                    if let newAngle = rotationFormatter.numberFormatter.number(from: valueText) {
                        return CGFloat(newAngle.floatValue)
                    }
                case .scale:
                    if let newValue = scaleFormatter.number(from: valueText) {
                        return CGFloat(newValue.doubleValue)
                    }
                }
            }
            fallthrough
        case .cancelled:
            return CGFloat(vectorForSection(section)[vectorElemIndex])
        }
    }
    
    private func vectorForSection(_ section: NumberFieldSection) -> SIMD3<Float> {
        switch section {
        case .position:
            return transform.position
        case .rotation:
            return rad2deg(transform.rotation)
        case .scale:
            return transform.scale
        }
    }
    
    func numberFieldDidBeginContinuousEditing(_ numberField: NumberField) {
        delegate?.transformViewController(self, didBeginContinuousEditingOnNumberField: numberField)
    }
    
    func numberFieldDidEndContinuousEditing(_ numberField: NumberField) {
        delegate?.transformViewController(self, didEndContinuousEditingOnNumberField: numberField)
    }
    
    // MARK: Position
    private func configPositionViews() {
        positionXNumberField.delegate = self
        positionYNumberField.delegate = self
        positionZNumberField.delegate = self
    }
    
    @IBAction func onNumberFieldValueChanged(_ sender: NumberField) {
        let section = NumberFieldSection(tag: sender.tag)!
        let vectorElementIndex = sender.tag % 3
        switch section {
        case .position:
            transform.position[vectorElementIndex] = Float(sender.value)
        case .rotation:
            transform.rotation[vectorElementIndex] = Float(deg2rad(sender.value))
        case .scale:
            transform.scale[vectorElementIndex] = Float(sender.value)
        }
    }
    
    @IBOutlet weak var positionXNumberField: NumberField!
    @IBOutlet weak var positionYNumberField: NumberField!
    @IBOutlet weak var positionZNumberField: NumberField!
    private let positionFormatter = NumberFormatter()
    
    // MARK: Rotation
    private func configRotationViews() {
        rotationXNumberField.delegate = self
        rotationYNumberField.delegate = self
        rotationZNumberField.delegate = self
        
        var items = [UIAction]()
        for rotationModeVal in kRotationModeFirst..<kRotationModeCount {
            let rotationMode = RotationMode(rotationModeVal)
            items.append( UIAction(title: nameFor(rotationMode)!) { [unowned self, rotationMode] action in
                self.transform.rotationMode = rotationMode
                self.rotationModeButton.setTitle(nameFor(rotationMode)!, for: .normal)
            })
        }
        rotationModeButton.menu = UIMenu(title: "", children: items)
        rotationModeButton.showsMenuAsPrimaryAction = true
    }
    
    func nameFor(_ rotationMode: RotationMode) -> String? {
        switch rotationMode {
        case RotationMode_xyz:
            return "Euler XYZ"
        case RotationMode_xzy:
            return "Euler XZY"
        case RotationMode_yxz:
            return "Euler YXZ"
        case RotationMode_yzx:
            return "Euler YZX"
        case RotationMode_zxy:
            return "Euler ZXY"
        case RotationMode_zyx:
            return "Euler ZYX"
        default:
            return nil
        }
    }
    
    @IBOutlet weak var rotationXNumberField: NumberField!
    @IBOutlet weak var rotationYNumberField: NumberField!
    @IBOutlet weak var rotationZNumberField: NumberField!
    @IBOutlet weak var rotationModeButton: UIButton!
    private let rotationFormatter = MeasurementFormatter()
    
    // MARK: Scale
    private func configScaleViews() {
        scaleXNumberField.delegate = self
        scaleYNumberField.delegate = self
        scaleZNumberField.delegate = self
    }
    
    @IBOutlet weak var scaleXNumberField: NumberField!
    @IBOutlet weak var scaleYNumberField: NumberField!
    @IBOutlet weak var scaleZNumberField: NumberField!
    private let scaleFormatter = NumberFormatter()
    
    // MARK: Releasing / Retaining number fields
    struct ReleasedNumberFieldRecord {
        let superview: UIStackView
        let index: Int
    }
    var releasedControlRecords = [NumberField : ReleasedNumberFieldRecord]()
    
    func releaseNumberField(_ numberField: NumberField, animated: Bool) {
        assert(numberField.isDescendant(of: view))
        
        let superview = numberField.superview as! UIStackView
        let index = superview.arrangedSubviews.firstIndex(of: numberField)!
        releasedControlRecords[numberField] = ReleasedNumberFieldRecord(superview: superview, index: index)
        
        superview.removeArrangedSubview(numberField)
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                superview.layoutIfNeeded()
            }
        } else {
            superview.layoutIfNeeded()
        }
    }
    
    func retainNumberField(_ numberField: NumberField, animated: Bool) {
        let record = releasedControlRecords.removeValue(forKey: numberField)!
        
        let center = record.superview.convert(numberField.center, from: numberField.superview)
        numberField.removeFromSuperview()
        record.superview.insertArrangedSubview(numberField, at: record.index)
        numberField.center = center
        
        if animated {
            UIView.animate(withDuration: 0.3) {
                record.superview.layoutIfNeeded()
            }
        } else {
            
        }
        
    }
    
    func ensureVisible(view: UIView, animated: Bool) {
        assert(view.isDescendant(of: scrollView))
        let rect = scrollView.convert(view.frame, from: view.superview)
        scrollView.scrollRectToVisible(rect, animated: animated)
    }
}
