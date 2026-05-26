# GAAS - Math Learning Adventure

A comprehensive[cyberswahili](../FlutterApps/cyberswahili) math learning app designed for primary school students, featuring adaptive difficulty, multiple game modes, and cross-platform support.

## 🎮 Features

- **Multiple Game Modes**: Practice, Arcade, Campaign, and more
- **Adaptive Difficulty**: Automatically adjusts based on student performance
- **Cross-Platform**: Works on Android and Windows desktop
- **Comprehensive Math Topics**: Addition, subtraction, multiplication, division, and advanced topics
- **Progress Tracking**: Detailed statistics and achievements
- **Responsive Design**: Optimized for both mobile and desktop experiences

## 🚀 Quick Start

### Prerequisites

- **Flutter** (3.0 or higher)
- **Dart** SDK
- **Android Studio** (for Android development)
- **Visual Studio** (for Windows development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/your-repo/gaas.git
cd gaas
```

2. Install dependencies:
```bash
flutter pub get
```

3. Enable platform support:
```bash
# For Android
flutter config --enable-android

# For Windows
flutter config --enable-windows-desktop
```

## 🏗️ Building for Different Platforms

### Android APK Build

#### Using Build Script (Recommended)
```bash
# Interactive menu
./build.sh menu

# Direct APK build
./build.sh apk

# Android App Bundle for Play Store
./build.sh aab
```

#### Manual Build
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

The APK files will be located in `build/app/outputs/flutter-apk/`

### Windows Desktop Build

#### Using Build Script (Recommended)
```bash
# Interactive menu
./build.sh menu

# Direct Windows build
./build.sh windows
```

#### Manual Build
```bash
flutter clean
flutter pub get
flutter build windows --release
```

The executable will be located in `build/windows/runner/Release/`

### Cross-Platform Build

```bash
# Build for all platforms
./build.sh all
```

## 🖥️ Windows-Specific Notes

### System Requirements
- Windows 10 or higher
- Minimum 4GB RAM
- 500MB free disk space

### Installation
1. Run the `build.bat` script or use the manual build commands
2. The executable will be in `build/windows/runner/Release/`
3. Create a shortcut to `gaas.exe` on your desktop for easy access

### Performance Optimization
- The app automatically optimizes memory usage for Windows
- Large screens are supported with responsive layouts
- Keyboard navigation is enabled for desktop users

## 📱 Android-Specific Notes

### System Requirements
- Android 5.0 (API 21) or higher
- Minimum 2GB RAM
- 200MB free storage

### Installation
1. Use the build scripts to generate APK files
2. Transfer the APK to your Android device
3. Enable "Install from Unknown Sources" in settings
4. Install the APK

### Play Store Deployment
1. Build the AAB (Android App Bundle):
```bash
./build.sh aab
```
2. Upload `build/app/outputs/bundle/release/app-release.aab` to Google Play Console

## 🎨 Responsive Design Features

### Mobile (Android/iOS)
- Touch-optimized interface
- Portrait orientation optimized
- Gesture-based navigation
- Haptic feedback for interactions

### Desktop (Windows)
- Mouse and keyboard support
- Resizable window support
- Multiple orientation support
- Enhanced visual elements for larger screens

### Adaptive Elements
- **Buttons**: Larger touch targets on mobile, compact on desktop
- **Text**: Responsive font sizes based on screen size
- **Layouts**: Grid systems adapt to screen width
- **Navigation**: Touch gestures on mobile, keyboard shortcuts on desktop

## 🚀 Performance Optimizations

### Caching System
- Question caching for faster game transitions
- Asset preloading for smoother UX
- Memory management with automatic cleanup

### Game Flow
- Smooth transitions between screens
- Loading indicators for better feedback
- Optimized question generation with batch processing

### Adaptability
- Dynamic difficulty adjustment based on performance
- Personalized learning paths
- Streak-based bonuses and encouragement

## 🧪 Testing

### Run Tests
```bash
./build.sh test
```

### Performance Analysis
```bash
./build.sh analyze
```

## 🧹 Maintenance

### Clean Build Artifacts
```bash
./build.sh clean
```

### Clear App Cache
```bash
# Run this command in the app
# Cache is automatically managed, but manual clearing is available
```

## 📊 Game Modes

### Practice Mode
- Unlimited questions
- Customizable question counts
- Progress tracking

### Arcade Modes
- **Score Attack**: Time-limited high score challenge
- **Endless**: Infinite questions with increasing difficulty
- **Duel**: Race against AI opponent
- **Speed Demon**: Fast-paced questions
- **Math Master**: All operations combined

### Campaign Mode
- Progressive levels (1-50)
- Operation-specific challenges
- Achievement unlocks

## 🎯 Math Topics Covered

- **Basic Operations**: Addition, Subtraction, Multiplication, Division
- **Advanced Topics**: Fractions, Decimals, Geometry, Word Problems
- **Logic Puzzles**: Pattern recognition, sequence completion
- **Number Sequences**: Fibonacci, geometric, arithmetic progressions

## 🏆 Achievements & Rewards

- **Performance-based**: Accuracy milestones, speed records
- **Progress-based**: Level completions, operation mastery
- **Special**: Streaks, perfect scores, consistency awards

## 🔧 Development

### Project Structure
```
lib/
├── core/                 # Core utilities and services
│   ├── math_engine/     # Math question generation
│   ├── game_adaptability/ # Dynamic difficulty
│   ├── utils/           # Helper utilities
│   └── themes/          # App theming
├── data/                # Data layer
│   ├── models/          # Data models
│   └── repositories/    # Data access
├── features/            # Feature modules
│   ├── game/           # Game logic
│   ├── arcade/         # Arcade modes
│   ├── campaign/       # Campaign mode
│   └── reports/        # Statistics & reports
└── main.dart           # App entry point
```

### Key Technologies
- **Flutter**: Cross-platform UI framework
- **Riverpod**: State management
- **SQLite**: Local data storage
- **Shared Preferences**: Settings storage

## 📝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
- Check the GitHub Issues page
- Review the documentation
- Contact the development team

---

**Happy Learning! 🎓✨**