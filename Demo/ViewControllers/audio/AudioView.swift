//
//  AudioView.swift
//  NexmoConversation
//
//  Created by Shams Ahmed on 10/10/2017.
//  Copyright © 2017 Nexmo. All rights reserved.
//

import UIKit

internal class AudioView: UIView {

    @IBOutlet internal weak var title: UILabel!
    @IBOutlet internal weak var state: UILabel!

    @IBOutlet internal weak var mute: UIButton!
    @IBOutlet internal weak var hold: UIButton!
    @IBOutlet internal weak var loudspeaker: UIButton!
    @IBOutlet internal weak var earmuff: UIButton!
    @IBOutlet internal weak var disable: UIButton!
}
