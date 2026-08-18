//
//  Utils.swift
//  Wallie
//
//  Created by Vitor Silva Souza on 18/08/26.
//

import SwiftUI

struct PhotoHeroEffectConfig<Element: PhotoProtocol>{
    var selectedItem: Element?
    var sourceLocation: CGRect = .zero
    var sourceScrollPosition: ScrollPosition = .init()
    var showFullScreenCover: Bool = false
}

extension View {
    func withoutAnimation(_ result: @escaping () -> ()) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) { result() }
    }
}

struct PanGesture: UIGestureRecognizerRepresentable {
    var handle: (UIPanGestureRecognizer) -> ()
    
    func makeUIGestureRecognizer(context: Context) -> UIPanGestureRecognizer {
        let gesture = UIPanGestureRecognizer()
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = context.coordinator
        return gesture
    }
    
    func updateUIGestureRecognizer(_ recognizer: UIPanGestureRecognizer, context: Context) {}
    
    func handleUIGestureRecognizerAction(_ recognizer: UIPanGestureRecognizer, context: Context) {
        handle(recognizer)
    }
    
    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            if let scrollView = otherGestureRecognizer.view as? UIScrollView {
                return scrollView.contentOffset.y == 0
            }
            return false
        }
        
        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard let panGesture = gestureRecognizer as? UIPanGestureRecognizer else { return false }
            let velocity = panGesture.velocity(in: panGesture.view)
            return velocity.y > abs(velocity.x)
        }
    }
}
