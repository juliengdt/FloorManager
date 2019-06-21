//
//  ViewController.swift
//  FloorDetector
//
//  Created by Julien Goudet on 21/06/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import UIKit
import CoreMotion


class ViewController: UIViewController {
    
    private let maxGraphicConstraintConstant: Double = 100
    
    // Acceleration IBoutlets
    @IBOutlet weak var accelerationXLabel: UILabel!
    @IBOutlet weak var accelerationYLabel: UILabel!
    @IBOutlet weak var accelerationZLabel: UILabel!
    
    // Motion IBOutlets
    @IBOutlet weak var gravityXConstraint: NSLayoutConstraint!
    @IBOutlet weak var gravityYConstraint: NSLayoutConstraint!
    @IBOutlet weak var gravityZConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var accelerationXConstraint: NSLayoutConstraint!
    @IBOutlet weak var accelerationYConstraint: NSLayoutConstraint!
    @IBOutlet weak var accelerationZConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var magneticfieldXConstraint: NSLayoutConstraint!
    @IBOutlet weak var magneticfieldYConstraint: NSLayoutConstraint!
    @IBOutlet weak var magneticfieldZConstraint: NSLayoutConstraint!
    
    // Motion IBOutlets
    @IBOutlet weak var _gravityXConstraint: NSLayoutConstraint!
    @IBOutlet weak var _gravityYConstraint: NSLayoutConstraint!
    @IBOutlet weak var _gravityZConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var _accelerationXConstraint: NSLayoutConstraint!
    @IBOutlet weak var _accelerationYConstraint: NSLayoutConstraint!
    @IBOutlet weak var _accelerationZConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var _magneticfieldXConstraint: NSLayoutConstraint!
    @IBOutlet weak var _magneticfieldYConstraint: NSLayoutConstraint!
    @IBOutlet weak var _magneticfieldZConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headingLabel: UILabel!
    // Activity IBOutlets
    @IBOutlet weak var activityLabel: UILabel!
    
    @IBOutlet weak var pedometerLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupFloorManager()
    }
    
    
    func setupFloorManager() {
        DispatchQueue.global(qos: .background).async {
            FloorManager.instance.startUpdateWith(delegate: self)
        }
    }


}

extension ViewController: FloorManagerDelegate {
    func didReceiveNewFloorEvent(_ event: FloorEvent) {
        switch event {
        case .acceleration(let data):
         self.updateUIWithAcceleration(data)
        case .activity(let data):
            self.updateUIWithActivity(data)
        case .motion(let data):
            self.updateUIWithMotion(data)
        case .pedometer(let data):
            self.updateUIWithPedometer(data)
        }
    }
    
    func didReceiveFloorError(_ error: Error) {
        print(error.localizedDescription)
    }
    
}

private extension ViewController {
    
    func updateUIWithAcceleration(_ data: CMAcceleration) {
        DispatchQueue.main.async { [weak self] in
            self?.accelerationXLabel.text = "\((data.x * 1000).rounded() / 1000)"
            self?.accelerationYLabel.text = "\((data.y * 1000).rounded() / 1000)"
            self?.accelerationZLabel.text = "\((data.z * 1000).rounded() / 1000)"

        }

    }
    
    func updateUIWithMotion(_ data: CMDeviceMotion) {
        
        let gravityData = data.gravity
        let userAccelerationData = data.userAcceleration
        let magneticFieldData = data.magneticField
        
        let headingData = data.heading
        
        DispatchQueue.main.async { [weak self] in
            
            guard let this = self else { return }
            
            if gravityData.x > 0 {
                this.gravityXConstraint.constant = CGFloat(gravityData.x * this.maxGraphicConstraintConstant/1.5)
                this._gravityXConstraint.constant = 0
            }else {
                this.gravityXConstraint.constant = 0
                this._gravityXConstraint.constant = CGFloat(abs(gravityData.x) * this.maxGraphicConstraintConstant/1.5)
            }
            
            if gravityData.y > 0 {
                this.gravityYConstraint.constant = CGFloat(gravityData.y * this.maxGraphicConstraintConstant/1.5)
                this._gravityYConstraint.constant = 0
            }else {
                this.gravityYConstraint.constant = 0
                this._gravityYConstraint.constant = CGFloat(abs(gravityData.y) * this.maxGraphicConstraintConstant/1.5)
            }
            if gravityData.z > 0 {
                this.gravityZConstraint.constant = CGFloat(gravityData.z * this.maxGraphicConstraintConstant/1.5)
                this._gravityZConstraint.constant = 0
            }else {
                this.gravityZConstraint.constant = 0
                this._gravityZConstraint.constant = CGFloat(abs(gravityData.z) * this.maxGraphicConstraintConstant/1.5)
            }
            
            
            if userAccelerationData.x > 0 {
                this.accelerationXConstraint.constant = CGFloat(userAccelerationData.x * this.maxGraphicConstraintConstant)
                this._accelerationXConstraint.constant = 0
            }else {
                this.accelerationXConstraint.constant = 0
                this._accelerationXConstraint.constant = CGFloat(abs(userAccelerationData.x) * this.maxGraphicConstraintConstant)
            }
            if userAccelerationData.y > 0 {
                this.accelerationYConstraint.constant = CGFloat(userAccelerationData.y * this.maxGraphicConstraintConstant)
                this._accelerationYConstraint.constant = 0
            }else {
                this.accelerationYConstraint.constant = 0
                this._accelerationYConstraint.constant = CGFloat(abs(userAccelerationData.y) * this.maxGraphicConstraintConstant)
            }
            if userAccelerationData.z > 0 {
                this.accelerationZConstraint.constant = CGFloat(userAccelerationData.z * this.maxGraphicConstraintConstant)
                this._accelerationZConstraint.constant = 0
            }else {
                this.accelerationZConstraint.constant = 0
                this._accelerationZConstraint.constant = CGFloat(abs(userAccelerationData.z) * this.maxGraphicConstraintConstant)
            }
            
    
            if magneticFieldData.field.x > 0 {
                this.magneticfieldXConstraint.constant = CGFloat(magneticFieldData.field.x * 2)
                this._magneticfieldXConstraint.constant = 0
            }else {
                this.magneticfieldXConstraint.constant = 0
                this._magneticfieldXConstraint.constant = CGFloat(abs(magneticFieldData.field.x) * 2)
            }
            if magneticFieldData.field.y > 0 {
                this.magneticfieldYConstraint.constant = CGFloat(magneticFieldData.field.y * 2)
                this._magneticfieldYConstraint.constant = 0
            }else {
                this.magneticfieldYConstraint.constant = 0
                this._magneticfieldYConstraint.constant = CGFloat(abs(magneticFieldData.field.y) * 2)
            }
            if magneticFieldData.field.z > 0 {
                this.magneticfieldZConstraint.constant = CGFloat(magneticFieldData.field.z * 2)
                this._magneticfieldZConstraint.constant = 0
            }else {
                this.magneticfieldZConstraint.constant = 0
                this._magneticfieldZConstraint.constant = CGFloat(abs(magneticFieldData.field.z) * 2)
            }

            self?.headingLabel.text = "\(Int(headingData))"
        }
    }
    
    func updateUIWithActivity(_ data: CMMotionActivity) {

        DispatchQueue.main.async { [weak self] in
            self?.activityLabel.text = data.debugDescription
        }
        
    }
    
    func updateUIWithPedometer(_ data: CMPedometerData) {
        
        DispatchQueue.main.async { [weak self] in
            self?.pedometerLabel.text = data.debugDescription
        }
        
    }
    
}

