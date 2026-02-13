//
//  TestCase.swift
//  SDKQAAppleTV
//
//  Test cases for the SDK QA suite on tvOS.
//  Simple examples only: no Cast, Reels, or "with Service".
//

import Foundation

struct TestCase {
    let type: TestCaseType
    let title: String
    let category: Category

    enum Category: String, CaseIterable {
        case audio = "Audio"
        case video = "Video"
        var displayName: String { rawValue }
    }

    enum TestCaseType: String, CaseIterable {
        // Audio (simples)
        case audioAodSimple
        case audioEpisode
        case audioLocal
        case audioLive
        case audioLiveDvr
        case audioMixed
        // Video (simples)
        case videoVodSimple
        case videoSmallContainer
        case videoNextEpisodeDefault
        case videoNextEpisodeCustom
        case videoLocal
        case videoEpisode
        case videoLive
        case videoLiveDvr
        case videoMixed
        case videoUILocalization
    }

    var displayTitle: String {
        "\(category.displayName): \(title)"
    }

    static func cases(for category: Category) -> [TestCase] {
        switch category {
        case .audio:
            return [
                TestCase(type: .audioAodSimple, title: "AOD Simple", category: .audio),
                TestCase(type: .audioEpisode, title: "Episode", category: .audio),
                TestCase(type: .audioLocal, title: "Local Audio", category: .audio),
                TestCase(type: .audioLive, title: "Live Audio", category: .audio),
                TestCase(type: .audioLiveDvr, title: "Live Audio DVR", category: .audio),
                TestCase(type: .audioMixed, title: "Mixed Audio", category: .audio)
            ]
        case .video:
            return [
                TestCase(type: .videoVodSimple, title: "VOD Simple", category: .video),
                TestCase(type: .videoSmallContainer, title: "Small Container", category: .video),
                TestCase(type: .videoNextEpisodeDefault, title: "Next Episode Default", category: .video),
                TestCase(type: .videoNextEpisodeCustom, title: "Next Episode Custom", category: .video),
                TestCase(type: .videoLocal, title: "Local Video", category: .video),
                TestCase(type: .videoEpisode, title: "Episode", category: .video),
                TestCase(type: .videoLive, title: "Live Video", category: .video),
                TestCase(type: .videoLiveDvr, title: "Live Video DVR", category: .video),
                TestCase(type: .videoMixed, title: "Mixed Video", category: .video),
                TestCase(type: .videoUILocalization, title: "UI Localization", category: .video)
            ]
        }
    }
}
