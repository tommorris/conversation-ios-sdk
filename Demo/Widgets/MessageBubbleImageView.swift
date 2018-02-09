//
//  MessageBubbleImageView.swift
//  NexmoChat
//
//  Created by James Green on 27/05/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import UIKit
import NexmoConversation

public class MessageBubbleImageView: MessageBubbleView {
    
    lazy var mainImageView: UIImageView = {
        let imageView =  UIImageView()
        
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        self.payloadContainer.addSubview(imageView)
        
        self.payloadContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[imageView]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["imageView": imageView]))
        self.payloadContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[imageView]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["imageView": imageView]))
        
        return imageView
    }()
    
    // MARK:
    // MARK: Initializers
    
    /**
     Constructor.
     
     - parameter message: The message.
     
     - returns: A new instance.
     */
    required public init(message: ImageEvent, onLeft: Bool, parentWidth: CGFloat, avatarEnabled: Bool, name: String?) {
        super.init(onLeft: onLeft, message: message, parentWidth: parentWidth, avatarEnabled: avatarEnabled, name: name)
        
        setup(with: message)
    }
    
    /**
     Returns an object initialized from data in a given unarchiver.
     
     - parameter aDecoder: An unarchiver object.
     
     - returns: self, initialized using the data in decoder.
     */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
    }
    
    // MARK:
    // MARK: Setup
    
    private func setup(with event: ImageEvent) {
        // pre-fetch thumbnail image
        event.image { [weak self] in
            switch $0 {
            case .success(let thumbnail):
                self?.setImage(for: thumbnail)
            case .failed(let error):
                self?.setImage(for: nil)
                
                print("DEMO - Failed to display image: \(error)")
            }
        }
    }
    
    // MARK:
    // MARK: View
    
    private func setImage(for image: UIImage?) {
        mainImageView.image = image
    }
    
    /**
     For the given message (containing an image), what would we like the height of the payload container to be?
     
     - parameter image:     image
     - parameter parentWidth: Width of table (not payload container)
     
     - returns: The height
     */
    public static func payloadHeightFor(image: UIImage, parentWidth: CGFloat) -> CGFloat {
        let width = payloadWidthFor(image: image, availableWidth: parentWidth)
        let height = (image.size.height * width) / image.size.width
        
        return height
    }

    /**
     For the given message (containing an image), what would we like the width of the payload container to be?
     
     - parameter image:        image
     - parameter availableWidth: Current/default width of payload container
     
     - returns: The width we'd like it to be (not exceeding the current width)
     */
    public static func payloadWidthFor(image: UIImage, availableWidth: CGFloat) -> CGFloat {
        return min(availableWidth, 150)
    }
    
    /**
     For the given message (containing an image), refresh the image
     
     - parameter image:        image
     */
    public func refreshImage(imageEvent: ImageEvent) {
        //TODO currently this will add another subview to payload container (and constraints) each time. not good.
        imageEvent.image { [weak self] in
            switch $0 {
            case .success(let thumbnail):
                self?.setImage(for: thumbnail)
            case .failed(let error):
                self?.setImage(for: nil)
                
                print("DEMO - Failed to display image: \(error)")
            }
        }
    }
}
