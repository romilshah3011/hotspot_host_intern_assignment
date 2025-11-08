# Hotspot Hosts Onboarding Questionnaire

A Flutter-based onboarding questionnaire application for Hotspot Hosts, built with clean architecture, state management, and modern UI/UX practices.

## 📱 Overview

This application facilitates the onboarding process for individuals who want to become hosts on the platform. It consists of a two-step questionnaire that collects information about the host's preferred experience types and their motivation for hosting.

## ✨ Features Implemented

### Core Features

#### 1. Experience Type Selection Screen
- ✅ **Dynamic Experience List**: Fetches and displays experiences from the provided API
- ✅ **Multi-Selection**: Users can select/deselect multiple experience cards
- ✅ **Visual Feedback**: 
  - Unselected cards display grayscale images
  - Selected cards display original colored images
  - Cards have slight tilt variations (left, right, center) for visual appeal
- ✅ **Description Text Field**: 
  - Multi-line text input with 250 character limit
  - Real-time character counter
  - Compulsory field with validation
- ✅ **State Management**: Selected experience IDs and description text are stored in state
- ✅ **Navigation**: Logs state on "Next" click and navigates to the question screen
- ✅ **Disabled Navigation**: Back and close buttons are disabled on the first page

#### 2. Onboarding Question Screen
- ✅ **Answer Text Field**: 
  - Multi-line text input with 600 character limit
  - Real-time character counter
  - Compulsory field with validation
- ✅ **Audio Recording**: 
  - Record audio answers with real-time waveform visualization
  - Up/down wave pattern visualization while speaking
  - Cancel option during recording
  - Playback functionality with play/pause controls
  - Delete recorded audio option
- ✅ **Video Recording**: 
  - Record video answers with camera preview
  - Switch between front and back camera during recording
  - Cancel option during recording
  - Video playback with expandable/collapsible preview
  - Delete recorded video option
- ✅ **Dynamic Layout**: 
  - Recording buttons (audio/video) automatically hide when corresponding media is recorded
  - Smooth animations when buttons appear/disappear
- ✅ **Success Message**: Shows "Questionnaire submitted successfully!" message on submission
- ✅ **Navigation**: Returns to first page after successful submission

### Technical Features

- ✅ **State Management**: Implemented using Riverpod for reactive state management
- ✅ **API Integration**: Uses Dio for HTTP requests to fetch experiences
- ✅ **Clean Architecture**: MVC pattern with separate screens, models, services, and providers
- ✅ **Error Handling**: Comprehensive error handling for API calls and media operations
- ✅ **File Management**: Proper cleanup of recorded audio/video files on deletion
- ✅ **Permissions**: Handles microphone and camera permissions gracefully

## 🎯 Brownie Points (Optional Enhancements)

### UI/UX Enhancements
- ✅ **Pixel-Perfect Design**: 
  - Implemented according to Figma specifications
  - Custom font: Space Grotesk with proper sizes, weights, and spacing
  - Color palette matching design specifications
  - Proper spacing and padding throughout
- ✅ **Responsive Design**: 
  - Handles keyboard open/close scenarios
  - Content adjusts when viewport height is reduced
  - Proper layout management with LayoutBuilder and ConstrainedBox

### State Management
- ✅ **Riverpod Implementation**: 
  - Complete state management using Flutter Riverpod
  - Separate providers for experiences and onboarding state
  - Reactive UI updates based on state changes
- ✅ **Dio for API Calls**: 
  - Clean API service implementation
  - Proper error handling and response parsing
  - Type-safe models for API responses

### Animations
- ✅ **Experience Screen**: 
  - **Card Selection Animation**: On selection, cards animate and slide to the first index
  - Selected cards smoothly transition to the front of the list
  - AnimatedPositioned and AnimatedContainer for smooth transitions
  - Maintains visual hierarchy with selected items appearing first
- ✅ **Question Screen**: 
  - **Animated Next Button Width**: Next button width animates smoothly when recording buttons disappear
  - When audio/video is recorded, recording buttons fade out and Next button expands to full width
  - Smooth 400ms animations with easeInOut curve
  - AnimatedContainer for dynamic layout changes

## 🚀 Additional Features & Enhancements

### Enhanced User Experience
- ✅ **Visual Progress Indicator**: Custom wavy progress bar showing questionnaire progress
- ✅ **Background Pattern**: Subtle wavy background pattern for visual depth
- ✅ **Double Arrow Icon**: Custom Next button with double arrow (arrow + chevron) design
- ✅ **Image Optimization**: Uses cached_network_image for efficient image loading
- ✅ **Audio Waveform**: Real-time amplitude-based waveform visualization during recording
- ✅ **Video Preview**: Expandable/collapsible video preview with play/pause controls
- ✅ **Camera Switching**: Seamless camera switching during video recording
- ✅ **File Cleanup**: Automatic file deletion when media is removed

### Code Quality
- ✅ **Clean Code**: Well-structured, readable code with proper comments
- ✅ **Scalable Architecture**: 
  - Separate directories for screens, widgets, models, services, providers, utils, and theme
  - Reusable components
  - Separation of concerns
- ✅ **Error Handling**: Comprehensive try-catch blocks and error messages
- ✅ **Type Safety**: Strong typing throughout the application
- ✅ **Null Safety**: Full null safety implementation

## 🛠️ Tech Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: Flutter Riverpod (^2.5.1)
- **HTTP Client**: Dio (^5.4.0)
- **Fonts**: Google Fonts (^6.1.0) - Space Grotesk
- **Image Loading**: cached_network_image (^3.3.0)
- **Audio Recording**: record (^6.1.2)
- **Audio Playback**: just_audio (^0.9.36)
- **Video Recording**: camera (^0.11.2+1)
- **Video Playback**: video_player (^2.8.1)
- **Permissions**: permission_handler (^12.0.1)
- **Path Provider**: path_provider (^2.1.1)

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── experience.dart       # Experience model
├── screens/                  # Screen widgets
│   ├── experience_selection_screen.dart
│   ├── onboarding_question_screen.dart
│   └── video_recording_screen.dart
├── widgets/                  # Reusable widgets
│   ├── experience_card.dart
│   ├── audio_recording_widget.dart
│   ├── audio_player_widget.dart
│   ├── video_player_widget.dart
│   ├── wavy_progress_bar.dart
│   └── background_pattern.dart
├── services/                 # Business logic
│   └── api_service.dart      # API service with Dio
├── providers/                # State management
│   ├── experience_provider.dart
│   └── onboarding_provider.dart
├── utils/                     # Utility classes
│   ├── permission_helper.dart
│   └── audio_recorder_helper.dart
└── theme/                     # App theming
    ├── app_colors.dart
    └── app_text_styles.dart
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd assignment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎨 Design Specifications

### Typography
- **Font Family**: Space Grotesk
- **Font Sizes**: 10px, 12px, 14px, 16px, 20px, 24px, 28px
- **Font Weights**: Regular (200), Bold (400)
- **Letter Spacing**: -3% to 0%
- **Line Heights**: 12px to 36px

### Colors
- **Text Colors**: White with varying opacity (24%, 48%, 72%, 100%)
- **Base Colors**: #101010, #151515
- **Surface Colors**: White/Black with varying opacity
- **Accent Colors**: 
  - Primary: #9196FF
  - Secondary: #5961FF
  - Positive: #FE5BDB
  - Negative: #C22743

## 📸 Demo

A screen recording demonstrating all functionalities is available. The demo covers:
- Experience selection with multiple cards
- Text input with character limits
- Audio recording with waveform visualization
- Video recording with camera switching
- Media playback and deletion
- Form submission and navigation


## 📄 License

This project is part of an assignment submission.

## 👤 Author

**Romil Shah**
- Email: romilshah3011@gmail.com
- GitHub: https://github.com/romilshah3011

## 🙏 Acknowledgments

- 8club.co for providing the assignment requirements
- Flutter team for the amazing framework
- All package maintainers for their excellent work

---

## 📧 Submission

**Submitted to**: jatin@8club.co

**Repository**: https://github.com/romilshah3011/hotspot_host_intern_assignment

**Demo Video**: https://drive.google.com/file/d/1oNuxDNKp5gF5eHKWF9Ro7htAGXH_lrjK/view?usp=drive_link

