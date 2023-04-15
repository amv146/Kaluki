//
//  MultipeerNetwork.swift
//  Kaluki
//
//  Created by Alex Vallone on 3/23/23.
//

import MultipeerConnectivity

class MultipeerNetwork: NSObject
{
    // MARK: Lifecycle

    deinit
    {
        print("Stopping Network")
        MultipeerNetwork.stopNetwork()
    }

    // MARK: Internal

    static var advertiser: MCNearbyServiceAdvertiser?
    static var browser: MCNearbyServiceBrowser?
    static var session: MCSession?
    static var gameID: UUID?

    static func send(data: Data, to peer: MCPeerID)
    {
        // Attempt system that tries to send data 5 times before giving up

        guard let session
        else
        {
            return
        }

        var attempts = 0
        var successfullySent = false

        let attemptSend = {
            guard session.connectedPeers.contains(peer)
            else
            {
                attempts += 1
                return
            }

            do
            {
                try session.send(data, toPeers: [peer], with: .reliable)
                successfullySent = true
            }
            catch
            {
                attempts += 1
            }
        }

        while !successfullySent, attempts < 5
        {
            attemptSend()
        }
    }

    static func stopNetwork()
    {
        MultipeerNetwork.session?.disconnect()
        MultipeerNetwork.advertiser?.stopAdvertisingPeer()
        MultipeerNetwork.browser?.stopBrowsingForPeers()
    }
}

extension MultipeerNetwork: MCNearbyServiceAdvertiserDelegate
{
    func advertiser(_: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        print("Error: \(error)")
    }

    func advertiser(_: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer _: MCPeerID, withContext _: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        invitationHandler(true, MultipeerNetwork.session)
    }
}

extension MultipeerNetwork: MCNearbyServiceBrowserDelegate
{
    func browser(_: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error)
    {
        print("Error: \(error)")
    }

    func browser(_: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo _: [String: String]?)
    {
        print("Found peer: \(peerID)")
    }

    func browser(_: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        print("Lost peer: \(peerID)")
    }
}
