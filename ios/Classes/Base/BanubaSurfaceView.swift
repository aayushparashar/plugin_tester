//
//  BanubaSurfaceView.swift

import Foundation
import UIKit

class BanubaSurfaceView: UIView {
    private var surface: EffectPlayerView
    private var banubaSdkManager = BanubaSdkManager()
    
    private var effectName : String?
    
    internal let banubaClientToken = "CJOTaz7ChzHGe97okh0KcDRKfEC8pkAjGbiOTzWJyEaMqlrVtV87NGPBUPLRGelwp9IcJVPjeeYVAiDzShXDW7UsioCXOLTGR4VoKK+Ljg4e1qwndj3t2WaiwEeT6eOwCU3tZMQA5cZRzlvNSl5EDEj4gVIVGa4Wwcb+w/KF/RY1IztsFnz7JiDCIkCdTOF6FPkuaL9vq5bOcZ+rkS/Pd0M4IBykArCuBg7S02qSr1HVH/w635y4YZYetsYeoHL93ms+6Ktkw52/rsxMyfnSmZtQyCoFzgNg0NHbnuttoTA7Wki3seNJaqJE9CymwqojJxzYXL/8/1kg8uaQY13fJPlbjInQyFZzeG5dpV2jkDBMclsZ0HS5nVdJuJcfRAhiNsAZtSe0kVjVgpvaMSEaIaoU+La/DsK/BAZwta56fN8/o3sAiUaxzr7GbHplFNCOfBqN+7FAGv3sLpIJpxUoxbPgtl5y/f+vyGkDWr5+pzTZ5gIscm7GazIVibJb9wAGWXhuDJBc71GuI7HZzxKkJruCSwJnXBoEedBaGjqjAljwL8TDpAfvpxP12AG7r2FfGJR8t3mR+B/WbN3nIxlFx2xqAf88MoDiWzhMTeJuy577UmRUiolqS+dj/SukJUoMaXeB2IcnDCLEp84m/FkP06GAub5Y9l16TZRXxqIqmP8AD3EBXG0MfiF0XUvCaiqUdebKH4mz7vViBq8IFsI8cP1DPqWwLNYzpQBmY+h5OUUa/Mn7f/2dJX9qiVF/4F9jUKJhWLEnpVbQQWPIn+6fcCwplNdngg3B5/KSC7UZ04FcyIyBiyuYr83TV2K6mMgWJNmSNcZFfeqmPw6/CJQ9owmL7iFA/QotN2B9Fq1amWtsZU1FJah2jz6Cytgi9HFiAFf2OB17qfBBE4OG4EtTSkN/67VCqGb0FgL3BV0Cnixed8gNDr9uDi1H5KDMfFS+s05ZpsKt9K8SqOLqsjdrD2QJ+XQDIMyF7OuOy18upOhWhqeG4LRXZEfhityK2aUNVQErGheLbBkNRG2laJhmK/841dsO+JAjshEMpIZzkscN34+MgRk+R9R9VXtrBOybMr1Z6+b3vWGA05LMbF15MaU9uGxPwWXP6DNFYXpe8PoHEkvDp342xxoa92UhcSG0IdNVRkt6f5u8yPO/tm+QZSULKeWp2kp6ugOk1cosyRdgmgUOrkoDufKPujAITNee7vzkJfhb4TMhn5mwjcb9tMFZdcGdvQLF/MOiWI8wpOC+ICNXPwRzewQKAtqwlT0iHbZvqL0+0ssgc40fGliUOfEPxrjkD6DhD0RrA8bVHVdUtuRuMayhv0HgYz3FgSnPszTwIcSxvKGEb4JdgT64ZuROPvRDE/eGUKD2P+7tBU7Y8D37Oo3zXZH6Qq/Q4NFqtP0liHED1anjtmT9/to+fsskDeLOKsExcEwhFy3QSp29kTvX3tzdYqZ3VLDXkwQnMZNVKsP2L5zlUXH0tbPIJJSHKV+F5U6hoNhNVThQjPuUAwBFxy/IPUHp/5l7mSswRf6kfZG85Kblcd8G2YHq8xZd1Yvx6coHpIe+Mm3OyxMu0R4Tw2WT3ypwCZmST6e0svZfuYUJwgoQHkwLGjSXnzV2pfhK7ZtVC1a+nfZfOrgG66zT9L+Cvds/2NmXlF2tnOybuj0xA1810pQYTLxW9y+YeC+MbVbh3hTcpyWb4w8nydYeGcwoG+9tBV3ej/U+HsiYSMqfv1ltY9aqbLBWpKPz2kJ3fFHK2bDE9QXGZxg8/RrC4kjTeh5OmdnykJPSg9vXhOIUMLs5KKke6IlcKkgNnVvBPq3Ya2YFXCygJtSYOyBoZ32/NWflCe5Q78tsAkMdJeeQaMJyjx7G5fZj0Bd7K4VbnuqcZwthhb4q1bBj1i3yvYk2cgUmndi6UEG7yQ0d9Dbe2xxOM8gMW63zLUdLv4CRAyXw4PAyuIb0zWtbNDE7ekayAHIQOjQm+MScXyJUTif1bP+F"
    
    private let config = EffectPlayerConfiguration(renderMode: .video)
    
    var torceMode: AVCaptureDevice.TorchMode = AVCaptureDevice.TorchMode.on
    
    init(frame: CGRect, _ uid: UInt) {
        //            BanubaSdkManager.deinitialize()
        //            BanubaSdkManager.initialize(
        //                resourcePath: [Bundle.main.bundlePath + "/effects"], clientTokenString: banubaClientToken)
        
        surface = EffectPlayerView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)))
        //surface.layoutIfNeeded()
        banubaSdkManager.setup(configuration: config)
        //            banubaSdkManager.setRenderTarget(layer: surface.layer as! CAEAGLLayer, contentMode : RenderContentMode.resizeAspectFill, playerConfiguration: nil)
        
        
        surface.contentMode = UIView.ContentMode.scaleAspectFit
        super.init(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)))
        addSubview(surface)
        addObserver(self, forKeyPath: observerForKeyPath(), options: .new, context: nil)
        
        setUpRenderSize()
        surface.effectPlayer = banubaSdkManager.effectPlayer
                
        NotificationCenter.default.addObserver(self, selector: #selector(onEffectChange), name: .effectChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onCameraModeChange), name: .cameraModeChangeNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(flashModeChange), name: .flashModeChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(videoRecordChange), name: .videoRecodingChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioRecordChange), name: .audioChangeNotification, object: nil)
        
//        banubaSdkManager.input.switchCamera(to: .BackCameraVideoSession) {
//            print("Camera Switched")
//            _ = self.banubaSdkManager.input.setTorch(mode: self.torceMode)
//        }
    }
    
    func setUpRenderSize() {
        switch UIApplication.shared.statusBarOrientation {
        case .portrait:
            config.orientation = .deg90
            config.renderSize = CGSize(width: 720, height: 1280)
            banubaSdkManager.autoRotationEnabled = false
            setUpRenderTarget()
        case .portraitUpsideDown:
            config.orientation = .deg270
            config.renderSize = CGSize(width: 720, height: 1280)
            setUpRenderTarget()
        case .landscapeLeft:
            config.orientation = .deg180
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        case .landscapeRight:
            config.orientation = .deg0
            config.renderSize = CGSize(width: 1280, height: 720)
            setUpRenderTarget()
        default:
            setUpRenderTarget()
        }
    }
    
    private func setUpRenderTarget() {
        guard let effectView = self.surface.layer as? CAEAGLLayer else { return }
        banubaSdkManager.setRenderTarget(layer: effectView, playerConfiguration: nil)
        banubaSdkManager.startEffectPlayer()
    }
    
    @objc func onEffectChange(notification: Notification) {
        //        print("On select effect myFunction \(notification.object) ==== \(banubaSdkManager.currentEffect())" );
        banubaSdkManager.stopEffectPlayer()
        
        if let effectName = notification.object as? String {
            self.effectName = effectName
            _ = banubaSdkManager.loadEffect(effectName)
        }
        banubaSdkManager.startEffectPlayer()
    }
    
    @objc func onCameraModeChange(notification: Notification) {
        
        let cameraMode = banubaSdkManager.input.currentCameraSessionType
        var newCameraMode : CameraSessionType
        if (cameraMode == .FrontCameraVideoSession) {
            newCameraMode = .BackCameraVideoSession
        } else if (cameraMode == .BackCameraVideoSession) {
            newCameraMode = .FrontCameraVideoSession
        } else if (cameraMode == .FrontCameraPhotoSession) {
            newCameraMode = .BackCameraPhotoSession
        } else {
            newCameraMode = .FrontCameraPhotoSession
        }
        banubaSdkManager.input.switchCamera(to: newCameraMode) {
            print("Camera Switched")
        }
    }
    
    @objc func flashModeChange(notification: Notification) {
        torceMode = banubaSdkManager.input.setTorch(mode: torceMode == .on ? AVCaptureDevice.TorchMode.off : AVCaptureDevice.TorchMode.on)
    }
    var fileNameCount : Int = 1
    @objc func videoRecordChange(notification: Notification) {
        print("Start Stop Video Record")
        if let fileUrl = notification.object as? String {
            if (banubaSdkManager.output?.isRecording ?? false) {
                fileNameCount += 1
                banubaSdkManager.output?.stopVideoCapturing(cancel: false)
                banubaSdkManager.input.stopAudioCapturing()
            }
            else {
                banubaSdkManager.input.startAudioCapturing()
                
                banubaSdkManager.output?.startVideoCapturing(fileURL: URL(fileURLWithPath: fileUrl), completion: { (status, error) in
                    print("Start Video \(fileUrl) === \(status) === \(String(describing: error))")
                })
            }
        }
    }
    
    @objc func audioRecordChange(notification: Notification) {
        if let isAudio = notification.object as? Bool {
            if (isAudio) {
                banubaSdkManager.input.startAudioCapturing()
            } else {
                banubaSdkManager.input.stopAudioCapturing()
            }
        }
    }
    
    func observerForKeyPath() -> String {
        return "frame"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self, name: .effectChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .cameraModeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .flashModeChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .videoRecodingChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: .audioChangeNotification, object: nil)
        
        removeObserver(self, forKeyPath: observerForKeyPath(), context: nil)
    }
    
    func setData(_ uid: UInt, _ effectName: String?) {
        print("Effect \(effectName)")
        
        self.effectName = effectName
    }
    
    override func layoutSubviews() {
        
        banubaSdkManager.input.startCamera()
        if (self.effectName != nil) {
            _ = banubaSdkManager.loadEffect(self.effectName ?? "")
        }
        banubaSdkManager.startEffectPlayer()
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == observerForKeyPath() {
            if let rect = change?[.newKey] as? CGRect {
                surface.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: rect.size)
            }
        }
    }
    
}
