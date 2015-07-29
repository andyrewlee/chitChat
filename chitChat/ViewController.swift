//
//  ViewController.swift
//  chitChat
//
//  Created by Jae Hoon Lee on 7/16/15.
//  Copyright © 2015 Jae Hoon Lee. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate {
    
    let serviceType = "LCOC-Chat"
    
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var session: MCSession!
    var peerID: MCPeerID!
    
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var messageTextField: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        self.browser = MCBrowserViewController(serviceType: serviceType, session: self.session)
        self.browser.delegate = self
        
        self.assistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: self.session)
        
        self.assistant.start()
    }

    @IBAction func sendChat(sender: UIButton) {
        let msg = self.messageTextField.text?.dataUsingEncoding(NSUTF8StringEncoding,
            allowLossyConversion: false)
        
        do {
            try self.session.sendData(msg!, toPeers: self.session.connectedPeers,
                withMode: MCSessionSendDataMode.Unreliable)
        } catch {
            print("error")
        }
        
        self.updateChat(self.messageTextField.text!, fromPeer: self.peerID)
        
        self.messageTextField.text = ""
    }
    
    func updateChat(text : String, fromPeer peerID: MCPeerID) {
        // Appends some text to the chat view
        
        // If this peer ID is the local device's peer ID, then show the name
        // as "Me"
        var name : String
        
        switch peerID {
        case self.peerID:
            name = "Me"
        default:
            name = peerID.displayName
        }
        
        let message = "\(name): \(text)\n"
        self.chatTextView.text = self.chatTextView.text + message
    }
    
    @IBAction func showBrowser(sender: UIButton) {
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    // MARK: MCBrowserViewControllerDelegate
    
    func browserViewControllerDidFinish(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is dismissed (ie the Done
            // button was tapped)
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(
        browserViewController: MCBrowserViewController)  {
            // Called when the browser view controller is cancelled
            
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: MCSessionDelegate
    
    func session(session: MCSession, didReceiveData data: NSData,
        fromPeer peerID: MCPeerID)  {
            // Called when a peer sends NSData to us
            
            dispatch_async(dispatch_get_main_queue()) {
                let msg = String(data: data, encoding: NSUTF8StringEncoding)
                self.updateChat(msg, fromPeer: peerID)
            }
    }
    
    // Remote peer changed state.
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
    
    // Received a byte stream from remote peer.
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    // Start receiving a resource from remote peer.
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError) {
    }

}

