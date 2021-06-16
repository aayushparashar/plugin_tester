import OpenGLES
import GLKit
import Accelerate

/// Options how to resize the result of effect player to display it on a target layer.
@objc public enum RenderContentMode: Int {
    /// Fits the content into a target layer by keeping its aspect ratio.
    case resizeAspect
    /// Fills a target layer with the content and maintains content's aspect ratio.
    case resizeAspectFill
    /// Makes the content the same size as a target layer by changing content's aspect ratio.
    case resize
}

public protocol SnapshotProvider {
    func makeSnapshotWithSettings(_ settings: OutputSettings, watermarkPixelBuffer: CVPixelBuffer?) -> UIImage?
}

public protocol PixelBufferProvider {
    func makeVideoPixelBuffer() -> CVPixelBuffer?
}

@objc public class RenderTarget: NSObject, SnapshotProvider, PixelBufferProvider {
    private var context: EAGLContext
    private var layer: CAEAGLLayer
    private(set) var renderSize: CGSize
    private var renderQueue: DispatchQueue
    
    private var textureCache: CVOpenGLESTextureCache?
    private var renderTarget: CVPixelBuffer?
    private var renderTexture: CVOpenGLESTexture?
    private var croppedRenderTarget: CVPixelBuffer?
    
    private var framebuffer: GLuint = 0
    private var framebuffer2: GLuint = 0
    private var colorRenderBuffer: GLuint = 0
    
    private let contentMode: RenderContentMode

    @objc init(
        context: EAGLContext,
        layer: CAEAGLLayer,
        renderSize: CGSize,
        contentMode: RenderContentMode,
        renderQueue: DispatchQueue
    ) {
        self.context = context
        self.layer = layer
        self.renderSize = renderSize
        self.contentMode = contentMode
        self.renderQueue = renderQueue
        super.init()
        setup()
    }
    
    @objc deinit {
        glDeleteFramebuffers(1, &framebuffer)
        glDeleteFramebuffers(1, &framebuffer2)
        glDeleteRenderbuffers(1, &colorRenderBuffer)
    }
    
    private func setup() {
        EAGLContext.setCurrent(context)
        
        let result = CVOpenGLESTextureCacheCreate(
            kCFAllocatorDefault, nil,
            context as CVEAGLContext,
            nil,
            &textureCache
        )
        
        if result != kCVReturnSuccess {
            assert(false, "Error at CVOpenGLESTextureCacheCreate")
        }
        
        let emptyAttributes: CFDictionary = [:] as CFDictionary
        let attributes: CFDictionary = [kCVPixelBufferIOSurfacePropertiesKey : emptyAttributes] as CFDictionary
        
        CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(renderSize.width),
            Int(renderSize.height),
            kCVPixelFormatType_32BGRA,
            attributes, &renderTarget
        )
        
        guard let textureCache = textureCache, let renderTarget = renderTarget else {
            assert(false, "Error at initializing texture cache pixelbuffer for RenderTarget")
            return
        }
        
        CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            textureCache,
            renderTarget,
            nil,
            GLenum(GL_TEXTURE_2D),
            GL_RGBA,
            GLsizei(renderSize.width),
            GLsizei(renderSize.height),
            GLenum(GL_BGRA),
            GLenum(GL_UNSIGNED_BYTE),
            0,
            &renderTexture
        )
        
        guard let renderTexture = renderTexture else {
            assert(false, "Error at initializing render texture for RenderTarget")
            return
        }
        
        glBindTexture(CVOpenGLESTextureGetTarget(renderTexture), CVOpenGLESTextureGetName(renderTexture))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLfloat(GL_CLAMP_TO_EDGE))
        glTexParameterf(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLfloat(GL_CLAMP_TO_EDGE))
        
        glGenFramebuffers(1, &framebuffer)
        glGenFramebuffers(1, &framebuffer2)
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer)
        
        glGenRenderbuffers(1, &colorRenderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        
        context.renderbufferStorage(Int(GL_RENDERBUFFER), from: layer)
        glFramebufferRenderbuffer(
            GLenum(GL_FRAMEBUFFER),
            GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_RENDERBUFFER), colorRenderBuffer
        )
        
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer2)
        glFramebufferTexture2D(
            GLenum(GL_FRAMEBUFFER),
            GLenum(GL_COLOR_ATTACHMENT0),
            GLenum(GL_TEXTURE_2D),
            CVOpenGLESTextureGetName(renderTexture),
            0
        )
    }
    
    @objc public func makeVideoPixelBuffer() -> CVPixelBuffer? {
        return renderTarget
    }
    
    @objc public func makeSnapshotWithSettings(_ settings: OutputSettings, watermarkPixelBuffer: CVPixelBuffer?) -> UIImage? {
        activate()
        
        guard let pixelBuffer = croppedRenderedVideoPixelBuffer else { return nil }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let dataLength: CFIndex = bytesPerRow * height
        
        CVPixelBufferLockBaseAddress(pixelBuffer, [])
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        guard let dataPointer = data?.bindMemory(to: UInt8.self, capacity: dataLength),
            let cfData = CFDataCreateMutable(kCFAllocatorDefault, dataLength) else { return nil }
        
        CFDataAppendBytes(cfData, UnsafePointer<UInt8>(dataPointer), dataLength)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        
        var sourceBufferInfo = vImage_Buffer(
            data: CFDataGetMutableBytePtr(cfData),
            height: UInt(height),
            width: UInt(width),
            rowBytes: bytesPerRow
        )
        
        if settings.shouldApplyVerticalFlip {
            vImageVerticalReflect_ARGB8888(&sourceBufferInfo, &sourceBufferInfo, UInt32(kvImageNoFlags))
        }
        if settings.shouldApplyHorizontalFlip {
            vImageHorizontalReflect_ARGB8888(&sourceBufferInfo, &sourceBufferInfo, UInt32(kvImageNoFlags))
        }
        
        if let watermarkBuffer = watermarkPixelBuffer {
            let watermarkWidth = CVPixelBufferGetWidth(watermarkBuffer)
            let watermarkHeight = CVPixelBufferGetHeight(watermarkBuffer)
            
            if width == watermarkWidth && height == watermarkHeight {
                CVPixelBufferLockBaseAddress(watermarkBuffer, [])
                
                var watermarkBufferInfo = vImage_Buffer(
                    data: CVPixelBufferGetBaseAddress(watermarkBuffer),
                    height: UInt(height),
                    width: UInt(width),
                    rowBytes: CVPixelBufferGetBytesPerRow(watermarkBuffer)
                )
                
                vImagePremultipliedAlphaBlend_BGRA8888(&watermarkBufferInfo, &sourceBufferInfo, &sourceBufferInfo, UInt32(kvImageNoFlags))
                
                CVPixelBufferUnlockBaseAddress(watermarkBuffer, [])
            }
        }
        
        let permuteMap: [UInt8] = [2, 1, 0, 3] // Convert to BGRA pixel format
        vImagePermuteChannels_ARGB8888(&sourceBufferInfo, &sourceBufferInfo, permuteMap, UInt32(kvImageNoFlags))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        guard let dataProvider = CGDataProvider(data: cfData) else { return nil }
        
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let cgImageRef = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        )
        
        guard let cgImage = cgImageRef else { return nil }
        
        return UIImage(cgImage: cgImage, scale: 1.0, orientation: settings.resultImageOrientation)
    }
    
    @objc public func activate() {
        EAGLContext.setCurrent(context)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), framebuffer2)
    }
    
    @objc public func clearRenderColor(r: GLclampf, g: GLclampf, b: GLclampf, a: GLclampf) {
        renderQueue.async {
            self.activate()
            glClearColor(r, g, b, a)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
            self.presentRenderbuffer(nil)
        }
    }
    
    @objc public func presentRenderbuffer(_ willPresentHandler: (() -> Void)?) {
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), colorRenderBuffer)
        glBindFramebuffer(GLenum(GL_READ_FRAMEBUFFER), framebuffer2)
        
        willPresentHandler?()
        
        glBindFramebuffer(GLenum(GL_DRAW_FRAMEBUFFER), framebuffer)
        
        let scrRect = srcBufferRect
        let dstRect = dstBufferRect
        
        if dstRect != pixelLayerBounds {
            glClearColor(0.0, 0.0, 0.0, 0.0)
            glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        }
        
        glBlitFramebuffer(
            GLint(scrRect.minX),
            GLint(scrRect.minY),
            GLint(scrRect.maxX),
            GLint(scrRect.maxY),
            GLint(dstRect.minX),
            GLint(dstRect.minY),
            GLint(dstRect.maxX),
            GLint(dstRect.maxY),
            GLbitfield(GL_COLOR_BUFFER_BIT),
            GLenum(GL_LINEAR)
        )
        context.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }

    private var croppedRenderedVideoPixelBuffer: CVPixelBuffer? {
        guard let renderTarget = renderTarget else { return nil }

        let cropRect = srcBufferRect
        let ciImage = CIImage(cvPixelBuffer: renderTarget)
        let croppedImage = ciImage.cropped(to: cropRect)

        return croppedImage.pixelBuffer ?? pixelBufferFromCIImage(croppedImage, rect: cropRect)
    }
    
    private func pixelBufferFromCIImage(_ image: CIImage, rect: CGRect) -> CVPixelBuffer? {
        if croppedRenderTarget == nil {
            let emptyAttributes: CFDictionary = [:] as CFDictionary
            let attributes: CFDictionary = [kCVPixelBufferIOSurfacePropertiesKey : emptyAttributes] as CFDictionary
            CVPixelBufferCreate(
                kCFAllocatorDefault,
                Int(rect.width),
                Int(rect.height),
                kCVPixelFormatType_32BGRA, attributes, &croppedRenderTarget
            )
        }
        
        guard let croppedRenderTarget = croppedRenderTarget else { return nil }

        CIContext().render(image, to: croppedRenderTarget)
        
        return croppedRenderTarget
    }
    
    private var pixelLayerBounds: CGRect {
        layer.bounds.applying(.init(scaleX: layer.contentsScale, y: layer.contentsScale))
    }
    
    private var srcBufferRect: CGRect {
        switch contentMode {
        case .resizeAspect, .resize:
            return .init(origin: .zero, size: renderSize)
        case .resizeAspectFill:
            return rect(from: .init(origin: .zero, size: renderSize), toResizeAspectFillRect: pixelLayerBounds)
        }
    }
    
    private var dstBufferRect: CGRect {
        switch contentMode {
        case .resizeAspectFill, .resize:
            return pixelLayerBounds
        case .resizeAspect:
            return rect(from: pixelLayerBounds, toResizeAspectFillRect: .init(origin: .zero, size: renderSize))
        }
    }
    
    private func rect(from rect: CGRect, toResizeAspectFillRect targetRect: CGRect) -> CGRect {
        guard targetRect.size.width > 0, targetRect.size.height > 0 else { return .zero }
        let minRatio = min(rect.size.width / targetRect.size.width, rect.size.height / targetRect.height)
        let size = targetRect.size.applying(.init(scaleX: minRatio, y: minRatio))
        let xInset = (rect.size.width - size.width) / 2
        let yInset = (rect.size.height - size.height) / 2
        let origin = rect.origin.applying(.init(translationX: xInset, y: yInset))
        return .init(origin: origin, size: size)
    }
}
