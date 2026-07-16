# GaaS: Gamified Arithmetic & Analytics System 🚀

**GaaS** is a premium, high-performance mental mathematics training platform built with Flutter. It transcends traditional educational software by merging rigorous arithmetic exercises with advanced data analytics and a deep, RPG-inspired gamification layer.

---

## 🌟 Vision & Impact
In an era of digital distractions, GaaS aims to turn cognitive development into an addictive, rewarding experience.
- **Cognitive Growth**: Focuses on improving subitizing, mental calculation speed, and working memory.
- **The Flow State**: Uses a proprietary **Heat Index** and **Dynamic Difficulty Adjustment (DDA)** to keep users in the "sweet spot" between boredom and frustration.
- **Educational Equity**: Provides a "Professional Grade" tool for everyone, from students to professionals looking to sharpen their mental acuity.

---

## 🎮 Core Gameplay & Features

### 1. The Mastery Campaign
- **Linear Progression**: 100+ handcrafted levels across Addition, Subtraction, Multiplication, and Division.
- **Milestone Bosses**: High-pressure "Boss" levels every 10 levels with unique visual effects and tighter time constraints.
- **Adaptive Scoring**: Stars are awarded based on a combination of accuracy, speed, and the **Heat Index** maintained during the session.

### 2. The Arcade Arena
- **Score Attack**: 90-second sprints to maximize points.
- **Speed Demon**: Ultra-fast intervals—one mistake ends the session.
- **Flash Math**: High-speed visual recognition of numbers and operators.
- **Endless Mode**: Complexity scales infinitely as long as the player remains accurate.
- **Duel Mode**: Race against an AI "Ghost" that mimics your previous best performance or a target skill rating.

### 3. Advanced Puzzles
- **Cross Numbers**: A hybrid of Crosswords and Sudoku. Users must fill a grid so that every intersecting equation is mathematically valid.
- **Logic Riddles**: Non-standard arithmetic problems that require lateral thinking and pattern recognition.
- **Visual Counting**: A mode designed to improve subitizing (instantly recognizing the number of objects without counting).

### 4. Innovation: The Heat System
- **Heat Index**: A real-time "intensity" meter that grows as you answer correctly and decays over time. Higher Heat increases points but reduces the window for "Fever Mode."
- **Fever Mode**: Triggered at maximum Heat, doubling all points and providing explosive visual feedback (UI color shifts and particle effects).

### 5. Challenge & Reward Ecosystem
- **Daily & Weekly Challenges**: Procedurally generated tasks (e.g., "Solve 25 Multiplications in under 2 minutes") that reward "Math Points."
- **Avatar Shop**: Spend earned points to unlock new shapes (Diamond, Hexagon, Star) and premium neon colors for your profile.

---

## 📱 Detailed Screen Breakdown

| Screen | Description |
| :--- | :--- |
| **The Command Center (Home)** | The central hub featuring the **Quick Resume** module, Daily Challenge progress, and a snapshot of player level/XP. |
| **The Lab (Game Screen)** | The primary interface for sessions. Features a glassmorphic numpad, real-time Heat Meter, and "Fever" overlays. |
| **Campaign Map** | A vertical scrolling journey showing progress through chapters and star completion rates. |
| **Arcade Arena** | A selection screen for high-intensity modes, showing personal high scores for each sub-mode. |
| **Intelligence Center (Reports)** | A data-heavy dashboard showing accuracy heatmaps, operation-specific performance, and time-spent analytics via `fl_chart`. |
| **Daily Challenges** | A dedicated view for tracking Daily and Weekly goals with "Claim Reward" functionality. |
| **Avatar Shop** | A gamified marketplace where users spend "Math Points" to unlock premium assets. |
| **Settings & Accessibility** | Full control over Haptics, Sound FX, Language (English/Swahili), and **Focus Mode** (removes UI clutter for better concentration). |

---

## 🛠 Technical Architecture

### State Management: Riverpod
The app uses **Riverpod** for a completely reactive and testable architecture:
- `UserSessionProvider`: Manages global user state, XP progression, and profile persistence.
- `GameSessionProvider`: A high-frequency notifier handling the game loop, timers, and scoring.
- `DailyChallengeNotifier`: Manages complex reset logic and persistence for daily/weekly cycles.
- `DynamicDifficultyProvider`: Analyzes real-time performance to adjust the difficulty of the next question.

### Data & Persistence
- **Local Database (SQLite)**: Manages detailed level progress and historical session data for offline-first analytics.
- **Repositories**: Abstracted data layer for Math Riddles, User Settings, and Level Stats.
- **Math Engine**: A custom algorithmic generator that ensures every equation (including Cross Numbers) is solvable and difficulty-balanced.

### UI/UX Excellence
- **Glassmorphism**: Premium "frosted glass" UI style using `BackdropFilter` and custom layering.
- **Fluid Animations**: Leveraging `flutter_animate` for non-blocking, performant UI transitions (targeting 60-120 FPS).
- **Localization (i18n)**: Fully localized in English and Swahili with support for dynamic language switching.

---

## 💼 Business & Growth Value
- **High Retention**: Multiple feedback loops (Login Streaks, XP Progress, Global Achievements) drive long-term engagement.
- **Monetization Ready**: The "Avatar Shop" and "Points" system are primed for IAP integration.
- **Performance Analytics**: The deep-dive reporting makes it an essential tool for parents and educators to track student growth.

---

## 🚀 Getting Started

1.  **Clone & Install**: `flutter pub get`
2.  **Generate Code**: `flutter gen-l10n` (for localization)
3.  **Run**: `flutter run --release` (recommended to experience full 60FPS animations)

---
Developed by **GaaS Team** – *Quantifying Intelligence, One Equation at a Time.*
