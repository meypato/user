# Meypato - Rent Management Mobile App

## Project Overview
**Meypato** is a Flutter-based tenant-focused rent management platform for **Arunachal Pradesh**, India. The app helps tenants find rental properties with APST (Arunachal Pradesh Scheduled Tribe) compatibility filtering and manage their rental subscriptions.

## Target Market
- **Primary Users**: Tenants seeking rental properties in Arunachal Pradesh
- **Geographic Focus**: Arunachal Pradesh with APST tribal considerations
- **Platform Type**: Tenant-focused (not property listing platform)

## Core Features
- **Property Discovery**: Search buildings and rooms with APST/profession filtering
- **Subscription Management**: Manage rental agreements and monthly payments
- **Cultural Compatibility**: Tribe and profession-based access control
- **Document Management**: Digital verification and rental agreements

---

## Technical Stack

**Frontend**: Flutter (Dart) + Provider + GoRouter + Material Design  
**Backend**: Supabase (PostgreSQL + Auth + Storage + Realtime)  
**Authentication**: Email/Password + Google Sign-In  

### Key Dependencies
```yaml
supabase_flutter: ^2.10.0    # Backend integration
go_router: ^16.2.0           # Navigation
provider: ^6.1.5+1           # State management
google_sign_in: ^6.3.0       # Google OAuth
shared_preferences: ^2.5.3   # Local storage
geolocator: ^14.0.2          # Location services
image_picker: ^1.2.0         # Photo uploads
```

---

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
│   │   └── supabase_config.dart       # Supabase connection setup
│   ├── models/                        # Data models and entities
│   │   ├── building.dart              # Building/Property model
│   │   ├── enums.dart                 # All enums (UserRole, APST, etc.)
│   │   ├── models.dart                # Barrel export file
│   │   ├── payment.dart               # Payment/Transaction model
│   │   ├── profile.dart               # User profile model
│   │   ├── reference_models.dart      # Location models (State, City, etc.)
│   │   ├── review.dart                # Review/Feedback model
│   │   ├── room.dart                  # Room/Rental unit model
│   │   └── subscription.dart          # Tenancy/Subscription model
│   ├── screens/                       # UI screens by feature
│   │   ├── auth/                      # Authentication screens
│   │   │   ├── login_screen.dart      # Login with email + Google
│   │   │   └── register_screen.dart   # User registration
│   │   ├── home/                      # Main app screens
│   │   │   └── home_screen.dart       # Search/welcome screen with drawer + bottom nav
│   │   ├── rent/                      # Property rental screens
│   │   │   └── rent_screen.dart       # Room listings with drawer + bottom nav
│   │   ├── profile/                   # User profile screens
│   │   │   ├── profile_screen.dart    # Profile overview with drawer + bottom nav
│   │   │   └── profile_detail_screen.dart # Profile editing
│   │   └── settings/                  # Settings screens
│   │       └── settings_screen.dart   # App preferences
│   ├── services/                      # Business logic and API services
│   │   ├── auth_service.dart          # Email/password authentication
│   │   ├── google_auth_service.dart   # Google Sign-In integration
│   │   ├── profile_service.dart       # Profile CRUD operations
│   │   └── room_service.dart          # Room/rental data operations
│   ├── providers/                     # State management providers
│   │   └── profile_provider.dart      # Profile state with Provider
│   ├── themes/                        # App theming and styling
│   │   ├── app_colour.dart            # Color palette (light/dark)
│   │   └── theme_provider.dart        # Theme state management
│   ├── widgets/                       # Reusable UI components
│   │   ├── app_drawer.dart            # Beautiful drawer navigation with profile integration
│   │   ├── bottom_navigation.dart     # Custom bottom navigation with routing
│   │   └── theme_toggle_button.dart   # Theme switching widgets
│   └── main.dart                      # App entry point
├── assets/                            # Static assets
│   └── icons/
│       └── logo.png                   # App logo
├── docs/                              # Documentation
│   └── databases/                     # Database documentation
│       ├── database.md                # Complete schema reference
│       ├── profile.sql                # User profiles table
│       ├── buildings.sql              # Properties table
│       ├── rooms.sql                  # Rental units table
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
│       └── building_profession_exceptions.sql # Professional access control
├── pubspec.yaml                       # Dependencies and configuration
├── CLAUDE.md                          # Project documentation (this file)
├── CREDENTIALS.md                     # OAuth credentials (gitignored)
└── README.md                          # Project overview
```

## Database Schema
**See**: `docs/databases/database.md` for complete documentation

**Core Entities**: Profiles → Buildings → Rooms → Subscriptions → Payments/Reviews

---

## Business Logic

### User Management
- **Multi-role system**: Tenant, Owner, Agent, Admin
- **APST Classification**: Arunachal Pradesh Scheduled Tribe status
- **3-tier verification**: Document → Police → Profile verification
- **Cultural compatibility**: Tribe/profession-based filtering

### Property System
- **Buildings**: Property listings with photos, amenities, location
- **Rooms**: Individual rental units with pricing and availability
- **Access control**: Exception-based filtering (inclusion by default)
- **Geographic hierarchy**: State → City organization

### Subscription Management  
- **One active subscription per room**: Business rule enforcement
- **Monthly payment tracking**: One payment per month per subscription
- **Rental agreements**: Digital document management
- **Payment history**: Complete transaction audit trail

### Review System
- **Verified reviews**: Linked to actual tenancy subscriptions
- **Rating system**: 1-5 stars with photo support
- **Community feedback**: Helpfulness tracking

---

## Navigation Architecture

### **Clean Screen Separation**
- **HomeScreen**: Pure search/welcome content with drawer + bottom nav
- **RentScreen**: Pure room listings content with drawer + bottom nav  
- **ProfileScreen**: Pure profile management content with drawer + bottom nav
- **No embedded navigation logic**: Each screen focuses solely on content

### **Shared Navigation Components**
- **AppDrawer**: Beautiful sidebar with real profile data, menu items, and theme toggle
- **CustomBottomNavigation**: Smart routing component that handles all tab navigation
- **Self-contained**: Navigation widgets handle their own routing logic

### **Navigation Flow**
```
Bottom Navigation:
├── Home (index 0) → /home (HomeScreen)
├── Rent (index 1) → /rent (RentScreen) 
├── Favorites (index 2) → /home (placeholder)
├── Near Me (index 3) → /home (placeholder)
└── Profile (index 4) → /profile (ProfileScreen)

Drawer Navigation:
├── Home → /home
├── Rent → /rent
├── Profile → /profile
├── Settings → /settings
└── Secondary items (Favorites, Near Me, Notifications, Help)
```

### **Architecture Benefits**
- **Single Responsibility**: Screens handle content, widgets handle navigation
- **Easy Maintenance**: Add new screens without touching navigation logic
- **Consistent UX**: Same navigation experience across all screens
- **Clean Code**: No duplicate navigation logic or mixed concerns

---

## User Flow (Tenants)
1. **Registration** → Profile with APST/profession verification
2. **Discovery** → Search properties with cultural compatibility filtering  
3. **Subscription** → Rent room + digital rental agreement
4. **Payment** → Monthly rent tracking and payment history
5. **Reviews** → Rate buildings based on tenancy experience

## Important Notes
- **Tenant-focused platform** (NOT property listing app)
- **Property management** handled by owners/agents externally
- **Focus**: Subscription management and cultural compatibility

## Development Guidelines

### Critical Rules
- **SYNTAX FIRST**: Always run `flutter analyze` after ANY code edit
- **ZERO TOLERANCE**: Stop development if syntax errors exist
- **Small Edits**: Make incremental changes, verify each step
- **NO FLUTTER COMMANDS**: Do NOT run `flutter run` or similar commands - user will handle testing

### Build Commands (Reference Only)
```bash
flutter analyze                # Code analysis (REQUIRED after edits)
flutter build apk --release    # Android release
flutter build ios --release    # iOS release
```

## Project Status

### ✅ Completed Features
- **Foundation**: Flutter project setup + Supabase integration
- **Authentication**: Email/password + Google Sign-In + auth guards
- **UI/Navigation**: Beautiful drawer + smart bottom navigation + light/dark themes
- **Profile Management**: Complete CRUD with state management
- **Data Models**: 9 models matching database schema
- **Core Screens**: Login, Register, Home, Rent, Profile, Settings
- **Navigation Architecture**: Clean screen separation with shared navigation components

### ⏳ Next Steps
1. **Property Search**: Building/room browsing with APST filtering
2. **Subscription System**: Rental agreements and payments
3. **Reviews**: Rating system for buildings
4. **Image Upload**: Photo management for properties/profiles

---

*Meypato is a comprehensive tenant-focused rent management platform specifically designed for Arunachal Pradesh with APST tribal compatibility and modern Flutter architecture.*