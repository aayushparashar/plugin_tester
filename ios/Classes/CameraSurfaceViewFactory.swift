//
//  BanubaSurfaceViewFactory.swift
//  agora_rtc_engine
//
//  Created by LXH on 2020/6/28.
//

import Foundation

class CameraSurfaceViewFactory: NSObject, FlutterPlatformViewFactory {
    private final weak var messager: FlutterBinaryMessenger?
    private final weak var rtcEnginePlugin: SwiftAgoraRtcEnginePlugin?
    private final weak var rtcChannelPlugin: AgoraRtcChannelPlugin?

    init(_ messager: FlutterBinaryMessenger, _ rtcEnginePlugin: SwiftAgoraRtcEnginePlugin, _ rtcChannelPlugin: AgoraRtcChannelPlugin) {
        self.messager = messager
        self.rtcEnginePlugin = rtcEnginePlugin
        self.rtcChannelPlugin = rtcChannelPlugin
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        FlutterStandardMessageCodec.sharedInstance()
    }

    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return CameraSurfaceView(messager!, frame, viewId, args as? Dictionary<String, Any?>, rtcEnginePlugin!, rtcChannelPlugin!)
    }
}

class CameraSurfaceView: NSObject, FlutterPlatformView {
    private final weak var rtcEnginePlugin: SwiftAgoraRtcEnginePlugin?
    private final weak var rtcChannelPlugin: AgoraRtcChannelPlugin?
    private let _view: BanubaSurfaceView
    private let channel: FlutterMethodChannel

    init(_ messager: FlutterBinaryMessenger, _ frame: CGRect, _ viewId: Int64, _ args: Dictionary<String, Any?>?, _ rtcEnginePlugin: SwiftAgoraRtcEnginePlugin, _ rtcChannelPlugin: AgoraRtcChannelPlugin) {
        self.rtcEnginePlugin = rtcEnginePlugin
        self.rtcChannelPlugin = rtcChannelPlugin
        self._view = BanubaSurfaceView.init(frame: frame, ((args!["data"] as! NSDictionary)["uid"] as! NSNumber).uintValue)
        self.channel = FlutterMethodChannel(name: "agora_rtc_engine/banuba_surface_view_\(viewId)", binaryMessenger: messager)
        super.init()
        if let map = args {
            setData(map["data"] as! NSDictionary)
        }
        channel.setMethodCallHandler { [weak self] (call, result) in
            var args = [String: Any?]()
            if let arguments = call.arguments {
                args = arguments as! Dictionary<String, Any?>
            }
            switch call.method {
            case "setData":
                self?.setData(args["data"] as! NSDictionary)
            
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    func view() -> UIView {
        return _view
    }

    deinit {
        channel.setMethodCallHandler(nil)
    }

    func setData(_ data: NSDictionary) {
        _view.setData((data["uid"] as! NSNumber).uintValue, (data["effectName"] as? String))
    }
}
