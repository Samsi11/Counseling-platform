# Christian Counseling Connection Platform

## Student Information
- **Name:** NJUNG GLORIOUS SAMSIMBOM
- **Matricule:** ICTU20241321
- **Name:** MBELI CALEB AKEN
- **Matricule:** ICTU20241398
- **Course:** Software Design And Modelling
- **Submission Date:** January 2026

---

## Project Overview

The **Christian Counseling Connection Platform** is a comprehensive mobile application that connects clients seeking Christian counseling services with qualified counselors. The platform provides a seamless experience for booking sessions, communicating securely, and building a supportive community.

### Key Features

✅ **User Management**
- Dual registration system (Client & Counselor)
- Secure authentication with email verification
- Profile management for both user types

✅ **Counselor Discovery**
- Advanced search and filtering
- Counselor profiles with ratings and reviews
- Specialization-based matching

✅ **Booking System**
- Session scheduling with date/time selection
- Online and onsite session options
- Booking status tracking (pending, approved)

✅ **Communication**
- Secure in-app messaging
- Real-time message updates
- Conversation history

✅ **Social Features**
- Community feed with counselor posts
- Like and comment functionality
- Follow counselors for updates

✅ **Reviews & Ratings**
- Client feedback system
- Star ratings (1-5)
- Verified reviews from actual sessions

---

## Technology Stack

- **Framework:** Flutter 3.x
- **Language:** Dart
- **Storage:** SharedPreferences (Local Storage)
- **State Management:** StatefulWidget
- **UI Components:** Material Design

---

## Prerequisites

Before running this application, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://docs.flutter.dev/get-started/install
   
2. **Dart SDK** (comes with Flutter)

3. **Visual Studio Code** or **Android Studio**
   - VS Code Flutter Extension
   - Dart Extension

4. **Git** (for cloning the repository)

5. **Device Options:**
   - Windows Desktop (Recommended for this project)
   - Chrome Browser
   - Android Emulator
   - Physical Android/iOS device

---

## Installation Instructions

### Step 1: Clone or Extract Project

If you have the project as a ZIP file:
```bash
# Extract to a location (NOT in OneDrive or cloud storage)
# Recommended: C:\Users\YourName\Projects\
```

If cloning from repository:
```bash
git clone <repository-url>
cd christian_counseling_app
```

### Step 2: Install Dependencies

Open terminal/command prompt in the project directory:

```bash
# Navigate to project folder
cd christian_counseling_app

# Get all dependencies
flutter pub get
```

### Step 3: Verify Flutter Installation

```bash
# Check Flutter installation
flutter doctor

# Check available devices
flutter devices
```

---

## Running the Application

### Option 1: Run on Windows (Recommended)

```bash
flutter run -d windows
```

### Option 2: Run on Chrome Browser

```bash
flutter run -d chrome
```

### Option 3: Run on Android Emulator

1. Start Android emulator from Android Studio
2. Run:
```bash
flutter run
```

### Option 4: Run on Physical Device

1. Enable USB Debugging on your phone
2. Connect via USB
3. Run:
```bash
flutter run
```

---

## Project Structure

```
christian_counseling_app/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── services/
│   │   └── storage_service.dart           # Local data storage
│   └── screens/
│       ├── splash_screen.dart             # Initial loading screen
│       ├── auth/
│       │   ├── login_screen.dart          # User login
│       │   ├── register_screen.dart       # Client registration
│       │   └── counselor_register_screen.dart
│       ├── client/
│       │   ├── client_dashboard.dart      # Client home
│       │   ├── counselor_list_screen.dart # Browse counselors
│       │   ├── counselor_profile_screen.dart
│       │   └── booking_screen.dart        # Book sessions
│       ├── counselor/
│       │   └── counselor_dashboard.dart   # Counselor home
│       └── common/
│           ├── messaging_screen.dart      # Chat feature
│           ├── social_feed_screen.dart    # Community posts
│           └── profile_screen.dart        # User profile
├── pubspec.yaml                           # Dependencies
└── README.md                              # This file
```

---

## Testing the Application

### Demo Workflow

1. **Register as Client:**
   - Click "Register"
   - Fill in: Name, Email, Phone, Password
   - Login with credentials

2. **Register as Counselor:**
   - Click "Register as Counselor"
   - Fill in all required fields
   - Select specializations
   - Login with credentials

3. **Browse Counselors:**
   - Navigate to "Find" tab
   - Search for counselors
   - View profiles and ratings

4. **Book a Session:**
   - Click on a counselor
   - Click "Book Session"
   - Select date, time, and session type
   - Confirm booking

5. **Send Messages:**
   - Navigate to Messages
   - Start conversation

6. **View Social Feed:**
   - Navigate to "Feed" tab
   - View counselor posts
   - Like and comment

7. **Manage Profile:**
   - Navigate to "Profile" tab
   - View bookings and settings
   - Logout

---

## Database

The application uses **SharedPreferences** for local data persistence. All data is stored on the device and persists between app sessions.

### Data Storage:
- User accounts (clients & counselors)
- Bookings and appointments
- Messages and conversations
- Social posts and interactions
- Reviews and ratings

---

## Troubleshooting

### Issue: "Failed to delete directory" errors

**Solution:**
```bash
# Close all instances of the app and VS Code
# Then run:
flutter clean
flutter pub get
flutter run -d windows
```

### Issue: "No devices found"

**Solution:**
```bash
# Check available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Issue: Build errors after changes

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

### Issue: Hot reload not working

**Solution:**
- Press 'r' in terminal for hot reload
- Press 'R' for hot restart
- Or restart the app completely

---

## Features Implementation Status

| Feature | Status | Description |
|---------|--------|-------------|
| User Registration | ✅ Complete | Client and Counselor registration |
| Authentication | ✅ Complete | Login/Logout functionality |
| Counselor Search | ✅ Complete | Search and filter counselors |
| Profile Management | ✅ Complete | View and edit profiles |
| Session Booking | ✅ Complete | Schedule appointments |
| Messaging | ✅ Complete | In-app messaging |
| Social Feed | ✅ Complete | Posts, likes, comments |
| Reviews & Ratings | ✅ Complete | Rate and review counselors |
| Payment Integration | ⏳ Future | Online payment processing |
| Video Calling | ⏳ Future | In-app video sessions |
| Notifications | ⏳ Future | Push notifications |

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  shared_preferences: ^2.2.2
  intl: ^0.18.1
```

---

## Screen Shots

1. Client Registration
![alt text](lib/screens/screenshots/client_registration_screen.jpg)

2. Counselor Application
![alt text](<lib/screens/screenshots/counselor application.jpg>)
![alt text](lib/screens/screenshots/counselor_application2.jpg)

3. Login Screen 
![alt text](lib/screens/screenshots/login_screen.jpg)

4. Client Dashboard
![alt text](lib/screens/screenshots/client_dashboard.jpg)

5. Counselor List
![alt text](lib/screens/screenshots/find_counselor_screen.jpg)

6. Booking Screen
![alt text](lib/screens/screenshots/booking_session_screen.jpg)
![alt text](lib/screens/screenshots/booking_session_screen2.jpg)

7. Messaging
![alt text](lib/screens/screenshots/counselor_messaging_screen.jpg)

8. Social Feed
![alt text](lib/screens/screenshots/community_feed_screen.jpg)

9. Counselor Dashboard
![alt text](lib/screens/screenshots/counselor_dashboard.jpg)
![alt text](lib/screens/screenshots/counselor_dashboard2.jpg)

10. Client Profile
![alt text](lib/screens/screenshots/client_profile_screen.jpg)

11. Counselor Profile
![alt text](lib/screens/screenshots/counselor_profile_screen.jpg)

12. Create Post
![alt text](lib/screens/screenshots/creating_a_post.jpg)


---

## Known Limitations

1. **No Payment Integration:** Payment system not implemented
2. **No Video Calling:** Text-based communication only

---

## Future Enhancements

- 💳 Payment gateway integration (Stripe/PayPal)
- 📹 Video calling for online sessions
- 📊 Analytics dashboard for counselors
- 🌍 Multi-language support
- 📱 iOS optimization
- 🔐 Enhanced security with end-to-end encryption

---

## Development Notes

- **Development Time:** Approximately 5 weeks (intensive development)
- **Platform Tested:** Windows Desktop
- **Flutter Version:** 3.x
- **Target Platforms:** Windows, Android, iOS, Web

---

## License

This project was created as part of the Software Design And Modelling course.

---

## Contact Information

**Developer:** NJUNG GLORIOUS SAMSIMBOM  
**Matricule:** ICTU20241398  
**Institution:** [The ICT University]  
**Email:** [samsimbom86@gmail.com]

---

## Acknowledgments

- Flutter Documentation
- Material Design Guidelines
- Course Instructors and Teaching Assistants
- Fellow Students for support and collaboration

---

## Conclusion

The Christian Counseling Connection Platform demonstrates proficiency in:
- Flutter mobile application development
- State management
- Local data persistence
- User interface design
- Navigation and routing
- Form validation
- Material Design implementation

This project successfully implements all core requirements for a functional counseling platform, providing a solid foundation for future enhancements and production deployment.

---

**Last Updated:** January 5, 2026  
**Version:** 1.0.0  
**Status:** Completed ✅

