//
//  Reactive+Custom.swift
//  Core
//
//  Created by Atilla Özder on 4.08.2019.
//  Copyright © 2019 Atilla Özder. All rights reserved.
//

import struct Foundation.Notification
import class Foundation.NotificationCenter
import RxSwift
import RxCocoa

extension Reactive where Base: UIButton {
    var isValid: Binder<Bool> {
        return Binder(self.base) { button, valid in
            button.isEnabled = valid
            button.alpha = valid ? 1.0 : 0.5
        }
    }
}

extension Reactive where Base: NotificationCenter {
    func payload(name: Notification.Name) -> Observable<[AnyHashable: Any]> {
        return notification(name)
            .flatMap { (not) -> Observable<[AnyHashable: Any]> in
                guard let payload = not.userInfo else { return .empty() }
                return .just(payload)
        }
    }
}

extension UIScrollView {
    var rx_nextPageTrigger: Observable<Void> {
        return self.rx.contentOffset
            .observeOn(MainScheduler.asyncInstance)
            .flatMapLatest({ [weak self] (offset) -> Observable<Void> in
                guard let `self` = self else { return .empty() }
                let threshold = offset.y + self.frame.height + 200
                let newPage = threshold > self.contentSize.height
                return newPage ? .just(()) : .empty()
            })
    }
}
