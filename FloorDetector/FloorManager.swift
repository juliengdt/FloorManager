//
//  FloorManager.swift
//  FloorDetector
//
//  Created by Julien Goudet on 21/06/2019.
//  Copyright © 2019 Hootcode. All rights reserved.
//

import Foundation
import CoreMotion


/* CMDeviceMotion Tips
 
 *    Returns the attitude of the device.
 open var attitude: CMAttitude { get }

 *    Returns the rotation rate of the device for devices with a gyro.
 open var rotationRate: CMRotationRate { get }
 
 *    Returns the gravity vector expressed in the device's reference frame.
 open var gravity: CMAcceleration { get }
 
 *    Returns the acceleration that the user is giving to the device.
 open var userAcceleration: CMAcceleration { get }
 
 *    Returns the magnetic field vector with respect to the device for devices with a magnetometer.
 open var magneticField: CMCalibratedMagneticField { get }
 
 *    Returns heading angle in the range [0,360) degrees with respect to the CMAttitude reference frame.
 *    A negative value is returned for CMAttitudeReferenceFrameXArbitraryZVertical and CMAttitudeReferenceFrameXArbitraryCorrectedZVertical.
 open var heading: Double { get }
 
 */


/* CMAccelerometer Tips
 
 *    The acceleration measured by the accelerometer.
 open var acceleration: CMAcceleration { get }
 
 *  CMAcceleration - A structure containing 3-axis acceleration data.
 *    x: X-axis acceleration in G's.
 *    y: Y-axis acceleration in G's.
 *    z: Z-axis acceleration in G's.

 */


/* CMMotionActitivty Tips
 

 *    A confidence estimate associated with this state.
@property(readonly, nonatomic) CMMotionActivityConfidence confidence;

 *    Time at which the activity started.
@property(readonly, nonatomic) NSDate *startDate;

 *    True if there is no estimate of the current state.  This can happen if the device was turned off.
@property(readonly, nonatomic) BOOL unknown;

 *    True if the device is not moving.
@property(readonly, nonatomic) BOOL stationary;

 *    True if the device is on a walking person.
@property(readonly, nonatomic) BOOL walking;

 *    True if the device is on a running person.
@property(readonly, nonatomic) BOOL running;

 *    True if the device is in a vehicle.
@property(readonly, nonatomic) BOOL automotive;

 *    True if the device is on a bicycle.
@property(readonly, nonatomic) BOOL cycling NS_AVAILABLE(NA, 8_0);
 
 */



/* CMPedometer Tips
 
 *      The start time of the period for which the pedometer data is valid.
 open var startDate: Date { get }
 
 *      The end time of the period for which the pedometer data is valid.
 open var endDate: Date { get }
 
 *      Number of steps taken by the user.
 open var numberOfSteps: NSNumber { get }
 
 *      Estimated distance in meters traveled by the user while walking and running.
 open var distance: NSNumber? { get }
 
 *      Approximate number of floors ascended by way of stairs.
 open var floorsAscended: NSNumber? { get }
 
 *      Approximate number of floors descended by way of stairs.
 open var floorsDescended: NSNumber? { get }
 
 *      For updates this returns the current pace, in s/m (seconds per meter)
 open var currentPace: NSNumber? { get }
 
 *      For updates this returns the rate at which steps are taken, in steps per second.
 open var currentCadence: NSNumber? { get }
 
 *      For updates this returns the average active pace since
 *      startPedometerUpdatesFromDate:withHandler:, in s/m (seconds per meter)
 open var averageActivePace: NSNumber? { get }

 */



enum FloorEvent {
    case motion(data: CMDeviceMotion)
    case acceleration(data: CMAcceleration)
    case activity(data: CMMotionActivity)
}

enum FloorError: Error {
    case noMotion
    case noAcceleration
    case noActivity
    
    var localizedDescription: String {
        switch self {
        case .noMotion:
            return "No motion data given by Apple CoreMotion framework"
        case .noAcceleration:
            return "No acceleration data given by Apple CoreMotion framework"
        case .noActivity:
            return "No motion activity given by Apple CoreMotion framework"
        }
    }
    
    
}

protocol FloorManagerDelegate: class {
    func didReceiveNewFloorEvent(_ event: FloorEvent)
    func didReceiveFloorError(_ error: Error)
}

class FloorManager {
    
    static let instance: FloorManager = FloorManager()
    
    private let coremotionQueue: OperationQueue
    private let coremotion: CMMotionManager
    private let coremotionPedometer: CMPedometer
    private let coremotionActivity: CMMotionActivityManager
    
    private var lastPedometerEvent: CMPedometerEvent?
    
    private weak var delegate: FloorManagerDelegate?
    
    private init() {
        
        coremotionQueue = OperationQueue()
        coremotionQueue.maxConcurrentOperationCount = 1
        coremotionQueue.qualityOfService = .background
        
        coremotion = CMMotionManager()
        coremotion.accelerometerUpdateInterval = 0.1
        coremotion.deviceMotionUpdateInterval = 0.1
        
        coremotionPedometer = CMPedometer()

        coremotionActivity = CMMotionActivityManager()
        
    }
    
    func startUpdateWith(delegate: FloorManagerDelegate) {
        
        self.delegate = delegate
        
        if coremotion.isDeviceMotionActive == false {
            coremotion.startDeviceMotionUpdates(using: .xMagneticNorthZVertical, to: self.coremotionQueue) { [weak self] (motion, error) in
                if let _err = error {
                    self?.delegate?.didReceiveFloorError(_err)
                    return
                }
                                                    
                guard let _motion = motion else {
                    self?.delegate?.didReceiveFloorError(FloorError.noMotion)
                    return
                }
                
                self?.delegate?.didReceiveNewFloorEvent(.motion(data: _motion))
                
            }
        }
        
        if coremotion.isAccelerometerActive == false {
            coremotion.startAccelerometerUpdates(to: self.coremotionQueue) { [weak self] (acceleration, error) in
                if let _err = error {
                    self?.delegate?.didReceiveFloorError(_err)
                    return
                }
                
                guard let _acceleration = acceleration else {
                    self?.delegate?.didReceiveFloorError(FloorError.noAcceleration)
                    return
                }
                
                self?.delegate?.didReceiveNewFloorEvent(.acceleration(data: _acceleration.acceleration))
                
                
            }
        }
        
        coremotionActivity.stopActivityUpdates()
        coremotionActivity.startActivityUpdates(to: self.coremotionQueue) { [weak self] (activity) in
            
            guard let _activity = activity else {
                self?.delegate?.didReceiveFloorError(FloorError.noActivity)
                return
            }
            
            self?.delegate?.didReceiveNewFloorEvent(.activity(data: _activity))
            
        }
        
        coremotionPedometer.stopUpdates()
        coremotionPedometer.stopEventUpdates()
        
        coremotionPedometer.startEventUpdates { [weak self] (pedometerEvent, error) in
            
            guard let _event = pedometerEvent else { return }
            self?.lastPedometerEvent = _event
            
        }
        
        coremotionPedometer.startUpdates(from: Date().addingTimeInterval(-120)) { [weak self] (pedometer, error) in
            
            guard let _pedometer = pedometer else { return }
            
            
        
            
            
            
        }
        
        
    }
    
    func stopUpdate() {
        coremotion.stopDeviceMotionUpdates()
        coremotion.stopAccelerometerUpdates()
        coremotionActivity.stopActivityUpdates()
        coremotionPedometer.stopUpdates()
        coremotionPedometer.stopEventUpdates()
        coremotionQueue.cancelAllOperations()
    }
    
    
    deinit {
        delegate = nil
        coremotion.stopDeviceMotionUpdates()
        coremotion.stopAccelerometerUpdates()
        coremotionActivity.stopActivityUpdates()
        coremotionPedometer.stopUpdates()
        coremotionPedometer.stopEventUpdates()
        coremotionQueue.cancelAllOperations()
    }
    
    
}
