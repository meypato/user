# Meypato - Rent Management Mobile App

Flutter-based tenant-focused rent management platform for **Arunachal Pradesh** with APST (Scheduled Tribe) compatibility filtering and subscription management.

## Tech Stack
**Frontend**: Flutter + Provider + GoRouter + Material Design
**Backend**: Supabase (PostgreSQL + Auth + Storage + Realtime)
**Key Features**: Property discovery, subscription management, cultural compatibility, document management

## Project Structure

```
meypato/
├── android/                           # Android-specific files
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── kotlin/com/meypato/app/MainActivity.kt
│   │   │   └── AndroidManifest.xml
│   │   └── build.gradle.kts
│   └── gradle/
├── ios/                               # iOS-specific files
│   ├── Runner/
│   │   ├── Info.plist                 # Contains Google OAuth setup
│   │   └── AppDelegate.swift
│   └── Runner.xcodeproj/
├── web/                               # Web-specific files
├── lib/                               # Main Flutter application code
│   ├── common/                        # Shared utilities and routing
│   │   └── router.dart                # GoRouter configuration
│   ├── configs/                       # App configuration files
│   │   ├── supabase_config.dart       # Supabase connection setup
│   │   └── bunny_config.dart          # Bunny.net CDN storage configuration
│   ├── constants/                     # App-wide constants (placeholder directory)
│   ├── models/                        # Data models and entities
│   │   ├── building.dart              # Building/Property model with featured/popular fields
│   │   ├── contact.dart               # Contact information model for support and social media
│   │   ├── enums.dart                 # All enums (UserRole, APST, FeaturedType, etc.)
│   │   ├── favorite.dart              # User favorites models for rooms and buildings
│   │   ├── models.dart                # Barrel export file
│   │   ├── payment.dart               # Payment/Transaction model
│   │   ├── profile.dart               # User profile model
│   │   ├── reference_models.dart      # Location models (State, City, etc.)
│   │   ├── review.dart                # Review/Feedback model
│   │   ├── room.dart                  # Room/Rental unit model with featured/popular fields
│   │   ├── room_detail.dart           # Comprehensive room detail model with nested data and building location
│   │   └── subscription.dart          # Tenancy/Subscription model
│   ├── screens/                       # UI screens by feature
│   │   ├── splash/                     # App launch screens
│   │   │   └── splash_screen.dart     # Animated splash screen with auto-navigation
│   │   ├── onboarding/                 # User onboarding screens
│   │   │   ├── onboarding_screen.dart  # Main onboarding container with PageView
│   │   │   ├── onboarding_page.dart    # Reusable individual page widget
│   │   │   └── onboarding_content.dart # Content data model for 3 pages
│   │   ├── auth/                      # Authentication screens
│   │   │   ├── login_screen.dart      # Login with email + Google
│   │   │   └── register_screen.dart   # User registration
│   │   ├── home/                      # Main app screens
│   │   │   └── home_screen.dart       # Search/welcome screen with drawer + bottom nav
│   │   ├── rent/                      # Property rental screens (Rooms)
│   │   │   ├── rent_screen.dart       # Room listings with drawer + bottom nav
│   │   │   └── rent_detail_screen.dart # Detailed room view with photo gallery, building navigation, and map integration
│   │   ├── building/                  # Building screens
│   │   │   ├── building_screen.dart   # Building listings with drawer + bottom nav
│   │   │   ├── building_detail_screen.dart # Enhanced building detail view with full-width location section
│   │   │   └── building_room_detail_screen.dart # Room detail view accessed from building context
│   │   ├── booking/                   # Subscription booking screens
│   │   │   ├── booking_confirm_screen.dart # Booking confirmation with payment calculations
│   │   │   └── booking_success_screen.dart # Booking success with retry mechanism
│   │   ├── favorites/                 # Favorites screens
│   │   │   └── favorites_screen.dart  # Functional favorites with tabbed interface for rooms and buildings
│   │   ├── location/                  # Location screens
│   │   │   └── location_picker_screen.dart # Full-page city selection with search
│   │   ├── profile/                   # User profile screens
│   │   │   ├── profile_screen.dart    # Profile overview with drawer + bottom nav
│   │   │   ├── profile_edit_screen.dart # Profile editing with photo/document upload
│   │   │   ├── profile_view_screen.dart # Profile detail view with document viewer
│   │   │   └── profile_complete_screen.dart # Profile completion with step-by-step wizard
│   │   ├── room/                      # Additional room screens (placeholder directory)
│   │   ├── settings/                  # Settings screens
│   │   │   └── settings_screen.dart   # App preferences
│   │   └── contact/                   # Contact and support screens
│   │       └── contact_screen.dart    # Contact information with social media integration
│   ├── services/                      # Business logic and API services
│   │   ├── auth_service.dart          # Email/password authentication
│   │   ├── booking_service.dart       # Complete booking flow orchestration with transaction management
│   │   ├── building_filter_service.dart # Building filtering and search operations
│   │   ├── building_service.dart      # Building data operations and management
│   │   ├── bunny_storage_service.dart # Core Bunny.net CDN file upload/delete operations
│   │   ├── city_service.dart          # City/location database operations
│   │   ├── contact_service.dart       # Contact information retrieval from Supabase database
│   │   ├── favorites_service.dart     # Complete favorites CRUD operations with batch support
│   │   ├── featured_service.dart      # Featured/popular listing management with priority-based queries
│   │   ├── filter_service.dart        # Room filtering and search operations
│   │   ├── google_auth_service.dart   # Google Sign-In integration
│   │   ├── location_service.dart      # Location and geographic data services
│   │   ├── onboarding_service.dart    # First-time user onboarding tracking with SharedPreferences
│   │   ├── payment_service.dart       # Payment calculations with admin-style month-based logic
│   │   ├── profile_completion_service.dart # Profile completion tracking and validation
│   │   ├── profile_document_service.dart # Legal document upload/management with validation
│   │   ├── profile_photo_service.dart # Profile photo upload with compression and validation
│   │   ├── profile_service.dart       # Profile CRUD operations with file upload integration
│   │   ├── room_service.dart          # Room/rental data operations with search filters and building location data
│   │   └── subscription_service.dart  # Subscription/tenancy CRUD operations with validation
│   ├── providers/                     # State management providers
│   │   ├── booking_provider.dart      # Booking flow state management with month selection
│   │   ├── favorites_provider.dart    # Favorites state management with real-time sync
│   │   └── profile_provider.dart      # Profile state with Provider
│   ├── themes/                        # App theming and styling
│   │   ├── app_colour.dart            # Color palette (light/dark)
│   │   └── theme_provider.dart        # Theme state management
│   ├── widgets/                       # Reusable UI components
│   │   ├── app_drawer.dart            # Beautiful drawer navigation with profile integration
│   │   ├── bottom_navigation.dart     # Compact floating bottom navigation with routing
│   │   ├── building_filter_modal.dart # Building filter system with location and type filtering
│   │   ├── building_item_card.dart    # Building card with photo and property details
│   │   ├── compact_room_card.dart     # Compact room cards for building detail page
│   │   ├── favorite_icon_button.dart  # Reusable favorite heart icons with variants for different contexts
│   │   ├── filter_modal.dart          # Room filter system with beautiful gradient design
│   │   ├── location_section.dart      # Database-connected user location display with city picker
│   │   ├── map_widget.dart            # Interactive Google Maps WebView widget with popup functionality
│   │   ├── navigation_wrapper.dart    # Navigation wrapper component for consistent routing
│   │   ├── payment_calculation_card.dart # Month selection widget for booking payments with condition badges
│   │   ├── profile_completion_banner.dart # Profile completion encouragement banner for homepage/profile
│   │   ├── profile_required_banner.dart # Profile completion required banner for rent/building pages
│   │   ├── profile_step_indicator.dart # Step progress indicator for profile completion wizard
│   │   ├── rent_item_card.dart        # Horizontal room card with photo and details
│   │   ├── search_section.dart        # Dynamic search form with real room types, occupancy, and price data
│   │   └── theme_toggle_button.dart   # Theme switching widgets
│   └── main.dart                      # App entry point
├── assets/                            # Static assets
│   └── icons/
│       └── logo.png                   # App logo
├── docs/                              # Documentation
│   └── databases/                     # Database documentation
│       ├── database.md                # Complete schema reference
│       ├── profile.sql                # User profiles table
│       ├── buildings.sql              # Properties table with featured/popular fields
│       ├── rooms.sql                  # Rental units table with featured/popular fields
│       ├── subscriptions.sql          # Rental agreements table
│       ├── payments.sql               # Payment tracking table
│       ├── reviews.sql                # Rating system table
│       ├── tribes.sql                 # APST tribal categories
│       ├── professions.sql            # Professional categories
│       ├── states.sql                 # State reference data
│       ├── cities.sql                 # City reference data
│       ├── amenities.sql              # Property amenities
│       ├── room_amenities.sql         # Room-amenity mapping
│       ├── building_tribe_exceptions.sql     # Tribal access control
│       ├── building_profession_exceptions.sql # Professional access control
│       ├── user_favorite_rooms.sql    # User favorites for rooms with RLS
│       ├── user_favorite_buildings.sql # User favorites for buildings with RLS
│       └── contacts.sql               # Contact information table for support team details
├── pubspec.yaml                       # Dependencies and configuration
├── CLAUDE.md                          # Project documentation (this file)
├── CREDENTIALS.md                     # OAuth credentials (gitignored)
└── README.md                          # Project overview
```

## Business Logic
- **Multi-role system**: Tenant, Owner, Agent, Admin with APST classification
- **Property hierarchy**: Buildings → Rooms → Subscriptions → Payments/Reviews
- **Cultural filtering**: Tribe/profession-based access control
- **Subscription management**: One active subscription per room, monthly payments
- **Verified reviews**: Linked to actual tenancies

## Navigation
**Architecture**: GoRouter with clean screen separation, shared AppDrawer + floating bottom navigation

**Key Routes**:
- Auth: `/splash` → `/onboarding` → `/login`
- Main: `/home`, `/rent`, `/building`, `/favorites`, `/profile`
- Booking: `/booking/confirm` → `/booking/success/:subscriptionId`
- Building: `/building/:buildingId/room/:roomId`

## UI/UX System
- **Modern floating navigation** (60px height, blue theme, adaptive)
- **Scaffold pattern**: `extendBody: true` with manual status bar padding
- **Material Design 3** with light/dark themes
- **Component library**: Reusable cards, modals, forms, navigation
- **Advanced features**: Map integration, favorites, search/filtering, file upload
- **Profile completion** wizard with step indicators
- **Onboarding** 3-page walkthrough for APST introduction

## Development Guidelines
- **SYNTAX FIRST**: Always run `flutter analyze` after ANY code edit
- **Small incremental changes**: Verify each step before proceeding
- **User handles testing**: Do NOT run flutter commands

## Project Status

### ✅ Completed Features

**Core Foundation**
- Flutter + Supabase setup with GoRouter navigation
- Authentication (email/password + Google OAuth with auto profile creation)
- Modern UI with floating navigation, light/dark themes, Material Design 3

**Screens & Navigation**
- Complete screen set: Splash, Onboarding, Auth, Home, Rent, Building, Favorites, Profile, Settings, Contact
- Booking flow: BookingConfirm → BookingSuccess with retry mechanism
- Building detail screens with room navigation

**Data & Services**
- 10 models matching database schema
- 20 service classes covering all business logic
- 3 providers for state management (Profile, Favorites, Booking)

**Key Features**
- **Property Discovery**: Advanced search/filtering with dynamic data
- **Favorites System**: Complete CRUD with real-time sync
- **Profile Management**: Photo upload, document management, completion wizard
- **Map Integration**: Google Maps with WebView popup functionality
- **Featured/Popular System**: Badge system with priority sorting
- **Contact System**: Social media integration with smart URL launching

**Subscription & Payment System**
- Complete booking flow with month-based payment calculations
- Admin-style payment logic with pro-rated amounts and late fees (0.8% daily)
- PaymentCalculationCard with condition badges and visual indicators
- Transaction management with rollback and retry mechanisms
- Testing-ready setup with disabled verification requirements

### ⏳ Next Steps
1. **Payment Gateway Integration**: Razorpay integration for actual payment processing
2. **APST Compatibility Filtering**: Implement tribal and professional access control for buildings and rooms
3. **Reviews**: Rating system for buildings based on completed tenancies
4. **Property Image Management**: Photo management for building/room listings (owner/agent features)
5. **Notification System**: Push notifications and in-app alerts for bookings and payments
6. **Enhanced Search**: Advanced filtering with APST/profession compatibility
7. **Rental Agreements**: Digital document generation and signing for subscriptions

---

*Meypato is a comprehensive tenant-focused rent management platform specifically designed for Arunachal Pradesh with APST tribal compatibility and modern Flutter architecture.*