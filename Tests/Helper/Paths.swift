//
//  Assets.swift
//  NexmoConversation
//
//  Created by shams ahmed on 29/09/2016.
//  Copyright © 2016 Nexmo. All rights reserved.
//

import Foundation

/// List of all assets for testing
internal enum AssetsTest: String {
    
    case nexmo = "nexmo_logo"
    case corruptedData = "corruptedData"

    /// Get path of asset
    ///
    /// - returns: path
    var path: String {
        switch self {
        case .nexmo: return self.rawValue+".jpeg"
        case .corruptedData: return self.rawValue+".jpg"
        }
    }
}

/// List of all mock JSON responses
///
/// - uploadedImage: upload image response
/// - uploadedImageOther: upload image response 2
/// - sendImageMessage: response of event id for a image message
/// - uploadPushCertificate: push notification result
/// - uploadPushCertificates: push notifications result
/// - addDeviceToken: response of adding a new device token
/// - joinConversation: join conversation reponse
/// - demo1: user model
/// - demo2: another user model
/// - deleteEvent: response of delete event
/// - invitedMemberToAConversation: invite response of a suer joining a conversation
/// - events: list of events from a conversation
/// - memberJoinedEvent: event for member join action
/// - textEvent: event for text
/// - conversations: list of lite conversations
/// - liteConversation: small conversation response
/// - fullConversation: full conversation response
/// - invitedMemberToAConversation: invite user to a conversation response
/// - typingOffEvent: event sent to CAPI when users starts typing
/// - detailedMemberModel: detailed member model
/// - member: member model
/// - sessionSuccess: session success socket message
/// - fetchEventNotJoined: user not joined to conversation
/// - conversationNotFound: detailed conversation not found
/// - memberAlreadyJoinedError: trying to join an conversation while the member has already joined
/// - memberInvitedViaSocket: member invite with member details from the socket
/// - fullConversationMultipleInviteBy: full conversation with a multiple invite_by member
/// - fullConversationSingleInviteBy: full conversation with invite_by member
/// - memberWithMultipleTimestamps: Member object with multiple states for dates
/// - memberLeftViaSocket: member left with member details from the socket
/// - uploadedImageEvent: uploaded image event
/// - allWithoutUserId: all conversation with pagination
/// - allWithoutUserId1: all conversation with pagination
/// - allWithoutUserId2: all conversation with pagination
/// - allWithoutUserId3: all conversation with pagination
/// - allWithoutUserId4: all conversation with pagination
/// - allWithoutUserId5: all conversation with pagination
/// - allWithoutUserId6: all conversation with pagination
/// - allWithoutUserId7: all conversation with pagination
/// - allWithoutUserId8: all conversation with pagination
/// - allWithoutUserId9: all conversation with pagination
/// - allWithoutUserId10: all conversation with pagination
/// - allWithoutUserIdReturnsEmpty: all conversation returns zero
/// - rtcNewt: rtc new
/// - rtcAnswerFromSocket: rtc answer
/// - muteAndUnmute: mute and unmute
/// - audioEnabled: audio enabled from member:media
internal enum JSONTest: String {
    case uploadedImage = "UploadedImage"
    case uploadedImageOther = "UploadedImageOther"
    case sendImageMessage = "SendImageMessage"
    case uploadPushCertificate = "Upload_Push_Certificate"
    case uploadPushCertificates = "Upload_Push_Certificates"
    case addDeviceToken
    case joinConversation
    case demo1
    case demo2
    case events
    case deleteEvent
    case invitedMemberToAConversation = "invitedMemberToAConversation2"
    case memberJoinedEvent = "event_member_joined"
    case textEvent = "event_text"
    case conversations
    case liteConversation
    case fullConversation
    case inviteUser = "invitedMemberToAConversation"
    case typingOffEvent
    case detailedMemberModel
    case member
    case sessionSuccess
    case errorNotFound
    case fetchEventNotJoined
    case conversationNotFound
    case memberAlreadyJoinedError
    case memberInvitedViaSocket
    case fullConversationMultipleInviteBy
    case fullConversationSingleInviteBy
    case memberWithMultipleTimestamps
    case memberLeftViaSocket
    case uploadedImageEvent
    case allWithoutUserId
    case allWithoutUserId1
    case allWithoutUserId2
    case allWithoutUserId3
    case allWithoutUserId4
    case allWithoutUserId5
    case allWithoutUserId6
    case allWithoutUserId7
    case allWithoutUserId8
    case allWithoutUserId9
    case allWithoutUserId10
    case rtcNew
    case rtcAnswerFromSocket
    case muteAndUnmute
    case audioEnabled
    case eventState
}
