import XCTest
@testable import EspeakNG

final class EspeakNGTests: XCTestCase {

    func testInitialization() throws {
        // Test that synthesizer can be initialized
        let synthesizer = try EspeakSynthesizer()
        XCTAssertNotNil(synthesizer, "Synthesizer should initialize successfully")
    }

    func testConfigurationUpdate() throws {
        let synthesizer = try EspeakSynthesizer()

        var config = EspeakSynthesizer.Configuration()
        config.pitch = 75
        config.speed = 200

        XCTAssertNoThrow(try synthesizer.updateConfiguration(config))
    }

    func testAvailableVoices() {
        // Note: This test requires espeak-ng to be built and data files to be available
        let voices = EspeakSynthesizer.availableVoices()
        XCTAssertGreaterThan(voices.count, 0, "Should have at least one voice available")
    }

    func testBasicSynthesis() throws {
        // Note: This test requires espeak-ng to be built and data files to be available
        let synthesizer = try EspeakSynthesizer()

        // This should not throw, but actual audio playback depends on environment
        XCTAssertNoThrow(try synthesizer.speak("Hello, world!", language: "en"))
    }

    func testMultipleLanguages() throws {
        let synthesizer = try EspeakSynthesizer()

        // Test English
        XCTAssertNoThrow(try synthesizer.speak("Hello", language: "en"))

        // Test Spanish
        XCTAssertNoThrow(try synthesizer.speak("Hola", language: "es"))

        // Test French
        XCTAssertNoThrow(try synthesizer.speak("Bonjour", language: "fr"))
    }

    func testInvalidLanguage() throws {
        let synthesizer = try EspeakSynthesizer()

        // Invalid language code should throw
        XCTAssertThrowsError(try synthesizer.speak("Test", language: "invalid_lang"))
    }

    func testConfigurationBoundaries() throws {
        let synthesizer = try EspeakSynthesizer()

        // Test minimum values
        var minConfig = EspeakSynthesizer.Configuration()
        minConfig.pitch = 0
        minConfig.speed = 80
        minConfig.volume = 0
        XCTAssertNoThrow(try synthesizer.updateConfiguration(minConfig))

        // Test maximum values
        var maxConfig = EspeakSynthesizer.Configuration()
        maxConfig.pitch = 99
        maxConfig.speed = 450
        maxConfig.volume = 200
        XCTAssertNoThrow(try synthesizer.updateConfiguration(maxConfig))
    }
}
