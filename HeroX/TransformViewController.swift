//
//  TransformViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/20/21.
//

import UIKit

class TransformViewController: UIViewController {
    
    var transform: Transform!
    
    enum VectorElement: Int {
        case x = 0
        case y = 1
        case z = 2
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
        positionXTextField.text = positionFor(.x)
        positionYTextField.text = positionFor(.y)
        positionZTextField.text = positionFor(.z)
        
        rotationXTextField.text = rotationFor(.x)
        rotationYTextField.text = rotationFor(.y)
        rotationZTextField.text = rotationFor(.z)
        
        scaleXTextField.text = scaleFor(.x)
        scaleYTextField.text = scaleFor(.y)
        scaleZTextField.text = scaleFor(.z)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: Position
    private func configPositionViews() {
        positionXTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onPositionTextFieldDonePressed)), onCancel: (self, #selector(onPositionElementTextFieldCancelPressed)), tag: positionXTextField.tag)
        positionYTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onPositionTextFieldDonePressed)), onCancel: (self, #selector(onPositionElementTextFieldCancelPressed)), tag: positionYTextField.tag)
        positionZTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onPositionTextFieldDonePressed)), onCancel: (self, #selector(onPositionElementTextFieldCancelPressed)), tag: positionZTextField.tag)
    }
    
    private func positionTextFieldForVectorElement(_ element: VectorElement) -> UITextField {
        switch element {
        case .x:
            return positionXTextField
        case .y:
            return positionYTextField
        case .z:
            return positionZTextField
        }
    }
    
    @objc func onPositionTextFieldDonePressed(_ barButtonItem: UIBarButtonItem) {
        let textField = positionTextFieldForVectorElement(VectorElement(rawValue: barButtonItem.tag)!)
        textField.resignFirstResponder()
    }
    
    @objc func onPositionElementTextFieldCancelPressed(_ barButtonItem: UIBarButtonItem) {
        let element = VectorElement(rawValue: barButtonItem.tag)!
        let textField = positionTextFieldForVectorElement(element)
        textField.text = rawPositionFor(element)
        textField.resignFirstResponder()
    }
    
    @IBAction func positionElementTextFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = rawPositionFor(VectorElement(rawValue: textField.tag)!)
        textField.text = nil
    }
    
    @IBAction func positionElementTextFieldDidEndEditing(_ textField: UITextField) {
        let element = VectorElement(rawValue: textField.tag)!
        if let text = textField.text {
            setPosition(text, for: element)
        }
        textField.text = positionFor(element)
    }
    
    func setPosition(_ text: String, for element: VectorElement) {
        var value = transform.position[element.rawValue]
        if let newValue = positionFormatter.number(from: text) {
            value = newValue.floatValue
        }
        transform.position[element.rawValue] = value
    }
    
    func positionFor(_ element: VectorElement) -> String {
        positionFormatter.string(from: NSNumber(value: transform.position[element.rawValue]))!
    }
    
    func rawPositionFor(_ element: VectorElement) -> String {
        positionFormatter.usesGroupingSeparator = false
        let result = positionFormatter.string(from: NSNumber(value: transform.position[element.rawValue]))!
        positionFormatter.usesGroupingSeparator = true
        return result
    }
    
    @IBOutlet weak var positionXTextField: UITextField!
    @IBOutlet weak var positionYTextField: UITextField!
    @IBOutlet weak var positionZTextField: UITextField!
    private let positionFormatter = NumberFormatter()
    
    // MARK: Rotation
    private func configRotationViews() {
        rotationXTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onRotationTextFieldDonePressed)), onCancel: (self, #selector(onRotationElementTextFieldCancelPressed)), tag: rotationXTextField.tag)
        rotationYTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onRotationTextFieldDonePressed)), onCancel: (self, #selector(onRotationElementTextFieldCancelPressed)), tag: rotationYTextField.tag)
        rotationZTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onRotationTextFieldDonePressed)), onCancel: (self, #selector(onRotationElementTextFieldCancelPressed)), tag: rotationZTextField.tag)
    }
    
    private func rotationTextFieldForVectorElement(_ element: VectorElement) -> UITextField {
        switch element {
        case .x:
            return rotationXTextField
        case .y:
            return rotationYTextField
        case .z:
            return rotationZTextField
        }
    }
    
    @objc func onRotationTextFieldDonePressed(_ barButtonItem: UIBarButtonItem) {
        let textField = rotationTextFieldForVectorElement(VectorElement(rawValue: barButtonItem.tag)!)
        textField.resignFirstResponder()
    }
    
    @objc func onRotationElementTextFieldCancelPressed(_ barButtonItem: UIBarButtonItem) {
        let element = VectorElement(rawValue: barButtonItem.tag)!
        let textField = rotationTextFieldForVectorElement(element)
        textField.text = rawRotationFor(element)
        textField.resignFirstResponder()
    }
    
    @IBAction func rotationElementTextFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = rawRotationFor(VectorElement(rawValue: textField.tag)!)
        textField.text = nil
    }
    
    @IBAction func rotationElementTextFieldDidEndEditing(_ textField: UITextField) {
        let element = VectorElement(rawValue: textField.tag)!
        if let text = textField.text {
            setRotation(text, for: element)
        }
        textField.text = rotationFor(element)
    }
    
    func setRotation(_ text: String, for element: VectorElement) {
        var angle = transform.rotation[element.rawValue]
        if let newAngle = rotationFormatter.numberFormatter.number(from: text) {
            angle = deg2rad(newAngle.floatValue)
        }
        transform.rotation[element.rawValue] = angle
    }
    
    func rotationFor(_ element: VectorElement) -> String {
        let angle = rad2deg(transform.rotation[element.rawValue])
        return rotationFormatter.string(from: Measurement<UnitAngle>(value: Double(angle), unit: .degrees))
    }
    
    func rawRotationFor(_ element: VectorElement) -> String {
        rotationFormatter.numberFormatter.string(from: NSNumber(value: rad2deg(transform.rotation[element.rawValue])))!
    }
    
    @IBOutlet weak var rotationXTextField: UITextField!
    @IBOutlet weak var rotationYTextField: UITextField!
    @IBOutlet weak var rotationZTextField: UITextField!
    private let rotationFormatter = MeasurementFormatter()
    
    // MARK: Scale
    private func configScaleViews() {
        scaleXTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onScaleTextFieldDonePressed)), onCancel: (self, #selector(onScaleElementTextFieldCancelPressed)), tag: scaleXTextField.tag)
        scaleYTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onScaleTextFieldDonePressed)), onCancel: (self, #selector(onScaleElementTextFieldCancelPressed)), tag: scaleYTextField.tag)
        scaleZTextField.setupInputAccessoryToolbar(onDone: (self, #selector(onScaleTextFieldDonePressed)), onCancel: (self, #selector(onScaleElementTextFieldCancelPressed)), tag: scaleZTextField.tag)
    }
    
    private func scaleTextFieldForVectorElement(_ element: VectorElement) -> UITextField {
        switch element {
        case .x:
            return scaleXTextField
        case .y:
            return scaleYTextField
        case .z:
            return scaleZTextField
        }
    }
    
    @objc func onScaleTextFieldDonePressed(_ barButtonItem: UIBarButtonItem) {
        let textField = scaleTextFieldForVectorElement(VectorElement(rawValue: barButtonItem.tag)!)
        textField.resignFirstResponder()
    }
    
    @objc func onScaleElementTextFieldCancelPressed(_ barButtonItem: UIBarButtonItem) {
        let element = VectorElement(rawValue: barButtonItem.tag)!
        let textField = scaleTextFieldForVectorElement(element)
        textField.text = rawScaleFor(element)
        textField.resignFirstResponder()
    }
    
    @IBAction func scaleElementTextFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = rawScaleFor(VectorElement(rawValue: textField.tag)!)
        textField.text = nil
    }
    
    @IBAction func scaleElementTextFieldDidEndEditing(_ textField: UITextField) {
        let element = VectorElement(rawValue: textField.tag)!
        if let text = textField.text {
            setScale(text, for: element)
        }
        textField.text = scaleFor(element)
    }
    
    func setScale(_ text: String, for element: VectorElement) {
        var value = transform.scale[element.rawValue]
        if let newValue = scaleFormatter.number(from: text) {
            value = newValue.floatValue
        }
        transform.scale[element.rawValue] = value
    }
    
    func scaleFor(_ element: VectorElement) -> String {
        scaleFormatter.string(from: NSNumber(value: transform.scale[element.rawValue]))!
    }
    
    func rawScaleFor(_ element: VectorElement) -> String {
        scaleFormatter.usesGroupingSeparator = false
        let result = scaleFormatter.string(from: NSNumber(value: transform.scale[element.rawValue]))!
        scaleFormatter.usesGroupingSeparator = true
        return result
    }
    
    @IBOutlet weak var scaleXTextField: UITextField!
    @IBOutlet weak var scaleYTextField: UITextField!
    @IBOutlet weak var scaleZTextField: UITextField!
    private let scaleFormatter = NumberFormatter()
    
    
}
