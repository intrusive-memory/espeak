import Foundation
import CEspeakNG

/// Swift wrapper for the eSpeak NG text-to-speech engine
public class EspeakSynthesizer {

    /// Errors that can occur during speech synthesis
    public enum SynthesisError: Error {
        case initializationFailed
        case synthesisFailedWithCode(Int32)
        case notInitialized
        case invalidParameter(String)
    }

    /// Speech output configuration
    public struct Configuration {
        public var pitch: Int = 50      // 0-99
        public var speed: Int = 175     // words per minute
        public var volume: Int = 100    // 0-200
        public var wordGap: Int = 0     // pause between words (10ms units)

        public init(pitch: Int = 50, speed: Int = 175, volume: Int = 100, wordGap: Int = 0) {
            self.pitch = pitch
            self.speed = speed
            self.volume = volume
            self.wordGap = wordGap
        }
    }

    private var isInitialized = false
    private var configuration: Configuration

    /// Initialize the eSpeak synthesizer
    /// - Parameters:
    ///   - configuration: Speech configuration settings
    ///   - dataPath: Optional path to espeak-ng-data directory. If nil, uses bundled resources.
    public init(configuration: Configuration = Configuration(), dataPath: String? = nil) throws {
        self.configuration = configuration

        // Determine data path
        let path = dataPath ?? Self.bundledDataPath()

        // Initialize espeak-ng
        let sampleRate = espeak_Initialize(
            AUDIO_OUTPUT_PLAYBACK,
            0,  // buffer length (0 = default)
            path,
            0   // options
        )

        guard sampleRate > 0 else {
            throw SynthesisError.initializationFailed
        }

        isInitialized = true

        // Apply configuration
        try applyConfiguration()
    }

    deinit {
        if isInitialized {
            espeak_Terminate()
        }
    }

    /// Speak the given text
    /// - Parameters:
    ///   - text: The text to synthesize
    ///   - language: Optional language code (e.g., "en", "es", "fr"). If nil, uses default.
    public func speak(_ text: String, language: String? = nil) throws {
        guard isInitialized else {
            throw SynthesisError.notInitialized
        }

        // Set language if specified
        if let lang = language {
            let result = espeak_SetVoiceByName(lang)
            guard result == EE_OK else {
                throw SynthesisError.synthesisFailedWithCode(result.rawValue)
            }
        }

        // Synthesize speech
        let result = espeak_Synth(
            text,
            text.utf8.count + 1,
            0,  // position
            POS_CHARACTER,
            0,  // end position (0 = no end position)
            UInt32(espeakCHARS_UTF8),
            nil,  // user identifier
            nil   // user data
        )

        guard result == EE_OK else {
            throw SynthesisError.synthesisFailedWithCode(result.rawValue)
        }

        // Wait for speech to complete
        espeak_Synchronize()
    }

    /// Update the speech configuration
    /// - Parameter configuration: New configuration to apply
    public func updateConfiguration(_ configuration: Configuration) throws {
        self.configuration = configuration
        try applyConfiguration()
    }

    /// Apply current configuration to eSpeak
    private func applyConfiguration() throws {
        guard isInitialized else {
            throw SynthesisError.notInitialized
        }

        espeak_SetParameter(espeakRATE, Int32(configuration.speed), 0)
        espeak_SetParameter(espeakPITCH, Int32(configuration.pitch), 0)
        espeak_SetParameter(espeakVOLUME, Int32(configuration.volume), 0)
        espeak_SetParameter(espeakWORDGAP, Int32(configuration.wordGap), 0)
    }

    /// Get the path to bundled espeak-ng-data
    private static func bundledDataPath() -> String? {
        #if SWIFT_PACKAGE
        // For Swift Package Manager, resources are in the bundle
        guard let resourceURL = Bundle.module.url(forResource: "espeak-ng-data", withExtension: nil) else {
            return nil
        }
        return resourceURL.path
        #else
        // For regular app bundle
        guard let resourcePath = Bundle.main.resourcePath else {
            return nil
        }
        return "\(resourcePath)/espeak-ng-data"
        #endif
    }

    /// List available voices
    public static func availableVoices() -> [String] {
        var voices: [String] = []
        guard let voiceList = espeak_ListVoices(nil) else {
            return voices
        }

        var index = 0
        while let voicePtr = voiceList[index], let voice = voicePtr.pointee {
            if let namePtr = voice.name {
                let name = String(cString: namePtr)
                voices.append(name)
            }
            index += 1
        }

        return voices
    }
}
