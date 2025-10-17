# EspeakNG Swift Package Usage

## Installation

Add the package dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/espeak", from: "1.0.0")
]
```

Or in Xcode, go to **File > Add Package Dependencies** and enter the repository URL.

## Basic Usage

### Simple Text-to-Speech

```swift
import EspeakNG

do {
    let synthesizer = try EspeakSynthesizer()
    try synthesizer.speak("Hello, world!")
} catch {
    print("Error: \(error)")
}
```

### Speaking in Different Languages

```swift
let synthesizer = try EspeakSynthesizer()

// English
try synthesizer.speak("Hello, how are you?", language: "en")

// Spanish
try synthesizer.speak("Hola, ¿cómo estás?", language: "es")

// French
try synthesizer.speak("Bonjour, comment allez-vous?", language: "fr")

// German
try synthesizer.speak("Hallo, wie geht es dir?", language: "de")
```

### Customizing Speech Parameters

```swift
// Create custom configuration
var config = EspeakSynthesizer.Configuration()
config.pitch = 75      // 0-99 (50 is default)
config.speed = 200     // words per minute (175 is default)
config.volume = 150    // 0-200 (100 is default)
config.wordGap = 10    // pause between words in 10ms units

let synthesizer = try EspeakSynthesizer(configuration: config)
try synthesizer.speak("This speech has custom settings")
```

### Updating Configuration at Runtime

```swift
let synthesizer = try EspeakSynthesizer()

// Initial speech
try synthesizer.speak("This is at normal speed")

// Change configuration
var newConfig = EspeakSynthesizer.Configuration()
newConfig.speed = 250  // Faster
newConfig.pitch = 80   // Higher pitch

try synthesizer.updateConfiguration(newConfig)
try synthesizer.speak("This is at faster speed and higher pitch")
```

### Listing Available Voices

```swift
let voices = EspeakSynthesizer.availableVoices()
print("Available voices:")
for voice in voices {
    print("  - \(voice)")
}
```

## Error Handling

The synthesizer can throw the following errors:

- `SynthesisError.initializationFailed` - Failed to initialize eSpeak NG engine
- `SynthesisError.notInitialized` - Attempting to use synthesizer before initialization
- `SynthesisError.synthesisFailedWithCode(Int32)` - Speech synthesis failed with error code
- `SynthesisError.invalidParameter(String)` - Invalid parameter provided

Always wrap synthesizer calls in `do-catch` blocks:

```swift
do {
    let synthesizer = try EspeakSynthesizer()
    try synthesizer.speak("Hello!")
} catch EspeakSynthesizer.SynthesisError.initializationFailed {
    print("Failed to initialize speech engine")
} catch EspeakSynthesizer.SynthesisError.synthesisFailedWithCode(let code) {
    print("Synthesis failed with code: \(code)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Advanced Usage

### Custom Data Path

If you need to specify a custom location for espeak-ng-data:

```swift
let customDataPath = "/path/to/espeak-ng-data"
let synthesizer = try EspeakSynthesizer(dataPath: customDataPath)
```

### Long-Running Application

For apps that need to synthesize speech multiple times, create one synthesizer instance and reuse it:

```swift
class SpeechManager {
    private let synthesizer: EspeakSynthesizer

    init() throws {
        self.synthesizer = try EspeakSynthesizer()
    }

    func speak(_ text: String, language: String = "en") {
        do {
            try synthesizer.speak(text, language: language)
        } catch {
            print("Speech error: \(error)")
        }
    }
}
```

## Supported Languages

eSpeak NG supports over 100 languages. Common language codes include:

- `en` - English (US)
- `en-gb` - English (UK)
- `es` - Spanish
- `fr` - French
- `de` - German
- `it` - Italian
- `pt` - Portuguese
- `ru` - Russian
- `zh` - Mandarin Chinese
- `ja` - Japanese
- `ko` - Korean
- `ar` - Arabic
- `hi` - Hindi

For a complete list, see the [eSpeak NG language documentation](https://github.com/espeak-ng/espeak-ng/blob/master/docs/languages.md).

## Platform Support

- macOS 11.0+
- iOS 14.0+ (when built with iOS targets)

## Performance Notes

- The first speech synthesis call may take slightly longer as eSpeak NG loads voice data
- Reuse synthesizer instances when possible to avoid reinitialization overhead
- Speech synthesis is synchronous by default - consider running on a background thread for UI applications

## Example: SwiftUI Integration

```swift
import SwiftUI
import EspeakNG

struct ContentView: View {
    @State private var text = "Hello, world!"
    @State private var synthesizer: EspeakSynthesizer?

    var body: some View {
        VStack {
            TextEditor(text: $text)
                .frame(height: 100)
                .border(Color.gray)

            Button("Speak") {
                speak()
            }
        }
        .padding()
        .onAppear {
            do {
                synthesizer = try EspeakSynthesizer()
            } catch {
                print("Failed to initialize: \(error)")
            }
        }
    }

    private func speak() {
        Task {
            do {
                try synthesizer?.speak(text)
            } catch {
                print("Speech error: \(error)")
            }
        }
    }
}
```

## Troubleshooting

### "Failed to initialize speech engine"

This usually means:
1. The espeak-ng-data directory is missing or not properly bundled
2. The library wasn't built correctly for your platform

Solution: Ensure you've run the build script and the resources are properly included.

### No Audio Output

Check:
1. System volume is not muted
2. Your app has audio output permissions (if required)
3. Audio device is connected and working

### Voice Not Found

If a specific language/voice fails:
1. Check the language code is valid
2. Ensure the voice data for that language is included in espeak-ng-data
3. Use `availableVoices()` to see which voices are actually available
