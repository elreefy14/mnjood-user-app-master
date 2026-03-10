# Mnjood User App

A comprehensive Flutter-based food delivery mobile application that connects hungry customers with local restaurants. Mnjood provides a seamless ordering experience with real-time tracking, multiple payment options, and personalized recommendations.

## Overview

Mnjood is a feature-rich food delivery platform designed for the Middle East market, with full Arabic and English language support. The app enables users to discover restaurants, browse menus, place orders, and track deliveries in real-time.

## Features

### User Authentication
- Email and phone number registration
- Social login (Google, Facebook, Apple)
- OTP verification
- Password recovery
- Guest browsing mode

### Restaurant Discovery
- Browse nearby restaurants
- Filter by cuisine type, rating, delivery time
- Search restaurants and food items
- View restaurant details, menus, and reviews
- Halal food indicators
- Vegetarian/Non-vegetarian filters

### Ordering System
- Add items to cart with customizations
- Multiple add-ons and variations support
- Apply coupon codes and discounts
- Schedule orders for later
- Subscription-based ordering
- Dine-in reservations

### Checkout & Payments
- Multiple payment methods:
  - Cash on delivery
  - Digital payments
  - Wallet balance
  - Partial wallet payments
- Order notes and special instructions
- Delivery address management
- Real-time price calculation with taxes

### Order Tracking
- Real-time order status updates
- Live delivery tracking on map
- Push notifications for order updates
- In-app chat with delivery personnel
- Order history and reordering

### User Profile
- Profile management
- Saved addresses (Home, Office, Other)
- Favorite restaurants and items
- Loyalty points system
- Wallet management
- Refer and earn program

### Additional Features
- Multi-language support (English, Arabic)
- Dark/Light theme
- Push notifications
- In-app customer support
- Rate and review orders
- Promotional banners and campaigns

## Technical Stack

- **Framework**: Flutter 3.35.7
- **State Management**: GetX
- **Architecture**: Clean Architecture with Repository Pattern
- **Networking**: HTTP/Dio
- **Local Storage**: SharedPreferences, GetStorage
- **Maps**: Google Maps Flutter
- **Push Notifications**: Firebase Cloud Messaging
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

## Getting Started

### Prerequisites

- Flutter SDK 3.35.7 or higher
- Dart SDK 3.0+
- Android Studio / VS Code
- Android SDK (API 21+)
- Xcode 14+ (for iOS development)
- Google Maps API Key
- Firebase Project

### Installation

1. Clone the repository:
```bash
git clone https://github.com/mohamed1nashaat/mnjood-user-app.git
```

2. Navigate to the project directory:
```bash
cd mnjood-user-app
```

3. Install dependencies:
```bash
flutter pub get
```

4. Configure environment:
   - Add your Google Maps API key in `android/app/src/main/AndroidManifest.xml`
   - Update Firebase configuration files (`google-services.json` for Android, `GoogleService-Info.plist` for iOS)
   - Set your API base URL in `lib/util/app_constants.dart`

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── api/
│   └── api_client.dart          # HTTP client and API handling
│
├── common/
│   ├── models/                   # Shared data models
│   │   ├── product_model.dart
│   │   ├── restaurant_model.dart
│   │   └── ...
│   └── widgets/                  # Reusable UI components
│       ├── custom_image_widget.dart
│       ├── product_widget.dart
│       └── ...
│
├── features/
│   ├── auth/                     # Authentication module
│   │   ├── controllers/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── home/                     # Home screen module
│   │   ├── controllers/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── restaurant/               # Restaurant details module
│   │   ├── controllers/
│   │   ├── domain/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   ├── cart/                     # Shopping cart module
│   ├── checkout/                 # Checkout flow module
│   ├── order/                    # Order management module
│   ├── product/                  # Product details module
│   ├── category/                 # Categories module
│   ├── cuisine/                  # Cuisines module
│   ├── search/                   # Search module
│   ├── address/                  # Address management module
│   ├── profile/                  # User profile module
│   ├── wallet/                   # Wallet module
│   ├── loyalty/                  # Loyalty points module
│   ├── coupon/                   # Coupons module
│   ├── notification/             # Notifications module
│   ├── chat/                     # Chat module
│   ├── location/                 # Location services module
│   ├── splash/                   # Splash screen module
│   ├── onboarding/               # Onboarding module
│   ├── dashboard/                # Main dashboard module
│   ├── menu/                     # Menu module
│   ├── dine_in/                  # Dine-in reservations module
│   └── ...
│
├── helper/
│   ├── date_converter.dart       # Date formatting utilities
│   ├── price_converter.dart      # Price formatting utilities
│   └── ...
│
└── util/
    ├── app_constants.dart        # App configuration constants
    ├── dimensions.dart           # UI dimensions
    ├── styles.dart               # Text styles
    └── ...

assets/
├── font/                         # Custom fonts (Roboto)
├── image/                        # App images and icons
├── language/                     # Localization files (en.json, ar.json)
└── map/                          # Map style configurations
```

## Configuration

### API Configuration
Update `lib/util/app_constants.dart`:
```dart
static const String baseUrl = 'https://your-api-domain.com';
```

### Google Maps
Add your API key in `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### Firebase
Replace the Firebase configuration files:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Build & Release

### Android

Debug build:
```bash
flutter build apk --debug
```

Release build:
```bash
flutter build apk --release
```

App Bundle (for Play Store):
```bash
flutter build appbundle --release
```

### iOS

Debug build:
```bash
flutter build ios --debug
```

Release build:
```bash
flutter build ios --release
```

## Supported Platforms

- Android 5.0 (API 21) and above
- iOS 12.0 and above

## Localization

The app supports multiple languages:
- English (en)
- Arabic (ar)

Language files are located in `assets/language/`.

## Author

**Mohamed Nashat**
- GitHub: [@mohamed1nashaat](https://github.com/mohamed1nashaat)
- Email: nashaat4c@gmail.com

## License

This project is proprietary software. All rights reserved.

## Acknowledgments

- Flutter Team
- GetX State Management
- Google Maps Platform
- Firebase
