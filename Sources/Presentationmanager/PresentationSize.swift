//
//  PresentationSize.swift
//  PresentationManager
//
//  Created by sai on 05/04/2017.
//

import Foundation
import UIKit

public protocol PresentationSizeProtocol {
    func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize
}

public struct PresentationSize {
    public var widthRatio: CGFloat? {
        didSet {
            if let ratio = self.widthRatio, 0...1 ~= ratio {
                self.widthRatio = oldValue
            }
        }
    }
    public var heightRatio: CGFloat? {
        didSet {
            if let ratio = self.heightRatio, 0...1 ~= ratio {
                self.heightRatio = oldValue
            }
        }
    }
    
    public init(widthRatio: CGFloat? = nil, heightRatio: CGFloat? = nil) {
        self.widthRatio = widthRatio.flatMap { 0...1 ~= $0 ? $0 : nil }
        self.heightRatio = heightRatio.flatMap { 0...1 ~= $0 ? $0 : nil }
    }
}

extension PresentationSize: PresentationSizeProtocol {
    public func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        let width: CGFloat
        if let ratio = self.widthRatio {
            width = parentSize.width * ratio
        } else if container.preferredContentSize.width > 0 {
            width = min(container.preferredContentSize.width, parentSize.width)
        } else {
            width = parentSize.width
        }
        
        let height: CGFloat
        if let ratio = self.heightRatio {
            height = parentSize.height * ratio
        } else if container.preferredContentSize.height > 0 {
            height = min(container.preferredContentSize.height, parentSize.height)
        } else {
            height = parentSize.height
        }
        
        return CGSize(width: width, height: height)
    }
}
