# Meypato - Rent Management Mobile App

## Project Overview
**Meypato** is a comprehensive Flutter-based mobile application designed as a **rent searching platform for tenants** to find places to live (apartments, PGs, rooms). The app focuses on helping tenants discover properties, manage their rental subscriptions, track payments, and provide community-based filtering with cultural/professional compatibility.

## Target Users
- **Primary**: Tenants looking for rental properties (apartments, PGs, rooms)
- **Secondary**: Platform for displaying properties listed by property owners
- **Geographic Focus**: India (with cultural/tribal considerations)

## Core Value Proposition
- **For Tenants**: Search and find verified properties with cultural/professional compatibility
- **Rent Management**: Manage rental subscriptions, track monthly payments, and maintain rental history
- **Community Features**: Tribe/profession-based filtering and transparent review system
- **Document Management**: Handle rental agreements and verification documents digitally

---

## Technical Stack

### Frontend
- **Framework**: Flutter (multi-platform: iOS, Android, Web)
- **Language**: Dart
- **State Management**: Provider
- **Navigation**: Go Router
- **UI**: Material Design

### Backend & Database
- **BaaS**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **File Storage**: Supabase Storage
- **Real-time**: Supabase Realtime

### Key Dependencies
- **supabase_flutter** (^2.10.0) - Backend integration
- **go_router** (^16.2.0) - Navigation
- **provider** (^6.1.5+1) - State management and theme management
- **google_sign_in** (^6.3.0) - Google OAuth authentication
- **shared_preferences** (^2.5.3) - Local storage for user preferences
- **geolocator** (^14.0.2) - Location services
- **image_picker** (^1.2.0) - Photo uploads
- **http** (^1.5.0) - API calls

---

## App Architecture

### Folder Structure
```
lib/
├── common/          # Shared utilities and routing
│   └── router.dart  # GoRouter configuration and route management
├── configs/         # App configuration files
│   └── supabase_config.dart  # Supabase connection configuration
├── models/          # Data models and entities
│   ├── building.dart              # Building/Property model with location and amenities
│   ├── enums.dart                 # All enums (UserRole, VerificationStatus, etc.)
│   ├── models.dart                # Barrel export file for all models
│   ├── payment.dart               # Payment/Transaction model
│   ├── profile.dart               # User profile model with verification
│   ├── reference_models.dart      # Location reference models (Country, State, City)
│   ├── review.dart                # Review/Feedback model
│   ├── room.dart                  # Room/Rental unit model
│   └── subscription.dart          # Tenancy/Subscription model
├── screens/         # UI screens organized by feature
│   ├── auth/        # Authentication screens
│   │   ├── login_screen.dart     # Login with email/password and Google
│   │   └── register_screen.dart  # User registration
│   ├── home/        # Main app screens
│   │   └── home_screen.dart      # Main dashboard with embedded profile content
│   ├── profile/     # User profile screens
│   │   ├── profile_screen.dart        # Menu-based profile overview
│   │   └── profile_detail_screen.dart # Detailed profile edit form
│   └── settings/    # Settings screens
│       └── settings_screen.dart       # App settings and preferences
├── services/        # Business logic and API services
│   ├── auth_service.dart         # Email/password authentication
│   ├── google_auth_service.dart  # Google Sign-In integration
│   └── profile_service.dart      # Profile data operations and Supabase integration
├── providers/       # State management providers
│   └── profile_provider.dart     # Profile state management with Provider pattern
├── themes/          # App theming and styling
│   ├── app_colour.dart           # Comprehensive color palette for light/dark themes
│   └── theme_provider.dart       # Theme state management with SharedPreferences
├── widgets/         # Reusable UI components
│   ├── sliding_sidebar.dart       # Animated sidebar with content shift animation
│   ├── bottom_navigation.dart     # Custom bottom navigation with 5 rent-focused tabs
│   └── theme_toggle_button.dart   # Light/dark mode toggle components
└── main.dart        # App entry point
```

### Database Schema
See `docs/databases/database.md` for comprehensive schema documentation.

**Core Entities:**
- **Users (Profiles)**: Multi-role system (tenant/owner)
- **Properties (Buildings)**: Listings with location/amenities
- **Rental Units (Rooms)**: Individual units with pricing
- **Tenancy (Subscriptions)**: Active rental agreements
- **Transactions (Payments)**: Rent payment tracking
- **Feedback (Reviews)**: Rating and review system

---

## Key Features

### 1. User Management
- **Dual Role System**: Tenant and Owner accounts
- **Profile Verification**: Document upload and verification workflow
- **Cultural Integration**: Tribe and profession-based filtering
- **Location Services**: State/City hierarchical organization

### 2. Property Discovery
- **Property Search**: Browse buildings with photos, amenities, and rules
- **Room Browsing**: View individual rental units with pricing and availability
- **Geographic Search**: Location-based property discovery with filters
- **Access Control**: Profession/tribe-based compatibility filtering

### 3. Subscription Management
- **Rental Subscriptions**: Manage active tenancy agreements for rented rooms
- **Payment Tracking**: Track monthly rent payments and payment history
- **Document Storage**: Access rental agreements, IDs, and verification documents
- **Subscription Status**: Monitor active rentals and subscription details

### 4. Community Features
- **Review System**: Building ratings with verification
- **Photo Sharing**: Property and review photo uploads
- **Filtering Options**: Cultural, professional, and geographic filters
- **Emergency Contacts**: Safety and security features

### 5. Payment Management
- **Monthly Payments**: Track and manage monthly rent payments
- **Payment History**: Complete transaction history and receipts
- **Payment Methods**: Support for various payment methods
- **Security Deposits**: Monitor security deposit payments and refunds

---

## User Journeys

### Primary User Flow (Tenants)
1. **Registration** → Profile creation with verification documents (tribe, profession, location)
2. **Discovery** → Search and browse available properties with cultural/professional filters
3. **Property Details** → View rooms, amenities, pricing, and building information
4. **Compatibility Check** → Ensure access based on tribe/profession restrictions
5. **Subscription** → Subscribe to rent a room and sign digital rental agreement
6. **Payment Management** → Track and pay monthly rent with payment history
7. **Reviews** → Rate and review buildings based on living experience
8. **Subscription Monitoring** → Manage active rentals and rental documents

### App Purpose Clarification
- **This is NOT a property listing app** - Tenants cannot list properties
- **Property listings are managed externally** - Buildings and rooms are added to the platform by property owners/administrators
- **Tenant-focused platform** - The app serves tenants looking for places to live
- **Subscription management** - Focus on managing rental agreements and payments for subscribed rooms

---

## Business Logic

### Verification System
- **3-tier verification**: Document → Police → Profile verification
- **Verification states**: Unverified → Pending → Verified → Rejected
- **Document types**: ID proof, Police verification, Address proof

### Access Control
- **Inclusion by default**: Open access unless restricted
- **Exception-based filtering**: Specific profession/tribe restrictions per building
- **Owner discretion**: Property owners control access rules

### Subscription Management
- **One active subscription per room**: Each room can only have one active tenant subscription
- **Monthly payment tracking**: One payment per month per subscription for rent tracking
- **Subscription lifecycle**: Active subscriptions link tenants to specific rooms
- **Payment history**: Complete tracking of all rent payments made by tenants

### Geographic Organization
- **Hierarchical structure**: Country → State → City
- **Location services**: GPS coordinates for properties
- **Search optimization**: Location-based property discovery

---

## Security & Compliance

### Data Protection
- **User authentication**: Supabase Auth integration
- **Document security**: Secure file storage with access controls
- **Personal data**: Encrypted storage of sensitive information
- **Privacy controls**: User data visibility settings

### Financial Security
- **Payment validation**: Amount and method verification
- **Transaction tracking**: Complete audit trail
- **Fraud prevention**: Payment method validation
- **Secure references**: Transaction ID tracking

### Access Security
- **Role-based access**: Tenant vs Owner permissions
- **Document verification**: Multi-step verification process
- **Emergency contacts**: Safety and security measures
- **Active status controls**: Account deactivation capabilities

---

## Navigation System Architecture

### Sliding Sidebar Navigation
- **Animation**: 300ms smooth slide animation with content shift (not overlay)
- **Width**: 280px sidebar that pushes main content to the right
- **Profile Section**: Beautiful gradient avatar border with user info and role badge
- **Navigation Items**: Rent-focused sections with selected state indicators
  - Search Rentals (default selected)
  - Properties, Favorites, Near Me
  - Recent Searches, Filters
  - My Profile, Notifications, Messages
  - Settings, Help & Support, Logout
- **Theme Integration**: Integrated theme toggle switch at bottom
- **Gestures**: Tap outside to close, hamburger menu button with animated icon
- **Color Scheme**: Uses AppColors for consistent blue theming across light/dark modes

### Bottom Navigation System
- **Tabs**: 5 main sections (Search, Properties, Favorites, Near Me, Profile)
- **Profile Integration**: Profile tab shows embedded profile content within home screen
- **Animations**: 200ms smooth transitions with filled/outline icon switching
- **Visual Feedback**: Selected state backgrounds, indicator dots, and color changes
- **Height**: 85px to prevent overflow with proper padding
- **Theme Integration**: Automatically adapts to light/dark mode using AppColors
- **State Management**: Integrated with home screen state for seamless tab switching

### Navigation Architecture
- **Dual System**: Sidebar for feature navigation, bottom tabs for main sections
- **State Consistency**: Both navigation systems work together seamlessly
- **Placeholder Ready**: All navigation items have TODO placeholders for future screen implementation
- **Theme Awareness**: All components automatically adapt colors based on current theme
- **Performance**: Smooth 60fps animations with proper AnimationController management

---

## Data Models Implementation

### Core Models Architecture
- **9 Complete Models**: All models matching the database schema with proper relationships
- **Type Safety**: Full Dart type safety with null safety compliance
- **JSON Serialization**: Complete `fromJson` and `toJson` methods for all models
- **Barrel Exports**: Central `models.dart` file for clean imports
- **Enum Integration**: Comprehensive enum definitions for all categorical data

### Model Files Structure
1. **Profile Model**: User profiles with verification status, roles, and personal information
2. **Building Model**: Property listings with location, amenities, and restrictions
3. **Room Model**: Individual rental units with pricing and availability
4. **Subscription Model**: Tenancy agreements linking tenants to rooms
5. **Payment Model**: Transaction records with payment methods and status
6. **Review Model**: Rating and feedback system with photo support
7. **Reference Models**: Location hierarchy (Country, State, City, Profession, Tribe)
8. **Enums**: All categorical data types (UserRole, VerificationStatus, etc.)
9. **Models Barrel**: Single import point for all models

### Model Features
- **Relationship Mapping**: Foreign key relationships properly defined
- **Validation Ready**: Models structured for form validation
- **Database Sync**: Perfect alignment with Supabase schema
- **Extensible Design**: Easy to extend with additional fields
- **Clean Architecture**: Separation of concerns with dedicated model layer

---

## Development Guidelines

### Code Standards
- **Dart conventions**: Follow official Dart style guide
- **Flutter best practices**: Material Design 3 guidelines implemented
- **State management**: Provider for theme management, GoRouter for navigation
- **Theme architecture**: Complete light/dark mode system with persistent storage
- **Error handling**: Comprehensive try/catch blocks with user-friendly messages

### Critical Development Rules
- **SYNTAX FIRST RULE**: Always run `flutter analyze` after ANY code edit
- **ZERO TOLERANCE FOR SYNTAX ERRORS**: If parenthesis/bracket issues occur:
  1. STOP all feature development immediately
  2. Focus 100% on fixing syntax errors first
  3. Never proceed with new features while syntax errors exist
  4. If unable to fix syntax issues after 2 attempts, STOP and ask for help
- **Small Incremental Edits**: Make smaller, targeted changes instead of large multi-line replacements
- **Verify Before Proceeding**: Each edit must be verified with `flutter analyze` before moving to next task

### Authentication Implementation
- **Supabase Auth**: Official supabase_flutter package integration complete
- **Session Management**: Automatic session persistence with SharedPreferences
- **Auth Guards**: Route-level authentication protection with GoRouter
- **State Listening**: Real-time auth state changes with stream subscriptions
- **Error Handling**: Graceful error handling with user feedback via SnackBars

### Google Authentication Implementation
- **Google Sign-In**: Integrated google_sign_in package v6.3.0 (compatible with Supabase)
- **OAuth Configuration**: Web OAuth client configured for server verification
- **Package Structure**: Updated to com.meypato.app for proper identification
- **Cross-Platform Setup**: iOS Info.plist configured with reversed client ID
- **Supabase Integration**: Google ID token authentication with automatic profile creation
- **Error Handling**: Comprehensive error handling for sign-in failures and cancellations
- **Profile Management**: Automatic profile completion checking and user onboarding flow

### Theme System Implementation
- **Light/Dark Mode Support**: Complete theme system with instant switching capability
- **ThemeProvider**: State management using Provider package with SharedPreferences persistence
- **Color Palette**: Comprehensive color scheme in app_colour.dart supporting both themes
- **Theme Toggle Components**: Reusable toggle buttons (icon and full button variants)
- **Material Design 3**: Full theming for buttons, inputs, cards, text, and app bars
- **Persistent Storage**: Theme preference automatically saved and restored on app restart
- **Dynamic Theming**: All auth screens and components adapt colors based on current theme
- **Professional UI**: Beautiful gradients, shadows, and contrast in both light and dark modes
- **Consistent Color Integration**: All navigation components use AppColors for unified blue theming
- **Theme-Aware Components**: Sidebar and bottom navigation automatically adapt to light/dark modes

### Navigation and Routing
- **GoRouter Implementation**: Centralized routing configuration in common/router.dart
- **Route Management**: Clean route path constants and navigation structure
- **Auth-Protected Routes**: Route guards for authenticated-only screens
- **Navigation Flow**: Login → Home → Profile → Settings → Profile Details
- **Deep Linking Support**: URL-based navigation for web and mobile platforms
- **Sliding Sidebar Navigation**: Animated sidebar with content shift animation (280px width)
- **Bottom Navigation System**: 5-tab navigation with embedded profile content
- **Dual Navigation Architecture**: Sidebar for feature navigation, bottom tabs for main sections

### Profile Management Implementation
- **ProfileProvider**: Complete state management using Provider pattern with loading states
- **ProfileService**: Full CRUD operations with Supabase integration and file upload support
- **Profile Screen**: Menu-based UI with profile overview and quick access to settings
- **Profile Detail Screen**: Comprehensive form-based editing with validation and error handling
- **Settings Screen**: App preferences, theme toggle, logout, and profile edit access
- **State Synchronization**: Real-time profile data updates across all screens
- **Form Validation**: Database-matching validation rules for all profile fields
- **File Upload Ready**: Support for profile photos and document uploads
- **Bottom Navigation Integration**: Profile content embedded in home screen for seamless UX

### Database Operations
- **Supabase integration**: Configured with project URL and anon key
- **Real-time updates**: Leverage Supabase Realtime capabilities
- **Row Level Security**: Database security implemented at schema level
- **Data validation**: Client-side form validation implemented

### File Management
- **Image handling**: Image picker integration ready for implementation
- **Document storage**: Supabase Storage integration planned
- **Caching strategy**: Local caching strategies to be implemented
- **Upload progress**: User feedback during uploads to be added

### Testing Strategy
- **Unit tests**: Business logic testing for auth service
- **Widget tests**: UI component testing for login/home screens
- **Integration tests**: End-to-end authentication flow testing
- **Performance testing**: App responsiveness and load testing

---

## Deployment & Operations

### Build Commands
```bash
# Development
flutter run

# Build for release
flutter build apk --release        # Android
flutter build ios --release        # iOS
flutter build web --release        # Web
```

### Environment Management
- **Development**: Local Supabase instance
- **Staging**: Staging Supabase project
- **Production**: Production Supabase project

### Monitoring
- **Error tracking**: Crash reporting and analytics
- **Performance monitoring**: App performance metrics
- **User analytics**: Usage patterns and feature adoption
- **Payment monitoring**: Transaction success rates

---

## Future Enhancements

### Phase 2 Features
- **Push notifications**: Payment reminders, lease renewals
- **In-app messaging**: Tenant-owner communication
- **Virtual tours**: 360° property viewing
- **Advanced search**: AI-powered property recommendations

### Phase 3 Features
- **IoT integration**: Smart home device management
- **Marketplace**: Furniture and services marketplace
- **Community forum**: Tenant community features
- **Analytics dashboard**: Advanced reporting for owners

### Technical Improvements
- **Offline support**: Core functionality without internet
- **Performance optimization**: Faster loading and smoother animations
- **Accessibility**: Screen reader and accessibility support
- **Internationalization**: Multi-language support

---

## Project Structure Notes

### Current State
- ✅ Project foundation and dependencies set up
- ✅ Database schema designed and documented
- ✅ Folder structure established with router and services organization
- ✅ Supabase integration and configuration complete
- ✅ Email/password authentication service implementation complete
- ✅ Google Sign-In authentication fully implemented and working
- ✅ Login screen with email/password and Google Sign-In options
- ✅ Home screen with logout functionality
- ✅ Navigation routing with GoRouter and auth guards
- ✅ Auth state management and automatic redirects
- ✅ Package name updated to com.meypato.app for production readiness
- ✅ User registration/signup screen with Google Sign-In integration
- ✅ Complete theme system with light/dark mode toggle and persistence
- ✅ Beautiful UI design with proper logo integration and compact spacing
- ✅ Theme-aware authentication screens with dynamic color adaptation
- ✅ Sliding sidebar navigation with content shift animation and rent-focused features
- ✅ Bottom navigation system with 5 tabs and beautiful animations
- ✅ Consistent blue theming across all navigation components using AppColors
- ✅ Core Dart models implementation complete with 9 models matching database schema
- ✅ Profile management system with ProfileProvider state management
- ✅ Profile screen with menu-based UI and embedded bottom navigation integration
- ✅ Profile detail screen with comprehensive form-based profile editing
- ✅ Settings screen with theme toggle, logout functionality, and app preferences
- ✅ ProfileService with complete CRUD operations and Supabase integration
- ⏳ Property listing and management features needed
- ⏳ Rental operations and payment features needed

### Recently Completed
1. **Supabase Setup**: ✅ Configured with project URL and anon key
2. **Authentication Service**: ✅ Complete auth service with sign in/up/out and password reset
3. **Google Authentication**: ✅ Full Google Sign-In integration with Supabase backend
4. **Login Screen**: ✅ Beautiful Material Design UI with email/password and Google Sign-In options
5. **Register Screen**: ✅ Complete signup screen with Google integration (no confirm password)
6. **Navigation System**: ✅ GoRouter with auth-based routing and state management
7. **Home Screen**: ✅ Basic welcome screen with logout functionality
8. **Package Configuration**: ✅ Updated to com.meypato.app with proper OAuth setup
9. **Theme System**: ✅ Complete light/dark mode with Provider and SharedPreferences
10. **UI Design**: ✅ Professional logo integration, compact spacing, and theme adaptation
11. **Theme Components**: ✅ Reusable toggle buttons and comprehensive color palette
12. **Project Structure**: ✅ Organized routing, services, themes, and widgets for scalable development
13. **Sliding Sidebar**: ✅ Animated sidebar with 280px content shift and rent-focused navigation items
14. **Bottom Navigation**: ✅ 5-tab navigation with beautiful animations and theme integration
15. **Color Consistency**: ✅ All navigation components updated to use AppColors for unified theming
16. **Navigation Architecture**: ✅ Dual navigation system ready for feature implementation
17. **Core Models**: ✅ Complete Dart model implementation with 9 models matching database schema
18. **Model Architecture**: ✅ Barrel exports, enums, and reference models for scalable data management
19. **Profile Management System**: ✅ Complete profile management with Provider state management
20. **Profile Screen**: ✅ Menu-based profile UI with clean design and embedded bottom navigation
21. **Profile Detail Screen**: ✅ Comprehensive form-based profile editing with validation
22. **Settings Screen**: ✅ App settings with theme toggle, logout, and preference management
23. **ProfileService**: ✅ Complete CRUD operations with Supabase integration and file upload support
24. **ProfileProvider**: ✅ State management for profile data with loading states and error handling
25. **Navigation Integration**: ✅ Profile content embedded in bottom navigation for seamless UX

### Next Steps
1. **Property Search**: Implement property browsing and search functionality for tenants
2. **Room Discovery**: Create detailed room viewing with pricing and availability
3. **Subscription System**: Implement room subscription and rental agreement features
4. **Payment Tracking**: Build payment history and rent payment tracking system
5. **Search Filters**: Implement cultural/professional compatibility and location filters
6. **Database Integration**: Connect property screens to Supabase database operations
7. **Additional Services**: Create services for buildings, rooms, subscriptions, and payments
8. **Image Upload Integration**: Implement photo upload functionality for profile and documents
9. **Notification System**: Add push notifications for rent reminders and updates

This project represents a comprehensive **tenant-focused rent searching platform** tailored for the Indian market with cultural considerations and modern mobile app best practices. The app helps tenants find suitable rental properties, manage their rental subscriptions, and track their rent payments efficiently.