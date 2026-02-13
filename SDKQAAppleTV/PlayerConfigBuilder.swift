//
//  PlayerConfigBuilder.swift
//  SDKQAAppleTV
//
//  Builds MediastreamPlayerConfig for each test case using the same IDs as SDKQAiOS/Android.
//

import UIKit
import MediastreamPlatformSDKAppleTV

enum PlayerConfigBuilder {

    // MARK: - Audio IDs (same as SDKQAiOS)
    private static let audioAodId = "67ae0ec86dcc4a0dca2e9b00"
    private static let audioEpisodeId = "6193f836de7392082f8377dc"
    private static let audioLiveId = "5c915724519bce27671c4d15"
    private static let audioLiveDvrId = "632c9b23d1dcd7027f32f7fe"

    // MARK: - Video IDs (same as SDKQAiOS)
    private static let videoVodId = "685be889d76b0da57e68620e"
    private static let videoEpisodeId = "6985311bd04b84ebf6400f24"
    private static let videoLiveId = "6824d425c3ae719205f54245"
    private static let videoNextEpisodeId = "6839b2d6a4149963bfe295e0"
    private static let videoNextEpisodeCustomId = "68891e8d1856d6378f5d81fa"
    /// Cadena de IDs para Next Episode Custom (mismo que SDKQAiOS VideoNextEpisodeViewController).
    static let nextEpisodeCustomIds = ["6892591911582875cc48b239", "689f6396ef81e4c28ba9644b"]

    static func config(for testCase: TestCase, bundle: Bundle = .main) -> MediastreamPlayerConfig? {
        let config = MediastreamPlayerConfig()
        config.showControls = true
        config.debug = true
        config.customUI = false
        config.autoplay = true

        switch testCase.type {
        case .audioAodSimple:
            config.id = audioAodId
            config.type = .VOD
            config.videoFormat = .MP3

        case .audioEpisode:
            config.id = audioEpisodeId
            config.type = .EPISODE
            config.videoFormat = .MP3
            config.loadNextAutomatically = true

        case .audioLocal:
            guard let url = bundle.url(forResource: "sample_audio", withExtension: "mp3") else { return nil }
            config.src = url as NSURL
            config.id = "local-audio"
            config.type = .VOD

        case .audioLive:
            config.id = audioLiveId
            config.type = .LIVE

        case .audioLiveDvr:
            config.id = audioLiveDvrId
            config.type = .LIVE
            config.dvr = true
            // Default: DVR with platform window (no start/end)

        case .audioMixed:
            // Default to AOD Simple when no mode selector
            config.id = audioAodId
            config.type = .VOD
            config.videoFormat = .MP3

        case .videoVodSimple:
            config.id = videoVodId
            config.type = .VOD

        case .videoSmallContainer:
            config.id = videoVodId
            config.type = .VOD

        case .videoNextEpisodeDefault:
            config.id = videoNextEpisodeId
            config.type = .EPISODE
            config.loadNextAutomatically = true
            config.environment = MediastreamPlayerConfig.Environments.DEV

        case .videoNextEpisodeCustom:
            config.id = videoNextEpisodeCustomId
            config.type = .VOD
            config.environment = MediastreamPlayerConfig.Environments.PRODUCTION
            config.nextEpisodeId = nextEpisodeCustomIds.first

        case .videoLocal:
            guard let url = bundle.url(forResource: "sample_video", withExtension: "mp4") else { return nil }
            config.src = url as NSURL
            config.id = "local-video"
            config.type = .VOD

        case .videoEpisode:
            config.id = videoEpisodeId
            config.type = .EPISODE
            config.loadNextAutomatically = true

        case .videoLive:
            config.id = videoLiveId
            config.type = .LIVE

        case .videoLiveDvr:
            config.id = videoLiveId
            config.type = .LIVE
            config.dvr = true

        case .videoMixed:
            config.id = videoVodId
            config.type = .VOD

        case .videoUILocalization:
            config.id = videoVodId
            config.type = .VOD
        }

        return config
    }

    /// Returns a short message when config cannot be built (e.g. missing local file).
    static func missingResourceMessage(for testCase: TestCase) -> String? {
        switch testCase.type {
        case .audioLocal:
            return "Add sample_audio.mp3 to the target\n(Copy Bundle Resources)"
        case .videoLocal:
            return "Add sample_video.mp4 to the target\n(Copy Bundle Resources)"
        default:
            return nil
        }
    }
}
