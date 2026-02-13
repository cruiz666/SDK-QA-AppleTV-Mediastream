//
//  CaseDetailViewController.swift
//  SDKQAAppleTV
//
//  Case detail: embeds MediastreamPlatformSDK with config built from test case (same IDs as iOS).
//

import AVKit
import UIKit
import MediastreamPlatformSDKAppleTV

class CaseDetailViewController: UIViewController {

    let testCase: TestCase
    private var player: MediastreamPlatformSDK?

    /// For Small Container only: player sits in this view.
    private let playerContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .black
        return v
    }()

    /// For Small Container: placeholder below the player (like iOS “dummy content”).
    private let contentAreaLabel: UILabel = {
        let l = UILabel()
        l.text = "Content area\n\nPlayer is in the section above. On tvOS you can show a smaller player with browse content below, similar to iOS Small Container."
        l.font = .systemFont(ofSize: 36, weight: .regular)
        l.textColor = .lightGray
        l.textAlignment = .center
        l.numberOfLines = 0
        return l
    }()

    private var isSmallContainer: Bool { testCase.type == .videoSmallContainer }

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 38, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(testCase: TestCase) {
        self.testCase = testCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = testCase.title
        view.backgroundColor = .black

        guard let config = PlayerConfigBuilder.config(for: testCase) else {
            messageLabel.text = PlayerConfigBuilder.missingResourceMessage(for: testCase)
                ?? "Unable to build config for \(testCase.type.rawValue)"
            view.addSubview(messageLabel)
            NSLayoutConstraint.activate([
                messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                messageLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
                messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -80)
            ])
            print("[SDK-QA] Entered here: \(testCase.displayTitle) — config unavailable")
            return
        }

        let mdstrm = MediastreamPlatformSDK()
        addChild(mdstrm)

        if isSmallContainer {
            view.addSubview(playerContainerView)
            view.addSubview(contentAreaLabel)
            playerContainerView.addSubview(mdstrm.view)
        } else {
            view.addSubview(mdstrm.view)
        }

        mdstrm.didMove(toParent: self)
        player = mdstrm

        mdstrm.setup(config)
        mdstrm.play()
        mdstrm.events.listenTo(eventName: "ready", action: { [weak self] _ in
            self?.triggerPlayerControlsAppearance()
            self?.requestFocusOnPlayer()
        })
        if testCase.type == .videoNextEpisodeCustom {
            setupNextEpisodeCustomListener()
        }
        print("[SDK-QA] Entered here: \(testCase.displayTitle) (\(testCase.type.rawValue))")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestFocusOnPlayer()
        triggerPlayerControlsAppearance()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.triggerPlayerControlsAppearance()
            self?.requestFocusOnPlayer()
        }
    }

    /// On tvOS, embedded AVPlayerViewController often needs explicit appearance transition for controls to show.
    private func triggerPlayerControlsAppearance() {
        guard let sdk = player else { return }
        sdk.beginAppearanceTransition(true, animated: false)
        sdk.endAppearanceTransition()
        if let avpvc = sdk.playerViewController {
            avpvc.beginAppearanceTransition(true, animated: false)
            avpvc.endAppearanceTransition()
            avpvc.showsPlaybackControls = true
        }
    }

    /// Ask focus system to move focus to the player so native controls can appear.
    private func requestFocusOnPlayer() {
        setNeedsFocusUpdate()
        updateFocusIfNeeded()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.setNeedsFocusUpdate()
            self?.updateFocusIfNeeded()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let playerView = player?.view else { return }
        let h = view.bounds.height
        let w = view.bounds.width

        if isSmallContainer {
            let topPadding: CGFloat = 40
            let playerHeight = h * 0.52
            playerContainerView.frame = CGRect(x: 0, y: topPadding, width: w, height: playerHeight)
            playerView.frame = playerContainerView.bounds
            contentAreaLabel.frame = CGRect(x: 60, y: topPadding + playerHeight + 40, width: w - 120, height: max(0, h - (topPadding + playerHeight + 80)))
        } else {
            playerView.frame = view.bounds
        }
    }

    override var preferredFocusEnvironments: [UIFocusEnvironment] {
        if let playerView = player?.view {
            return [playerView]
        }
        return super.preferredFocusEnvironments
    }

    /// Next Episode Custom: on nextEpisodeIncoming, call updateNextEpisode with next ID in chain (same as SDKQAiOS).
    private func setupNextEpisodeCustomListener() {
        player?.events.removeListeners(eventNameToRemoveOrNil: "nextEpisodeIncoming")
        let ids = PlayerConfigBuilder.nextEpisodeCustomIds
        player?.events.listenTo(eventName: "nextEpisodeIncoming", action: { [weak self] information in
            guard let self = self,
                  let info = information as? [String: Any],
                  let nextId = info["nextEpisodeId"] as? String,
                  let indexInList = ids.firstIndex(of: nextId) else { return }
            let nextIndex = indexInList + 1
            let nextConfig = MediastreamPlayerConfig()
            nextConfig.id = nextId
            nextConfig.type = .VOD
            nextConfig.environment = MediastreamPlayerConfig.Environments.PRODUCTION
            nextConfig.debug = true
            if nextIndex < ids.count {
                nextConfig.nextEpisodeId = ids[nextIndex]
            }
            self.player?.updateNextEpisode(nextConfig)
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.releasePlayer()
    }

    deinit {
        player?.releasePlayer()
    }
}
