# eSpeak NG Swift Package

[![CI](https://github.com/intrusive-memory/espeak/actions/workflows/ci.yml/badge.svg)](https://github.com/intrusive-memory/espeak/actions/workflows/ci.yml)

A Swift Package wrapper for [eSpeak NG](https://github.com/espeak-ng/espeak-ng), an open source speech synthesis library.

## Purpose

This repository provides a Swift Package Manager-compatible wrapper around the eSpeak NG speech synthesis library, enabling easy integration into Swift packages and Xcode projects. eSpeak NG is a compact, multilingual text-to-speech synthesizer that supports over 100 languages and accents.

## Quick Start

### Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/intrusive-memory/espeak.git", from: "1.0.0")
]
```

Or in Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/intrusive-memory/espeak.git`
3. Add to your target

### Basic Usage

```swift
import EspeakNG

// Initialize the synthesizer
let synthesizer = try EspeakSynthesizer()

// Speak some text
try synthesizer.speak("Hello, world!")

// Speak in different languages
try synthesizer.speak("Hola, mundo!", language: "es")
try synthesizer.speak("Bonjour le monde!", language: "fr")
```

### Custom Configuration

```swift
import EspeakNG

// Create custom configuration
var config = EspeakSynthesizer.Configuration()
config.pitch = 75      // 0-99 (50 is default)
config.speed = 200     // words per minute (175 is default)
config.volume = 150    // 0-200 (100 is default)
config.wordGap = 10    // pause between words in 10ms units

// Initialize with configuration
let synthesizer = try EspeakSynthesizer(configuration: config)
try synthesizer.speak("This speech has custom settings")

// Update configuration at runtime
var newConfig = EspeakSynthesizer.Configuration()
newConfig.speed = 250
try synthesizer.updateConfiguration(newConfig)
```

### List Available Voices

```swift
let voices = EspeakSynthesizer.availableVoices()
print("Available voices: \(voices.joined(separator: ", "))")
```

### SwiftUI Example

```swift
import SwiftUI
import EspeakNG

struct ContentView: View {
    @State private var text = "Hello from eSpeak NG!"
    @State private var synthesizer: EspeakSynthesizer?

    var body: some View {
        VStack(spacing: 20) {
            TextEditor(text: $text)
                .frame(height: 100)
                .border(Color.gray)

            Button("Speak") {
                Task {
                    try? synthesizer?.speak(text)
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            synthesizer = try? EspeakSynthesizer()
        }
    }
}
```

For more detailed examples, see [USAGE.md](USAGE.md).

## Project Goals

1. **Native Integration** - Package eSpeak NG as a first-class Swift dependency that can be added via Swift Package Manager
2. **Cross-Platform Support** - Support macOS, iOS, and other Apple platforms where feasible
3. **C Interoperability** - Provide Swift-friendly wrappers around the C API while maintaining full functionality
4. **Binary Distribution** - Pre-compile native binaries to avoid complex build requirements for consumers
5. **Complete Voice Data** - Bundle necessary language and voice data files with the package
6. **Documentation** - Provide clear examples and API documentation for Swift developers

## Requirements

### Technical Requirements

- **Swift 5.5+** - Modern Swift language features
- **Xcode 13.0+** - For development and testing
- **eSpeak NG Library** - Core C library and headers
- **Voice Data Files** - Language dictionaries, phoneme data, and voice configurations
- **Platform Support**:
  - macOS 11.0+ (primary target)
  - iOS 14.0+ (if audio output can be configured)
  - macOS Catalyst support (stretch goal)

### Build Requirements

- CMake or autotools for building eSpeak NG from source
- Binary compilation for multiple architectures:
  - x86_64 (Intel Macs)
  - arm64 (Apple Silicon)
  - arm64 (iOS devices)
  - x86_64 (iOS Simulator on Intel)
  - arm64 (iOS Simulator on Apple Silicon)

### Package Structure Requirements

1. **Module Map** - Create a modulemap to expose C headers to Swift
2. **Binary Targets** - XCFramework or similar for pre-built binaries
3. **Resource Bundles** - Package espeak-ng-data directory with voices and languages
4. **Swift Wrapper** - Optional Swift API layer for improved ergonomics
5. **Licensing** - Maintain GPL-3.0 compliance and attribution

## Expected Features

### Core Functionality

- Text-to-speech synthesis with multiple language support
- Voice selection and customization
- Speech parameter control (pitch, speed, volume, word gap)
- Phoneme output capability
- SSML markup support
- Multiple audio output formats

### Swift API Goals

```swift
import EspeakNG

// Initialize the synthesizer
let synthesizer = EspeakSynthesizer()

// Basic speech synthesis
try synthesizer.speak("Hello, world!", language: .english)

// Advanced configuration
synthesizer.configure {
    $0.voice = .englishUS
    $0.pitch = 50
    $0.speed = 175
    $0.volume = 100
}

// Synthesize to audio data
let audioData = try synthesizer.synthesize("Text to convert")
```

## Implementation Phases

### Phase 1: Core Library Integration
- Build eSpeak NG from source for all target architectures
- Create XCFramework with compiled binaries
- Package voice data files as resources
- Create module map for C API exposure

### Phase 2: Swift Package Setup
- Define Package.swift with proper targets and dependencies
- Configure binary targets and resource bundles
- Set up platform-specific build configurations
- Verify installation via SPM

### Phase 3: Swift Wrapper (Optional)
- Create Swift-friendly API layer
- Add error handling and type safety
- Implement modern Swift concurrency support
- Provide convenience methods

### Phase 4: Documentation & Testing
- Write comprehensive usage documentation
- Create example projects for macOS and iOS
- Add unit tests for core functionality
- Performance testing and optimization

## Usage (Once Complete)

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/espeak", from: "1.0.0")
]
```

### Xcode Project

1. File > Add Package Dependencies
2. Enter repository URL
3. Select version and add to target

## Technical Challenges

1. **Binary Size** - eSpeak NG includes extensive language data (~10-20MB)
2. **Audio Output** - Platform-specific audio handling (AVAudioEngine, AudioToolbox)
3. **Resource Loading** - Proper path resolution for espeak-ng-data directory
4. **Thread Safety** - Managing C library state in multi-threaded Swift environment
5. **Memory Management** - Bridging C memory management to Swift's ARC

## Contributing

Contributions are welcome! Please ensure:
- Code follows Swift API design guidelines
- All platforms are tested before submitting PRs
- Documentation is updated for new features
- eSpeak NG licensing (GPL-3.0) is respected

## License

This package wrapper is distributed under the GPL-3.0 license to maintain compatibility with eSpeak NG.

eSpeak NG is copyright (C) 2015-2024 Reece H. Dunn and other contributors.
Original eSpeak is copyright (C) 2005-2013 Jonathan Duddington.

## Related Projects

- [eSpeak NG](https://github.com/espeak-ng/espeak-ng) - The core speech synthesis engine
- [espeak-ng Documentation](https://github.com/espeak-ng/espeak-ng/blob/master/docs/index.md)

## Status

**Under Development** - This package is currently being structured and built. Check back for updates.
