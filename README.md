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

### 1. Open the Project

Open the project in Xcode using either:
- Open `CoursesApp.xcodeproj` if using Xcode project
- Or open `Package.swift` if using Swift Package Manager

### 2. Install Dependencies

The app uses Supabase Swift SDK. Dependencies are managed through Swift Package Manager and will be automatically resolved when you open the project.

### 3. Build and Run

1. Select a simulator or connected device
2. Press `Cmd + R` to build and run

## Project Structure

```
Sources/CoursesApp/
├── CoursesApp.swift          # Main app entry point
├── Models/
│   └── Course.swift          # Data models
├── Services/
│   ├── SupabaseClient.swift  # Supabase configuration
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
