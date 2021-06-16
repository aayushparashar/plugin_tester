package io.agora.rtc.base

import android.content.Context
import android.view.SurfaceView
import android.widget.FrameLayout
import io.agora.rtc.RtcChannel
import io.agora.rtc.RtcEngine
import io.agora.rtc.video.VideoCanvas
import java.lang.ref.WeakReference
import com.banuba.sdk.manager.BanubaSdkManager
import android.util.Log

import android.Manifest
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.core.content.ContextCompat
import com.banuba.sdk.entity.RecordedVideoInfo
import com.banuba.sdk.manager.BanubaSdkTouchListener
import com.banuba.sdk.manager.IEventCallback
import com.banuba.sdk.types.Data
import io.agora.rtc.IRtcEngineEventHandler
import io.agora.rtc.video.AgoraVideoFrame

class RtcSurfaceView(
  context: Context
) : FrameLayout(context) {
  private var surface: SurfaceView
  private var canvas: VideoCanvas
  private var isMediaOverlay = false
  private var onTop = false
  private var channel: WeakReference<RtcChannel>? = null

  companion object {

    const val BANUBA_CLIENT_TOKEN = "CJOTaz7ChzHGe97okh0KcDRKfEC8pkAjGbiOTzWJyEaMqlrVtV87NGPBUPLRGelwp9IcJVPjeeYVAiDzShXDW7UsioCXOLTGR4VoKK+Ljg4e1qwndj3t2WaiwEeT6eOwCU3tZMQA5cZRzlvNSl5EDEj4gVIVGa4Wwcb+w/KF/RY1IztsFnz7JiDCIkCdTOF6FPkuaL9vq5bOcZ+rkS/Pd0M4IBykArCuBg7S02qSr1HVH/w635y4YZYetsYeoHL93ms+6Ktkw52/rsxMyfnSmZtQyCoFzgNg0NHbnuttoTA7Wki3seNJaqJE9CymwqojJxzYXL/8/1kg8uaQY13fJPlbjInQyFZzeG5dpV2jkDBMclsZ0HS5nVdJuJcfRAhiNsAZtSe0kVjVgpvaMSEaIaoU+La/DsK/BAZwta56fN8/o3sAiUaxzr7GbHplFNCOfBqN+7FAGv3sLpIJpxUoxbPgtl5y/f+vyGkDWr5+pzTZ5gIscm7GazIVibJb9wAGWXhuDJBc71GuI7HZzxKkJruCSwJnXBoEedBaGjqjAljwL8TDpAfvpxP12AG7r2FfGJR8t3mR+B/WbN3nIxlFx2xqAf88MoDiWzhMTeJuy577UmRUiolqS+dj/SukJUoMaXeB2IcnDCLEp84m/FkP06GAub5Y9l16TZRXxqIqmP8AD3EBXG0MfiF0XUvCaiqUdebKH4mz7vViBq8IFsI8cP1DPqWwLNYzpQBmY+h5OUUa/Mn7f/2dJX9qiVF/4F9jUKJhWLEnpVbQQWPIn+6fcCwplNdngg3B5/KSC7UZ04FcyIyBiyuYr83TV2K6mMgWJNmSNcZFfeqmPw6/CJQ9owmL7iFA/QotN2B9Fq1amWtsZU1FJah2jz6Cytgi9HFiAFf2OB17qfBBE4OG4EtTSkN/67VCqGb0FgL3BV0Cnixed8gNDr9uDi1H5KDMfFS+s05ZpsKt9K8SqOLqsjdrD2QJ+XQDIMyF7OuOy18upOhWhqeG4LRXZEfhityK2aUNVQErGheLbBkNRG2laJhmK/841dsO+JAjshEMpIZzkscN34+MgRk+R9R9VXtrBOybMr1Z6+b3vWGA05LMbF15MaU9uGxPwWXP6DNFYXpe8PoHEkvDp342xxoa92UhcSG0IdNVRkt6f5u8yPO/tm+QZSULKeWp2kp6ugOk1cosyRdgmgUOrkoDufKPujAITNee7vzkJfhb4TMhn5mwjcb9tMFZdcGdvQLF/MOiWI8wpOC+ICNXPwRzewQKAtqwlT0iHbZvqL0+0ssgc40fGliUOfEPxrjkD6DhD0RrA8bVHVdUtuRuMayhv0HgYz3FgSnPszTwIcSxvKGEb4JdgT64ZuROPvRDE/eGUKD2P+7tBU7Y8D37Oo3zXZH6Qq/Q4NFqtP0liHED1anjtmT9/to+fsskDeLOKsExcEwhFy3QSp29kTvX3tzdYqZ3VLDXkwQnMZNVKsP2L5zlUXH0tbPIJJSHKV+F5U6hoNhNVThQjPuUAwBFxy/IPUHp/5l7mSswRf6kfZG85Kblcd8G2YHq8xZd1Yvx6coHpIe+Mm3OyxMu0R4Tw2WT3ypwCZmST6e0svZfuYUJwgoQHkwLGjSXnzV2pfhK7ZtVC1a+nfZfOrgG66zT9L+Cvds/2NmXlF2tnOybuj0xA1810pQYTLxW9y+YeC+MbVbh3hTcpyWb4w8nydYeGcwoG+9tBV3ej/U+HsiYSMqfv1ltY9aqbLBWpKPz2kJ3fFHK2bDE9QXGZxg8/RrC4kjTeh5OmdnykJPSg9vXhOIUMLs5KKke6IlcKkgNnVvBPq3Ya2YFXCygJtSYOyBoZ32/NWflCe5Q78tsAkMdJeeQaMJyjx7G5fZj0Bd7K4VbnuqcZwthhb4q1bBj1i3yvYk2cgUmndi6UEG7yQ0d9Dbe2xxOM8gMW63zLUdLv4CRAyXw4PAyuIb0zWtbNDE7ekayAHIQOjQm+MScXyJUTif1bP+F"

    private const val MASK_NAME = "HeadphoneMusic"
  }

  private val banubaSdkManager by lazy(LazyThreadSafetyMode.NONE) {
    BanubaSdkManager(context.applicationContext)
  }

  private val maskUri by lazy(LazyThreadSafetyMode.NONE) {
    Uri.parse(BanubaSdkManager.getResourcesBase())
      .buildUpon()
      .appendPath("effects")
      .appendPath(MASK_NAME)
      .build()
  }

  private val agoraRtc: RtcEngine by lazy(LazyThreadSafetyMode.NONE) {
    RtcEngine.create(
      context,
      "3a7d00163f6d41d6b533653369d4ce0e",
      null
    )
  }

  init {
    try {
      Log.e("logggggggg","loggggggggg1")
      BanubaSdkManager.initialize(context.applicationContext,
        BANUBA_CLIENT_TOKEN
      )
      configureSdkManager()
      surface = RtcEngine.CreateRendererView(context)
      //surface = setupRemoteVideo(0)
      //canvas = VideoCanvas(surface, VideoCanvas.RENDER_MODE_HIDDEN, 0)
    //  configureRtcEngine()
      Log.e("logggggggg","loggggggggg2")

      banubaSdkManager.attachSurface(surface)
      banubaSdkManager.openCamera()

      Log.e("logggggggg","loggggggggg3")
    } catch (e: UnsatisfiedLinkError) {
      throw RuntimeException("Please init RtcEngine first!")
    }

//    surface = setupRemoteVideo(0)
    removeAllViews()
    canvas = VideoCanvas(surface)
    addView(surface)

    banubaSdkManager.effectPlayer.setEffectVolume(0F)
    banubaSdkManager.effectPlayer.playbackPlay()
    banubaSdkManager.startForwardingFrames()

    Log.e("logggggggg","loggggggggg4")
  }

  private fun configureSdkManager() {
    banubaSdkManager.effectManager.loadAsync(maskUri.toString())
  }

  private fun configureRtcEngine() {
    agoraRtc.setExternalVideoSource(true, false, true)
    agoraRtc.enableVideo()
  }

  private fun setupRemoteVideo(uid: Int): SurfaceView {
    surface = RtcEngine.CreateRendererView(context)
//    canvas = VideoCanvas(surface, VideoCanvas.RENDER_MODE_HIDDEN, uid)
    agoraRtc.setupRemoteVideo(canvas)
    return surface
  }

  fun setZOrderMediaOverlay(isMediaOverlay: Boolean) {
    this.isMediaOverlay = isMediaOverlay
    try {
      removeView(surface)
      surface.setZOrderMediaOverlay(isMediaOverlay)
      addView(surface)
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  fun setZOrderOnTop(onTop: Boolean) {
    this.onTop = onTop
    try {
      removeView(surface)
      surface.setZOrderOnTop(onTop)
      addView(surface)
    } catch (e: Exception) {
      e.printStackTrace()
    }
  }

  fun setData(engine: RtcEngine, channel: RtcChannel?, uid: Int) {
    this.channel = if (channel != null) WeakReference(channel) else null
    canvas.channelId = this.channel?.get()?.channelId()
    canvas.uid = uid
    setupVideoCanvas(engine)
  }

  fun resetVideoCanvas(engine: RtcEngine) {
    val canvas = VideoCanvas(null, canvas.renderMode, canvas.channelId, canvas.uid, canvas.mirrorMode)
    if (canvas.uid == 0) {
      engine.setupLocalVideo(canvas)
    } else {
      engine.setupRemoteVideo(canvas)
    }
  }

  private fun setupVideoCanvas(engine: RtcEngine) {
//    removeAllViews()
//    surface = RtcEngine.CreateRendererView(context.applicationContext)
//    surface.setZOrderMediaOverlay(isMediaOverlay)
//    surface.setZOrderOnTop(onTop)
//    addView(surface)
    surface.layout(0, 0, width, height)
    canvas.view = surface
    if (canvas.uid == 0) {
      engine.setupLocalVideo(canvas)
    } else {
      engine.setupRemoteVideo(canvas)
    }

    engine.setExternalVideoSource(true, false, true)
    engine.enableVideo()
  }

  fun setRenderMode(engine: RtcEngine, @Annotations.AgoraVideoRenderMode renderMode: Int) {
    canvas.renderMode = renderMode
    setupRenderMode(engine)
  }

  fun setMirrorMode(engine: RtcEngine, @Annotations.AgoraVideoMirrorMode mirrorMode: Int) {
    canvas.mirrorMode = mirrorMode
    setupRenderMode(engine)
  }

  private fun setupRenderMode(engine: RtcEngine) {
    if (canvas.uid == 0) {
      engine.setLocalRenderMode(canvas.renderMode, canvas.mirrorMode)
    } else {
      channel?.get()?.let {
        it.setRemoteRenderMode(canvas.uid, canvas.renderMode, canvas.mirrorMode)
        return@setupRenderMode
      }
      engine.setRemoteRenderMode(canvas.uid, canvas.renderMode, canvas.mirrorMode)
    }
  }

  override fun onMeasure(widthMeasureSpec: Int, heightMeasureSpec: Int) {
    val width: Int = MeasureSpec.getSize(widthMeasureSpec)
    val height: Int = MeasureSpec.getSize(heightMeasureSpec)
    surface.layout(0, 0, width, height)
    super.onMeasure(widthMeasureSpec, heightMeasureSpec)
  }
}
