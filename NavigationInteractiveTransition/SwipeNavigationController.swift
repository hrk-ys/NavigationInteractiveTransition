//
//  SwipeNavigationController.swift
//  NavigationInteractiveTransition
//
//  Created by Hiroki Yoshifuji on 2015/01/17.
//  Copyright (c) 2015年 Hiroki Yoshifuji. All rights reserved.
//

import UIKit

class SwipeNavigationController : UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate
{
    
    // スワイプで遷移する先のコントローラ
    var nextViewController:UIViewController?
    private var interactiveTransition:UIPercentDrivenInteractiveTransition?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
    }
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        
        var gesture = UIPanGestureRecognizer(target: self, action: "panGesture:")
        gesture.delegate = self
        viewController.view.addGestureRecognizer(gesture)
    }
   
    // 画面遷移するときに使われるアニメーションを返す
    func navigationController(navigationController: UINavigationController,
        animationControllerForOperation operation: UINavigationControllerOperation,
        fromViewController fromVC: UIViewController,
        toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            
            if operation == .Push {
                return PushAnimatedTransitioning()
            }
            return nil
    }
    
    // UIPercentDrivenInteractiveTransitionを返す
    func navigationController(navigationController: UINavigationController, interactionControllerForAnimationController animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return self.interactiveTransition
    }
    
    
    
    // 横スワイプのみ対応
    func gestureRecognizerShouldBegin(gestureRecognizer: UIPanGestureRecognizer) -> Bool {
        var location = gestureRecognizer.translationInView(gestureRecognizer.view!)
        if self.nextViewController == nil { return false }
        return fabs(location.x) > fabs(location.y)
    }
    
    func panGesture(recognizer: UIPanGestureRecognizer) {
        var location = recognizer.translationInView(recognizer.view!)
        
        // どれくらい遷移したかを 0 〜 1で数値化
        var progress = fabs(location.x / (self.view.bounds.size.width * 1.0));
        progress = min(1.0, max(0.0, progress));
        
        // 次の画面が設定してなければ処理は継続しない
        if (self.nextViewController == nil) { return }
        
        if (recognizer.state == .Began) {
            // 左へのスワイプのみ
            if location.x > 0 { return }
            
            self.interactiveTransition = UIPercentDrivenInteractiveTransition()
            
            // ページ遷移させる!!!!!!
            self.pushViewController(self.nextViewController!, animated: true)
        }
        else if (recognizer.state == .Changed) {
            
            // 変化量を通知させる
            self.interactiveTransition?.updateInteractiveTransition(progress)
        }
        else if (recognizer.state == .Ended || recognizer.state == .Cancelled) {
            
            // 終了かキャンセルか
            if self.interactiveTransition != nil {
                if (progress > 0.5) {
                    self.interactiveTransition?.finishInteractiveTransition()
                    self.nextViewController = nil
                }
                else {
                    self.interactiveTransition?.cancelInteractiveTransition()
                }
            }
            
            self.interactiveTransition = nil;
        }
    }
}



class PushAnimatedTransitioning : NSObject, UIViewControllerAnimatedTransitioning {
   
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // 遷移元のVC
        var fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        // 遷移先のVC
        var toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        
        // 表示中のView
        var containerView = transitionContext.containerView()
        
        
        var duration:NSTimeInterval = self.transitionDuration(transitionContext)
        
        
        
        // アニメーション終了時のframeを取得
        toViewController.view.frame = transitionContext.finalFrameForViewController(toViewController)
        
        // 右端から出すため初期値は幅分をプラスする
        toViewController.view.center.x += containerView.bounds.width
            
        containerView.addSubview(toViewController.view)

        
        UIView.animateWithDuration(duration,
            animations: { () -> Void in
                // 先ほどプラスした幅分を戻す
                toViewController.view.center.x -= containerView.bounds.width
                
            }, completion: { (Bool) -> Void in
                
                // キャンセルされていなければ完了
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled());
        })
        
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
}
