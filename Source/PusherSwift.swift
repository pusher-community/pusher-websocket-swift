//
//  PusherSwift.swift
//
//  Created by Hamilton Chapman on 19/02/2015.
//
//

import Foundation

let PROTOCOL = 7
let VERSION = "2.0.1"
let CLIENT_NAME = "pusher-websocket-swift"

public class Pusher {
    public let connection: PusherConnection
    private let key: String

#if os(iOS)
    /**
        Initializes the Pusher client with an app key and any appropriate options.

        - parameter key:     The Pusher app key
        - parameter options: An optional collection of options

        - returns: A new Pusher client instance
    */
    public init(key: String, options: PusherClientOptions = PusherClientOptions(), nativePusher: NativePusher = NativePusher.sharedInstance) {
        self.key = key
        let urlString = constructUrl(key, options: options)
        let ws = WebSocket(url: NSURL(string: urlString)!)
        connection = PusherConnection(key: key, socket: ws, url: urlString, options: options)
        connection.createGlobalChannel()
        nativePusher.setPusherAppKey(key)
    }
#endif

#if os(OSX) || os(tvOS)
    /**
     Initializes the Pusher client with an app key and any appropriate options.

     - parameter key:     The Pusher app key
     - parameter options: An optional collection of options

     - returns: A new Pusher client instance
     */
    public init(key: String, options: PusherClientOptions = PusherClientOptions()) {
        self.key = key
        let urlString = constructUrl(key, options: options)
        let ws = WebSocket(url: NSURL(string: urlString)!)
        connection = PusherConnection(key: key, socket: ws, url: urlString, options: options)
        connection.createGlobalChannel()
    }
#endif

    /**
        Subscribes the client to a new channel

        - parameter channelName:     The name of the channel to subscribe to
        - parameter onMemberAdded:   A function that will be called with information about the
                                     member who has just joined the presence channel
        - parameter onMemberRemoved: A function that will be called with information about the
                                     member who has just left the presence channel

        - returns: A new PusherChannel instance
     */
    public func subscribe(
        channelName: String,
        onMemberAdded: ((PresenceChannelMember) -> ())? = nil,
        onMemberRemoved: ((PresenceChannelMember) -> ())? = nil) -> PusherChannel {
            return self.connection.subscribe(channelName, onMemberAdded: onMemberAdded, onMemberRemoved: onMemberRemoved)
    }

    /**
        Unsubscribes the client from a given channel

        - parameter channelName: The name of the channel to unsubscribe from
    */
    public func unsubscribe(channelName: String) {
        self.connection.unsubscribe(channelName)
    }

    /**
        Binds the client's global channel to all events

        - parameter callback: The function to call when a new event is received

        - returns: A unique string that can be used to unbind the callback from the client
    */
    public func bind(callback: (AnyObject?) -> Void) -> String {
        return self.connection.addCallbackToGlobalChannel(callback)
    }

    /**
        Unbinds the client from its global channel

        - parameter callbackId: The unique callbackId string used to identify which callback to unbind
    */
    public func unbind(callbackId: String) {
        self.connection.removeCallbackFromGlobalChannel(callbackId)
    }

    /**
        Unbinds the client from all global callbacks
    */
    public func unbindAll() {
        self.connection.removeAllCallbacksFromGlobalChannel()
    }

    /**
        Disconnects the client's connection
    */
    public func disconnect() {
        self.connection.disconnect()
    }

    /**
        Initiates a connection attempt using the client's existing connection details
    */
    public func connect() {
        self.connection.connect()
    }

#if os(iOS)
    /**
        Returns the NativePusher singletion
     
        - returns: The NativePusher singleton
    */
    public func nativePusher() -> NativePusher {
        return NativePusher.sharedInstance
    }
#endif
}

/**
    Creates a valid URL that can be used in a connection attempt

    - parameter key:     The app key to be inserted into the URL
    - parameter options: The collection of options needed to correctly construct the URL

    - returns: The constructed URL ready to use in a connection attempt
*/
func constructUrl(key: String, options: PusherClientOptions) -> String {
    var url = ""

    if options.encrypted {
        url = "wss://\(options.host):\(options.port)/app/\(key)"
    } else {
        url = "ws://\(options.host):\(options.port)/app/\(key)"
    }
    return "\(url)?client=\(CLIENT_NAME)&version=\(VERSION)&protocol=\(PROTOCOL)"
}
