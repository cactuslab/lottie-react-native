#if canImport(React)
import React
#endif

import Lottie

@objc(LottieAnimationView)
class AnimationViewManagerModule: RCTViewManager {
    override func view() -> UIView! {
        return ContainerView()
    }
    
    @objc override func constantsToExport() -> [AnyHashable : Any]! {
        return ["VERSION": 1]
    }
    
    
    @objc(play:fromFrame:toFrame:)
    public func play(_ reactTag: NSNumber, startFrame: NSNumber, endFrame: NSNumber) {
        
        self.bridge.uiManager.addUIBlock { (uiManager, viewRegistry) in
            guard let view = viewRegistry?[reactTag] as? ContainerView else {
                if (RCT_DEV == 1) {
                    print("Invalid view returned from registry, expecting ContainerView")
                }
                return
            }

            let onStart: LottieBlock = {
                if let onStart = view.onAnimationFinish {
                    onStart([:])
                }
            }
            
            let callback: LottieCompletionBlock = { animationFinished in
                if let onFinish = view.onAnimationFinish {
                    onFinish(["isCancelled": animationFinished])
                }
            }

            if (startFrame.intValue != -1 && endFrame.intValue != -1) {
                view.play(fromFrame: AnimationFrameTime(truncating: startFrame), toFrame: AnimationFrameTime(truncating: endFrame), onStart: onStart, completion: callback)
            } else {
                view.play(onStart: onStart, completion: callback)
            }
        }      
    }
    
    @objc(reset:)
    public func reset(_ reactTag: NSNumber) {
        self.bridge.uiManager.addUIBlock { uiManager, viewRegistry in
            guard let view = viewRegistry?[reactTag] as? ContainerView else {
                if (RCT_DEV == 1) {
                    print("Invalid view returned from registry, expecting ContainerView")
                }
                return
            }

            view.reset()
        }
    }
    
    override static func requiresMainQueueSetup() -> Bool {
        return true
    }
    
}
