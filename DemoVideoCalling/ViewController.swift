//
//  ViewController.swift
//  DemoVideoCalling
//
//  Created by Abdullah Ansari on 25/07/24.
//

import UIKit
import AgoraUIKit
import AgoraRtcKit
import AVFoundation

class VideoCallViewController: UIViewController {
    
    var agoraEngine: AgoraRtcEngineKit!
    var localVideoView: UIView!
    var remoteVideoView: UIView!
    
    var backgroundPlayer: AVPlayer!
    var backgroundLayer: AVPlayerLayer!
    var videoOutput: AVPlayerItemVideoOutput!
    var displayLink: CADisplayLink!
    let viewWidth: CGFloat = 150
    let viewHeight: CGFloat = 150
    let padding: CGFloat = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAgoraEngine()
        view.backgroundColor = .red
        setupCustomBackground()
    }
    
    func setupUI() {
        // Set up the local video view
        localVideoView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 150))
        // Set up the local video view
        localVideoView = UIView(frame: CGRect(x: padding,
                                                  y: self.view.bounds.height - viewHeight - 50,
                                                  width: viewWidth,
                                                  height: viewHeight))
        localVideoView.layer.cornerRadius = 10
        localVideoView.layer.masksToBounds = true
        localVideoView.backgroundColor = .black
        self.view.addSubview(localVideoView)
        
        // Set up the remote video view
        remoteVideoView = UIView(frame: self.view.bounds)
        remoteVideoView.backgroundColor = .lightGray
        self.view.addSubview(remoteVideoView)
        self.view.bringSubviewToFront(localVideoView)
        self.remoteVideoView.backgroundColor = .yellow
    }
    
    func setupAgoraEngine() {
          agoraEngine = AgoraRtcEngineKit.sharedEngine(withAppId: "0068f7b181b34b0c9fffd81eaebeb1d3", delegate: self)
          agoraEngine.enableVideo()
          let videoCanvas = AgoraRtcVideoCanvas()
          videoCanvas.uid = 0
          videoCanvas.view = localVideoView
          videoCanvas.renderMode = .hidden
          agoraEngine.setupLocalVideo(videoCanvas)
          agoraEngine.startPreview()
        
        // Join a channel
        let channelName = "testChannel"
        agoraEngine.joinChannel(byToken: nil, channelId: channelName, info: nil, uid: 0) { [weak self] (channel, uid, elapsed) in
            print("Joined channel: \(channel)")
        }
        
        
        func setupUI() {
            // Initialize and set up local and remote video views
        }

        func setupCustomBackground() {
            // Initialize background video setup
        }
        
      }
    
    func setupCustomBackground() {
        guard let videoURL = Bundle.main.url(forResource: "video", withExtension: "mp4") else {
            print("Video file not found")
            return
        }
        
        backgroundPlayer = AVPlayer(url: videoURL)
        backgroundLayer = AVPlayerLayer(player: backgroundPlayer)
        backgroundLayer.frame = remoteVideoView.bounds
        remoteVideoView.layer.insertSublayer(backgroundLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: backgroundPlayer.currentItem)
        
        // Observe buffering status
        backgroundPlayer.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
        
        backgroundPlayer.play()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if backgroundPlayer.timeControlStatus == .waitingToPlayAtSpecifiedRate {
                // Buffering: Show a loading indicator
                print("Buffering...")
            } else if backgroundPlayer.timeControlStatus == .playing {
                // Playing: Hide the loading indicator
                print("Playing")
            }
        }
    }

    @objc func playerDidFinishPlaying(notification: Notification) {
        backgroundPlayer.seek(to: .zero)
        backgroundPlayer.play()
    }


}

extension VideoCallViewController: AgoraRtcEngineDelegate {
  
}
