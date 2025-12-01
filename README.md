# 🎓 Courses iOS App - Modern 2025 Edition

A beautifully designed iOS app for accessing and watching courses from your Supabase-powered courses platform. Built with SwiftUI and featuring a modern 2025 design aesthetic.

## ✨ Features

### 🎨 Modern 2025 Design
- **Adaptive Light & Dark Mode** - Seamlessly switches between themes
- **Glassmorphism Effects** - Modern frosted glass UI elements
- **Smooth Animations** - Spring-based micro-interactions
- **Dynamic Colors** - Adapts to system appearance
- **Gradient Accents** - Eye-catching color schemes
- **Modern Typography** - SF Pro Rounded for a premium feel

### 🔐 Authentication
- Email/password login with elegant UI
- User registration with profile creation
- Automatic session management
- Beautiful gradient login cards

### 📚 Course Browsing
- Modern card-based course list
- High-quality thumbnail images
- Course metadata (duration, difficulty, price)
- Visual badges for free courses
- Smooth loading states

### 📖 Course Details
- Hero image with gradient overlay
- Expandable sections with lesson counts
- Visual access indicators (lock/unlock)
- Rich metadata display
- Modern card layouts

### 🎥 Video Player
- Full-screen video playback with AVPlayer
- Custom playback controls (play/pause, skip ±10s)
- **HTML Rich Text Support** for lesson descriptions
- Auto-play functionality
- Beautiful content cards

### 🔒 Access Control
- Free courses - Full access for everyone
- Free preview lessons - Always accessible
- Subscription-based access
- Individual course purchases
- Visual lock indicators

## 📱 Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+
- Supabase account

## 🚀 Setup Instructions

### 1. Open the Project in Xcode

Double-click `CoursesApp.xcodeproj` to open the project in Xcode.

### 2. Wait for Dependencies to Download

The app uses Supabase Swift SDK. When you first open the project, Xcode will automatically:
- Resolve Swift Package Manager dependencies
- Download the Supabase SDK (this may take 1-2 minutes)
- You'll see "Resolving Package Graph" in the top bar

### 3. Build and Run

Once dependencies are resolved:
1. Select a simulator (e.g., iPhone 15) or connected device from the top toolbar
2. Press `Cmd + R` or click the Play button to build and run
3. The app will launch in the simulator

**That's it!** The Supabase SDK and all dependencies are automatically included.

## 📂 Project Structure

```
CoursesApp.xcodeproj/         # Xcode project file
CoursesApp/
├── CoursesApp.swift          # Main app entry point
├── Info.plist                # App configuration
├── CoursesApp.xcassets/      # App icons and assets
├── Models/
│   └── Course.swift          # Data models
├── Services/
│   ├── SupabaseClient.swift  # Supabase configuration (pre-configured!)
│   ├── AuthManager.swift     # Authentication logic
│   └── CoursesService.swift  # Courses API calls
└── Views/
    ├── DesignSystem.swift        # Modern color scheme & styles
    ├── HTMLTextView.swift        # Rich text rendering
    ├── LoginView.swift           # Modern login/signup
    ├── CoursesListView.swift     # Course browsing
    ├── CourseDetailView.swift    # Course details
    └── VideoPlayerView.swift     # Video playback
```

## 🎨 Design System

The app uses a comprehensive design system with:

- **Adaptive Colors** - Automatically adjusts to light/dark mode
- **Modern Cards** - Subtle shadows and rounded corners
- **Smooth Animations** - Spring physics for natural feel
- **Gradient Accents** - Blue/purple theme
- **SF Symbols** - Latest icon set
- **Consistent Spacing** - 8pt grid system

## 🌙 Dark Mode Support

The entire app is fully optimized for dark mode:
- Dynamic colors that adapt automatically
- Proper contrast ratios
- Beautiful dark theme aesthetics
- Seamless switching

## 📊 Supabase Configuration

The app is pre-configured with your Supabase credentials in `SupabaseClient.swift`:
- URL: https://wnznhkimziiojltrxmnr.supabase.co
- Uses anonymous key for client-side access

## 🗄️ Database Tables Used

- `courses` - Course information
- `course_sections` - Course sections
- `course_lessons` - Individual lessons (supports HTML descriptions)
- `course_enrollments` - User enrollments
- `subscriptions` - Active subscriptions
- `profiles` - User profiles

## ⚡ Features Overview

### Authentication
- Modern gradient login cards
- Smooth transitions between login/signup
- Focus states on text fields
- Error handling with icons
- Profile creation on signup

### Courses
- Hero images with gradient overlays
- Metadata badges (difficulty, duration)
- Free/paid indicators
- Modern card layouts
- Smooth loading states

### Course Content
- Expandable sections with animations
- Lesson count badges
- Visual access indicators
- HTML-rendered descriptions
- Modern typography

### Video Playback
- Auto-play support
- Custom controls (±10s skip)
- Play/pause functionality
- Rich HTML lesson descriptions
- Full-screen video experience

## 🎯 Access Control Logic

```swift
func hasAccess(course, user, subscription, enrollment) -> Bool {
    // Free course
    if course.isFree { return true }

    // Free preview lesson
    if lesson.isFreePreview { return true }

    // Active subscription + included in subscription
    if subscription.active && course.includedInSubscription { return true }

    // Individual purchase
    if enrollment.exists { return true }

    return false
}
```

## 🚀 Next Steps

The app is complete and production-ready! Optional enhancements:

- Payment integration (Stripe checkout)
- Progress tracking with analytics
- Offline video downloads
- Search and advanced filters
- User profile editing
- Course reviews and ratings
- Push notifications
- Social sharing

## 📸 Screenshots

The app features:
- **Login Screen** - Gradient background with modern cards
- **Courses List** - Beautiful grid layout with thumbnails
- **Course Details** - Hero image with content cards
- **Video Player** - Full-screen with custom controls
- **Dark Mode** - Stunning dark theme throughout

## 💡 Tech Stack

- **SwiftUI** - Declarative UI framework
- **Supabase Swift SDK** - Backend integration
- **AVKit** - Video playback
- **Combine** - Reactive programming
- **HTML Rendering** - Rich text support

---

Built with ❤️ for the modern iOS experience
