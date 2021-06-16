extension BanubaSdkManager {
    //TODO: Check Performance
    class DisplayLinkRunLoop {
        var isStoped = true
        private var preRender = [() -> Void]()
        private var postRender = [() -> Void]()
        let renderWork: () -> Bool
        private let queue: DispatchQueue
        public var renderQueue: DispatchQueue {
            if !isStoped {
                print("DisplayLinkRunLoop: Runloop is running, any tasks in renderQueue will not be executed till Runloop is stopped")
            }
            return queue
        }
        
        init(
            label:String,
            renderWork work:@escaping () -> Bool
        ) {
            self.queue = DispatchQueue(label: label, qos: .userInitiated)
            self.renderWork = work
        }
        
        func addPreRender(preRenderWork:@escaping () -> Void) {
            if isStoped {
                preRender.append(preRenderWork)
            }
        }
        
        func addPostRender(postRenderWork:@escaping () -> Void) {
            if isStoped {
                postRender.append(postRenderWork)
            }
        }
        
        func start(framerate: Int) {
            queue.async { [weak self] in
                guard let `self` = self, !self.isStoped else { return }
                let runLoop = RunLoop.current
                let displayLink = CADisplayLink(target: self, selector: #selector(self.doWork))
                displayLink.preferredFramesPerSecond = framerate
                displayLink.add(to: runLoop, forMode: .default)
                defer { displayLink.invalidate() }
                let distantFuture = Date.distantFuture
                repeat {
                    runLoop.run(mode: .default, before: distantFuture)
                } while !self.isStoped
            }
        }
        
        func removeAllHandlers() {
          preRender = []
          postRender = []
        }
        
        @objc func doWork() {
            preRender.forEach { work in
                work()
            }
            let drawedSuccessfully = renderWork()
            if !drawedSuccessfully {
                return
            }
            postRender.forEach { work in
                work()
            }
        }
    }
}
