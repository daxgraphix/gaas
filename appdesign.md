# GAAS - General Arithmetic Assistant System

## Table of Contents

1. [Overview](#overview)

2. [Architecture](#architecture)

3. [Features](#features)

4. [Database Design](#database-design)

5. [Security](#security)

6. [Math Engine](#math-engine)

7. [Game Modes](#game-modes)

8. [Scoring System](#scoring-system)

9. [Achievements](#achievements)

10. [Marks & Grades](#marks--grades)

11. [User Interface](#user-interface)

12. [Localization](#localization)

---

## Overview

**GAAS (General Arithmetic Assistant System)** is a comprehensive math learning application designed to help users master arithmetic operations through interactive games, practice modes, and adaptive difficulty systems. The app supports multiple languages (English and Swahili) and features a modern, responsive UI with haptic feedback and sound effects.

---

## Architecture

### Project Structure

```dart
lib/
├── core/                    # Core services and utilities
│   ├── math_engine/        # Math problem generation engines
│   ├── themes/             # UI themes and design tokens
│   ├── providers.dart      # Riverpod state management
│   ├── sound_manager.dart  # Audio and haptic feedback
│   └── ...
├── data/                   # Data models and repositories
│   ├── models/             # Data structures
│   ├── repositories/       # Data access layer
│   └── content_library/    # Question banks and achievements
├── features/               # Feature modules
│   ├── game/               # Main game logic
│   ├── campaign/           # Campaign mode
│   ├── practice/           # Practice modes
│   ├── reports/            # Analytics and reports
│   └── ...
└── shared/                 # Reusable widgets
```

### Technology Stack

- **Framework**: Flutter (cross-platform mobile)
- **State Management**: Riverpod
- **Database**: SQLite (via sqflite)
- **Audio**: audioplayers package
- **Haptics**: Flutter haptic feedback
- **Localization**: Flutter internationalization (l10n)

---

## Features

### Core Features

#### 1. **User Profile System**

- Profile creation with avatar selection
- Progress tracking across all game modes
- Statistics and analytics dashboard

#### 2. **Game Modes**

- **Campaign Mode**: Structured progression through difficulty levels
- **Practice Mode**: Focused training on specific operations
- **Custom Mix**: User-defined operation combinations
- **Arcade Mode**: Timed challenges with leaderboards
- **Puzzle Mode**: Crosswords, equation solving, riddles

#### 3. **Math Operations**

- Addition (+)
- Subtraction (-)
- Multiplication (×)
- Division (÷)
- Mixed operations
- Advanced topics (fractions, decimals, geometry, word problems, sequences, logic)

#### 4. **Performance Tracking**

- Real-time accuracy metrics
- Streak tracking
- Session analytics
- Level mastery breakdown
- Time-based performance analysis

#### 5. **Reward System**

- Star-based progression (0-3 stars per level)
- Achievements and milestones
- Haptic feedback patterns for success/failure

---

## Database Design

### Entities

#### UserSession

```dart
class UserSession {
  String? id;
  String name;              // Sanitized (max 30 chars)
  String avatarShape;
  String avatarColor;
  String theme;
  String language;
  int totalPoints;          // Clamped to max 999999
  DateTime createdAt;
  DateTime lastPlayedAt;
  int loginStreak;          // Clamped to max 365
  List<String>? unlockedAvatars;
}
```

#### LevelProgress

```dart
class LevelProgress {
  String? id;
  String operationId;     // e.g., "addition", "multiplication"
  int level;              // Validated (1-30)
  int stars;              // 0-3 stars (clamped)
  bool isUnlocked;
  int highScore;          // Clamped to max 20
}
```

#### PuzzleProgress

```dart
class PuzzleProgress {
  String puzzleId;
  String operationType;
  int attempts;
  int bestScore;
  bool isCompleted;
  DateTime lastPlayed;
}
```

#### Statistics

```dart
class Statistics {
  int totalQuestionsAnswered;
  int correctAnswers;
  int totalTimePlayed;        // in seconds
  int currentStreak;
  int bestStreak;
  List<double> accuracyHistory;
  DateTime lastUpdated;
}
```

### Database Operations

- **Storage**: SharedPreferences (local key-value storage)
- **Caching**: Offline cache service for offline play
- **Migrations**: Automatic schema updates
- **Encryption**: XOR encryption for sensitive data (user session)

---

## Security

### Data Protection

- **Local Storage**: All user data stored locally on device
- **No Authentication**: Guest mode with optional profile setup
- **No Personal Data**: No personally identifiable information collected
- **Permissions**: Minimal Android permissions required

### Security Features

- **Data Encryption**: XOR encryption for user session data
- **Input Sanitization**: Removes dangerous characters from user inputs
- **Input Validation**: Validates user names (max 30 chars, alphanumeric + spaces only)
- **Score Validation**: Prevents score manipulation by clamping values
- **Level Validation**: Ensures level values are within valid bounds (1-30)
- **Secure ID Generation**: Creates non-guessable IDs using timestamp + random
- **Debug Mode Detection**: Identifies debug builds for security warnings

### Safe Practices

- **Input Validation**: All user inputs validated
- **Error Handling**: Graceful failure with haptic feedback
- **Secure Storage**: Sensitive data encrypted before persistence

---

## Math Engine

### Core Engines

#### 1. **MathEngine** (`lib/core/math_engine/math_engine.dart`)

Central hub that routes to specialized engines based on operation type:

- Arithmetic operations
- Advanced topics (fractions, decimals, geometry)
- Word problems
- Number sequences
- Logic challenges

#### 2. **MathRiddleEngine** (`lib/core/math_engine/math_riddle_engine.dart`)

Generates arithmetic problems with:

- Configurable difficulty (levels 1-30)
- Random operand generation
- Multiple-choice options
- Progressive hints

#### 3. **AdvancedTopicsEngine** (`lib/core/math_engine/advanced_topics_engine.dart`)

Handles complex math:

- Fraction operations
- Decimal calculations
- Geometry problems
- Algebraic expressions

#### 4. **LogicMathEngine**

Generates symbolic logic problems:

- Basic: `square + triangle = 5`
- Intermediate: Multi-variable equations
- Advanced: Systems of equations

### Question Generation Process

1. **Select Operation** → Based on user selection
2. **Determine Difficulty** → Based on level (1-30)
3. **Generate Operands** → Random numbers within constraints
4. **Calculate Answer** → Mathematical evaluation
5. **Create Distractors** → Plausible wrong answers
6. **Add Hints** → Progressive guidance

### Example: Custom Mix Question

```dart
// For multiplication at level 10
num1 = random(20) + 10  // 10-30
num2 = random(15) + 5   // 5-20
answer = num1 * num2    // 50-600

// Options: answer ± random offsets (avoid negatives)
options = [answer, answer+7, answer-5, answer+12]
```

---

## Game Modes

### 1. Campaign Mode

- **Structure**: 30 levels per operation type
- **Questions per Level**: 20 (configurable)
- **Pass Threshold**: 15 correct answers
- **Scoring**:
  - 1 star: 15-17 correct
  - 2 stars: 18-19 correct
  - 3 stars: 20 correct

### 2. Practice Mode

- Focused training on specific operations
- Adjustable difficulty
- Unlimited questions
- Real-time feedback

### 3. Custom Mix Mode

- Select multiple operations
- Choose difficulty level (1-30)
- Mixed question generation
- Session tracking

### 4. Arcade Mode

- Timed challenges (60 seconds)
- Leaderboard competition
- Combo multipliers
- Special power-ups

---

## Scoring System

### Campaign Mode Scoring

- **Questions per Level**: 20
- **Pass Threshold**: 15 correct answers
- **Star Rating**:
  - 1 star: 15-17 correct answers (75-85%)
  - 2 stars: 18-19 correct answers (90-95%)
  - 3 stars: 20 correct answers (100%)

### Puzzle Mode Scoring (Math Riddles, Number Sequences, Logic)

- **Questions per Level**: 20
- **Pass Threshold**: 15 correct answers
- **Star Rating**:
  - 1 star: 15-17 correct answers
  - 2 stars: 18-19 correct answers
  - 3 stars: 20 correct answers
- **Points per Correct Answer**: 5 points × multiplier

### Points System

| Action | Points |
|--------|--------|
| Correct Answer | 10 base + combo bonus |
| Combo x2 | +10 bonus |
| Combo x3 | +20 bonus |
| Combo x4 | +30 bonus |
| Hint Used | -50% points |
| Streak 5 | +20 bonus |
| Streak 10 | +50 bonus |
| Streak 15 | +100 bonus |

### Level Progression

- **Unlock Next Level**: Pass current level (15+ correct)
- **Stars Awarded**: Sum of stars from all operations
- **Total Stars Required**: 50 for "Stargazer" achievement

---

## Achievements

### Core Achievements

| ID | Title | Requirement | Reward |
|----|-------|-------------|--------|
| first_win | First Victory | Complete first game | 100 points |
| campaign_master | Campaign Master | Complete all campaign levels | 1000 points |
| speed_demon | Speed Demon | Answer 20 questions in 60s | 100 points |
| perfect_score | Perfect Score | 100% accuracy in any mode | 150 points |
| math_master | Math Master | Complete 50 arithmetic questions | 200 points |
| stargazer | Stargazer | Earn 50 total stars | 500 points |
| sharpshooter | Sharpshooter | 100% accuracy in 10 games | 750 points |
| time_lord | Time Lord | 3600+ seconds played | 300 points |
| scholar | Scholar | Earn 120 campaign stars | 1000 points |

### Daily Challenges

Randomly selected 4 challenges per day:

- Speed Demon: Answer 20 questions in under 60 seconds
- Perfect Score: Get 100% accuracy in any mode
- Math Master: Complete 50 arithmetic questions
- Unstoppable!: Get 10 correct answers in a row
- Campaign Grinder: Earn 9 stars in Campaign Mode
- Duel Master: Win 3 Duel games against AI
- Endless Survivor: Reach score of 200 in Endless Mode
- Division Expert: Answer 15 division questions correctly

---

## Marks & Grades

### Star-Based Progression

Stars are awarded per level and contribute to overall progress:

- **Total Stars**: Sum across all operations
- **Stars per Operation**: Sum of stars for that operation type
- **Level Mastery**: Stars determine which levels are "mastered"

### Accuracy Metrics

- **Overall Accuracy**: Total correct / Total answered × 100
- **Per-Operation Accuracy**: Accuracy for each math operation
- **Best Streak**: Highest consecutive correct answers
- **Current Streak**: Active streak counter

### Performance Tiers

| Tier | Stars | Description |
|------|-------|-------------|
| Bronze | 1-2 stars | Basic completion |
| Silver | 3-4 stars | Good performance |
| Gold | 5-6 stars | Excellent mastery |
| Platinum | 7+ stars | Perfect score |

---

## User Interface

### Design System

- **Themes**:
  - **Solar**: Warm sunlight and paper-inspired light theme.
  - **Cyber**: High-contrast neon dark theme (OLED-friendly).

### Components

- **GlassmorphicContainer**: Frosted glass effect cards
- **PremiumCard**: Elevated card with border
- **PremiumPrimaryButton**: Gradient primary button
- **StatItem**: Metrics display widget

### Responsive Design

- Mobile: Portrait optimized
- Tablet: Adaptive layouts
- Desktop (Windows): Landscape support with scaled text

---

## Localization

### Supported Languages

1. **English** (`en`) - Primary
2. **Swahili** (`sw`) - Secondary

### Localization Structure

- **App Strings**: `lib/l10n/app_en.arb`, `lib/l10n/app_sw.arb`
- **Generated Code**: `lib/l10n/generated/app_localizations.dart`
- **Delegate**: `AppLocalizations` class

### Key Localizations

- Game mode names
- Operation names
- UI labels
- Instructions
- Error messages

---

## Sound & Haptics

### Haptic Patterns

- **Light Impact**: Button presses
- **Medium Impact**: Correct answers
- **Heavy Impact**: Incorrect answers, errors
- **Selection Click**: UI navigation
- **Success Pattern**: Achievement unlocked
- **Error Pattern**: Mistake feedback
- **Level Up**: Level completion

### Sound Effects

- **click.wav**: Button interactions
- **completion.wav**: Correct answers, success
- **bling.wav**: Achievements, special events
- **levelup.wav**: Level progression

### Fallback System

```dart
Future<void> playCorrect() async {
  if (_isMuted || !_soundEnabled) {
    HapticManager.instance.successPattern();
    return;
  }
  await _playSound('correct');
}
```

---

## Performance Optimizations

### Memory Management

- **GameFlowOptimizer**: Automatic memory cleanup
- **Image Caching**: Preloaded assets
- **Lazy Loading**: On-demand resource loading

### Rendering

- **RepaintBoundary**: Selective widget repainting
- **Const Constructors**: Immutable widgets
- **AnimatedBuilder**: Efficient animations

---

## Analytics & Reporting

### Session Tracking

- Questions answered
- Correct/incorrect counts
- Time spent per session
- Operation distribution
- Accuracy trends

### Reports Screen

- **Performance Overview**: Stars, levels, accuracy, time
- **Performance Analytics**: Real-time session stats
- **Level Mastery**: Per-operation breakdown
- **Performance Insights**: Best accuracy, response time, completion rate

---

## Error Handling

### Graceful Degradation

1. **Sound Failures**: Haptic fallback
2. **Database Errors**: Continue with defaults
3. **Network Issues**: Offline mode with cache
4. **Initialization Errors**: Safe startup with ProviderScope

### User Feedback

- Visual indicators (colors, animations)
- Haptic patterns (success/error)
- Reaction messages (🔥 HOT STREAK!, 💔 STREAK BROKEN!)

---

## Future Enhancements

### Planned Features

1. **Multiplayer Mode**: Real-time competition
2. **Cloud Sync**: Cross-device progress
3. **AI Tutor**: Adaptive learning paths
4. **Voice Input**: Spoken number recognition
5. **AR Mode**: Augmented reality math

### Scalability

- Modular architecture for easy feature addition
- Configurable difficulty scaling
- Extensible question bank system

---

## Recent Updates

### Game Logic Changes (2026-06-17)

- **Pass Threshold**: 15 correct answers required to pass a level
- **Questions per Level**: 20 questions (reduced from 45)
- **3-Star Rating**:
  - 1 star: 15-17 correct
  - 2 stars: 18-19 correct
  - 3 stars: 20 correct

### Security Improvements (2026-06-17)

- XOR encryption for user session data
- Input sanitization for user names
- Score and level validation
- Secure ID generation
 
 
