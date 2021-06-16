package io.agora.agora_rtc_engine

import android.content.Context
import android.graphics.Bitmap
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.banuba.sdk.entity.RecordedVideoInfo
import com.banuba.sdk.manager.BanubaSdkManager
import com.banuba.sdk.manager.BanubaSdkTouchListener
import com.banuba.sdk.manager.IEventCallback
import com.banuba.sdk.types.Data
import io.agora.rtc.RtcEngine
import io.agora.rtc.base.RtcEngineManager
import io.agora.rtc.video.AgoraVideoFrame
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.flutter.plugin.platform.PlatformViewRegistry
import kotlin.reflect.full.declaredMemberFunctions
import kotlin.reflect.jvm.javaMethod

/** AgoraRtcEnginePlugin */
class AgoraRtcEnginePlugin : FlutterPlugin, MethodCallHandler, EventChannel.StreamHandler {
  private var registrar: Registrar? = null
  private var binding: FlutterPlugin.FlutterPluginBinding? = null
  private lateinit var applicationContext: Context
  private val MASK_NAME = "HeadphoneMusic"

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel

  private var eventSink: EventChannel.EventSink? = null
  private val manager = RtcEngineManager { methodName, data -> emit(methodName, data) }
  private val handler = Handler(Looper.getMainLooper())
  private val rtcChannelPlugin = AgoraRtcChannelPlugin(this)

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //fsaf
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    const val BANUBA_CLIENT_TOKEN = "CJOTaz7ChzHGe97okh0KcDRKfEC8pkAjGbiOTzWJyEaMqlrVtV87NGPBUPLRGelwp9IcJVPjeeYVAiDzShXDW7UsioCXOLTGR4VoKK+Ljg4e1qwndj3t2WaiwEeT6eOwCU3tZMQA5cZRzlvNSl5EDEj4gVIVGa4Wwcb+w/KF/RY1IztsFnz7JiDCIkCdTOF6FPkuaL9vq5bOcZ+rkS/Pd0M4IBykArCuBg7S02qSr1HVH/w635y4YZYetsYeoHL93ms+6Ktkw52/rsxMyfnSmZtQyCoFzgNg0NHbnuttoTA7Wki3seNJaqJE9CymwqojJxzYXL/8/1kg8uaQY13fJPlbjInQyFZzeG5dpV2jkDBMclsZ0HS5nVdJuJcfRAhiNsAZtSe0kVjVgpvaMSEaIaoU+La/DsK/BAZwta56fN8/o3sAiUaxzr7GbHplFNCOfBqN+7FAGv3sLpIJpxUoxbPgtl5y/f+vyGkDWr5+pzTZ5gIscm7GazIVibJb9wAGWXhuDJBc71GuI7HZzxKkJruCSwJnXBoEedBaGjqjAljwL8TDpAfvpxP12AG7r2FfGJR8t3mR+B/WbN3nIxlFx2xqAf88MoDiWzhMTeJuy577UmRUiolqS+dj/SukJUoMaXeB2IcnDCLEp84m/FkP06GAub5Y9l16TZRXxqIqmP8AD3EBXG0MfiF0XUvCaiqUdebKH4mz7vViBq8IFsI8cP1DPqWwLNYzpQBmY+h5OUUa/Mn7f/2dJX9qiVF/4F9jUKJhWLEnpVbQQWPIn+6fcCwplNdngg3B5/KSC7UZ04FcyIyBiyuYr83TV2K6mMgWJNmSNcZFfeqmPw6/CJQ9owmL7iFA/QotN2B9Fq1amWtsZU1FJah2jz6Cytgi9HFiAFf2OB17qfBBE4OG4EtTSkN/67VCqGb0FgL3BV0Cnixed8gNDr9uDi1H5KDMfFS+s05ZpsKt9K8SqOLqsjdrD2QJ+XQDIMyF7OuOy18upOhWhqeG4LRXZEfhityK2aUNVQErGheLbBkNRG2laJhmK/841dsO+JAjshEMpIZzkscN34+MgRk+R9R9VXtrBOybMr1Z6+b3vWGA05LMbF15MaU9uGxPwWXP6DNFYXpe8PoHEkvDp342xxoa92UhcSG0IdNVRkt6f5u8yPO/tm+QZSULKeWp2kp6ugOk1cosyRdgmgUOrkoDufKPujAITNee7vzkJfhb4TMhn5mwjcb9tMFZdcGdvQLF/MOiWI8wpOC+ICNXPwRzewQKAtqwlT0iHbZvqL0+0ssgc40fGliUOfEPxrjkD6DhD0RrA8bVHVdUtuRuMayhv0HgYz3FgSnPszTwIcSxvKGEb4JdgT64ZuROPvRDE/eGUKD2P+7tBU7Y8D37Oo3zXZH6Qq/Q4NFqtP0liHED1anjtmT9/to+fsskDeLOKsExcEwhFy3QSp29kTvX3tzdYqZ3VLDXkwQnMZNVKsP2L5zlUXH0tbPIJJSHKV+F5U6hoNhNVThQjPuUAwBFxy/IPUHp/5l7mSswRf6kfZG85Kblcd8G2YHq8xZd1Yvx6coHpIe+Mm3OyxMu0R4Tw2WT3ypwCZmST6e0svZfuYUJwgoQHkwLGjSXnzV2pfhK7ZtVC1a+nfZfOrgG66zT9L+Cvds/2NmXlF2tnOybuj0xA1810pQYTLxW9y+YeC+MbVbh3hTcpyWb4w8nydYeGcwoG+9tBV3ej/U+HsiYSMqfv1ltY9aqbLBWpKPz2kJ3fFHK2bDE9QXGZxg8/RrC4kjTeh5OmdnykJPSg9vXhOIUMLs5KKke6IlcKkgNnVvBPq3Ya2YFXCygJtSYOyBoZ32/NWflCe5Q78tsAkMdJeeQaMJyjx7G5fZj0Bd7K4VbnuqcZwthhb4q1bBj1i3yvYk2cgUmndi6UEG7yQ0d9Dbe2xxOM8gMW63zLUdLv4CRAyXw4PAyuIb0zWtbNDE7ekayAHIQOjQm+MScXyJUTif1bP+F"

    @JvmStatic
    fun registerWith(registrar: Registrar) {
      AgoraRtcEnginePlugin().apply {
        this.registrar = registrar
        rtcChannelPlugin.initPlugin(registrar.messenger())
        initPlugin(registrar.context(), registrar.messenger(), registrar.platformViewRegistry())
      }
    }
  }

  private fun initPlugin(context: Context, binaryMessenger: BinaryMessenger, platformViewRegistry: PlatformViewRegistry) {
    applicationContext = context.applicationContext
//    BanubaSdkManager.initialize(applicationContext,
//      BANUBA_CLIENT_TOKEN
//    )
   // configureSdkManager()
    methodChannel = MethodChannel(binaryMessenger, "agora_rtc_engine")
    methodChannel.setMethodCallHandler(this)
    eventChannel = EventChannel(binaryMessenger, "agora_rtc_engine/events")
    eventChannel.setStreamHandler(this)
    platformViewRegistry.registerViewFactory("AgoraSurfaceView", AgoraSurfaceViewFactory(binaryMessenger, this, rtcChannelPlugin))
    platformViewRegistry.registerViewFactory("AgoraTextureView", AgoraTextureViewFactory(binaryMessenger, this, rtcChannelPlugin))
//    banubaSdkManager.attachSurface(platformViewRegistry)
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    this.binding = binding
    rtcChannelPlugin.onAttachedToEngine(binding)
    initPlugin(binding.applicationContext, binding.binaryMessenger, binding.platformViewRegistry)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    rtcChannelPlugin.onDetachedFromEngine(binding)
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    manager.release()
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
    eventSink = events
  }

  override fun onCancel(arguments: Any?) {
    eventSink = null
  }

  private fun emit(methodName: String, data: Map<String, Any?>?) {
    handler.post {
      val event: MutableMap<String, Any?> = mutableMapOf("methodName" to methodName)
      data?.let { event.putAll(it) }
      eventSink?.success(event)
    }
  }

  fun engine(): RtcEngine? {
    return manager.engine
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getAssetAbsolutePath") {
      getAssetAbsolutePath(call, result)
      return
    }

    manager::class.declaredMemberFunctions.find { it.name == call.method }?.let { function ->
      function.javaMethod?.let { method ->
        try {
          val parameters = mutableListOf<Any?>()
          call.arguments<Map<*, *>>()?.toMutableMap()?.let {
            if (call.method == "create") {
              it["context"] = applicationContext
            }
            parameters.add(it)
          }
          method.invoke(manager, *parameters.toTypedArray(), ResultCallback(result))
          return@onMethodCall
        } catch (e: Exception) {
          e.printStackTrace()
        }
      }
    }
    result.notImplemented()
  }

  fun getAssetAbsolutePath(call: MethodCall, result: Result) {
    call.arguments<String>()?.let {
      val assetKey = registrar?.lookupKeyForAsset(it)
        ?: binding?.flutterAssets?.getAssetFilePathByName(it)
      try {
        applicationContext.assets.openFd(assetKey!!).close()
        result.success("/assets/$assetKey")
      } catch (e: Exception) {
        result.error(e.javaClass.simpleName, e.message, e.cause)
      }
      return@getAssetAbsolutePath
    }
    result.error(IllegalArgumentException::class.simpleName, null, null)
  }

//  val banubaSdkManager by lazy(LazyThreadSafetyMode.NONE) {
//    BanubaSdkManager(applicationContext)
//  }
//
//  private fun configureSdkManager() {
//    banubaSdkManager.effectManager.loadAsync(maskUri.toString())
//  }
//
//  private val maskUri by lazy(LazyThreadSafetyMode.NONE) {
//    Uri.parse(BanubaSdkManager.getResourcesBase())
//      .buildUpon()
//      .appendPath("effects")
//      .appendPath(MASK_NAME)
//      .build()
//
//
//  }


}
