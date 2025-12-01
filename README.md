# Courses iOS App

Simple iOS app for accessing and watching courses from your Supabase-powered courses platform.

## Features

- User authentication (login/signup)
- Browse published courses
- View course details with sections and lessons
- Watch course videos
- Right-to-left (RTL) Arabic interface
- Check enrollment and subscription status

## Requirements

- iOS 16.0+
- Xcode 15.0+
- Swift 5.9+

## Setup Instructions

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

## Project Structure

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
    ├── LoginView.swift       # Login/signup screen
    ├── CoursesListView.swift # Courses list
    ├── CourseDetailView.swift # Course details
    └── VideoPlayerView.swift  # Video player
```

## Supabase Configuration

The app is pre-configured with your Supabase credentials in `SupabaseClient.swift`:
- URL: https://wnznhkimziiojltrxmnr.supabase.co
- Uses anonymous key for client-side access

## Database Tables Used

- `courses` - Course information
- `course_sections` - Course sections
- `course_lessons` - Individual lessons
- `course_enrollments` - User enrollments
- `subscriptions` - Active subscriptions
- `profiles` - User profiles

## Features Overview

### Authentication
- Email/password login
- New user registration
- Automatic session management
- Profile creation on signup

### Courses
- Browse all published courses
- View course thumbnails and details
- See pricing and duration information
- Filter by free/paid courses

### Course Content
- View course sections and lessons
- Check enrollment status
- Access control (free preview, enrolled, subscription)
- Video playback with AVPlayer

## Next Steps

To enhance the app, consider adding:
- Payment integration for course purchases
- Subscription management
- Progress tracking
- Offline video downloads
- Search and filter functionality
- User profile management
- Course reviews and ratings
