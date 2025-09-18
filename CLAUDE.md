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
│   │   ├── room_detail.dart           # Comprehensive room detail model with nested data
│   │   └── subscription.dart          # Tenancy/Subscription model
│   ├── screens/                       # UI screens by feature
│   │   ├── auth/                      # Authentication screens
│   │   │   ├── login_screen.dart      # Login with email + Google
│   │   │   └── register_screen.dart   # User registration
│   │   ├── home/                      # Main app screens
│   │   │   └── home_screen.dart       # Search/welcome screen with drawer + bottom nav
│   │   ├── rent/                      # Property rental screens (Rooms)
│   │   │   ├── rent_screen.dart       # Room listings with drawer + bottom nav
│   │   │   └── rent_detail_screen.dart # Detailed room view with photo gallery
│   │   ├── building/                  # Building screens
│   │   │   └── building_screen.dart   # Building listings with drawer + bottom nav
│   │   ├── favorites/                 # Favorites screens
│   │   │   └── favorites_screen.dart  # Favorites overview with drawer + bottom nav
│   │   ├── location/                  # Location screens
│   │   │   └── location_picker_screen.dart # Full-page city selection with search
│   │   ├── profile/                   # User profile screens
│   │   │   ├── profile_screen.dart    # Profile overview with drawer + bottom nav
│   │   │   └── profile_detail_screen.dart # Profile editing
│   │   └── settings/                  # Settings screens
│   │       └── settings_screen.dart   # App preferences
│   ├── services/                      # Business logic and API services
│   │   ├── auth_service.dart          # Email/password authentication
│   │   ├── building_filter_service.dart # Building filtering and search operations
│   │   ├── city_service.dart          # City/location database operations
│   │   ├── filter_service.dart        # Room filtering and search operations
│   │   ├── google_auth_service.dart   # Google Sign-In integration
│   │   ├── profile_service.dart       # Profile CRUD operations
│   │   └── room_service.dart          # Room/rental data operations with search filters
│   ├── providers/                     # State management providers
│   │   └── profile_provider.dart      # Profile state with Provider
│   ├── themes/                        # App theming and styling
│   │   ├── app_colour.dart            # Color palette (light/dark)
│   │   └── theme_provider.dart        # Theme state management
│   ├── widgets/                       # Reusable UI components
│   │   ├── app_drawer.dart            # Beautiful drawer navigation with profile integration
│   │   ├── bottom_navigation.dart     # Compact floating bottom navigation with routing
│   │   ├── building_filter_modal.dart # Building filter system with location and type filtering
│   │   ├── building_item_card.dart    # Building card with photo and property details
│   │   ├── filter_modal.dart          # Room filter system with beautiful gradient design
│   │   ├── location_section.dart      # Database-connected user location display with city picker
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
├── Rooms (index 1) → /rent (RentScreen) → /rent/:rentId (RentDetailScreen)
├── Building (index 2) → /building (BuildingScreen)
├── Favorites (index 3) → /favorites (FavoritesScreen)
└── Profile (index 4) → /profile (ProfileScreen)

Drawer Navigation:
├── Home → /home
├── Rooms → /rent
├── Building → /building
├── Profile → /profile
├── Settings → /settings
└── Secondary items (Favorites → /favorites, Notifications, Help)

Nested Routes:
└── /rent (RentScreen)
    └── /:rentId (RentDetailScreen) # Proper parent-child relationship
```

### **Architecture Benefits**
- **Single Responsibility**: Screens handle content, widgets handle navigation
- **Easy Maintenance**: Add new screens without touching navigation logic
- **Consistent UX**: Same navigation experience across all screens
- **Clean Code**: No duplicate navigation logic or mixed concerns

---

## UI/UX Design System

### **Modern Floating Navigation**
- **Compact Design**: 60px height (reduced from 85px) with pill-shaped floating design
- **Smart Layout**: 20px margins create floating effect above content
- **Simplified Icons**: Removed active indicator dots for cleaner appearance
- **Theme Responsive**: Adapts colors automatically for light/dark modes
- **Content Flow**: Uses `extendBody: true` to allow content behind transparent navigation

### **CRITICAL: Bottom Navigation Screen Layout Pattern**
⚠️ **For ALL screens with bottom navigation, use this exact pattern to avoid visual cutouts:**

```dart
Scaffold(
  extendBody: true,
  body: SingleChildScrollView(  // ❌ NO SafeArea wrapper here!
    child: Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top), // Status bar padding
        // ... your content ...
        const SizedBox(height: 100), // Bottom navigation spacing
      ],
    ),
  ),
  bottomNavigationBar: const CustomBottomNavigation(...),
)
```

**❌ WRONG Pattern (creates cutouts):**
```dart
body: SafeArea(  // This conflicts with extendBody: true
  child: SingleScrollView(
    padding: EdgeInsets.only(bottom: 100), // Root padding causes issues
    child: Column(...)
  )
)
```

**✅ CORRECT Pattern:**
- Remove `SafeArea` wrapper from body
- Use manual status bar padding: `SizedBox(height: MediaQuery.of(context).padding.top)`
- Add bottom spacing inside content: `SizedBox(height: 100)`
- Content flows naturally behind floating navigation

**✅ Successfully Applied To:**
- ProfileScreen, BuildingScreen, FavoritesScreen (all cutout-free!)
- RentScreen uses similar pattern with ListView padding

### **Rent Screen Optimization**
- **Horizontal Room Cards**: Large 140x140px left-side photos with details on right
- **Compact Layout**: Removed SafeArea constraints for full-screen content flow
- **Smart Scrolling**: 100px bottom padding allows scrolling past floating navigation
- **Modern Card Design**: Subtle shadows, green price chips, optimized spacing
- **Touch-Friendly**: Larger tap targets and readable text sizes

### **App Bar Consistency**
- **Theme-Aware Colors**: Proper text/icon colors for light mode visibility
- **Consistent Styling**: 20px font size, 600 weight across all screens
- **Clean Design**: Zero elevation with surface-matching backgrounds

### **Performance Optimizations**
- **Efficient Layouts**: Removed unnecessary containers and SafeArea constraints
- **Smooth Animations**: 200ms transitions for navigation state changes
- **Memory Efficient**: Optimized widget rebuilds and state management

### **Modern Homepage Design**
- **Unified Interface**: Single white container with logo, location, and search form
- **Responsive Layout**: Centered design with 400px max width and scrollable fallback
- **Theme Integration**: Complete light/dark mode support with proper color schemes
- **Compact Components**: Optimized spacing and text sizes for better readability
- **Background Integration**: Immersive background image with transparent app bar
- **Modular Architecture**: Separated LocationSection and SearchSection widgets
- **Database Integration**: Real-time data from Supabase for all search components

### **Advanced Search System**
- **Dynamic Room Types**: Fetches actual room types from database (Single, Double, Triple, Studio) using proper enum conversion
- **Smart Occupancy Filter**: Real occupancy ranges based on `maximum_occupancy` field (1 Person, 2 People, 3 People, 4+ People)
- **Dynamic Price Range**: Min/max values from actual room inventory with ₹500 step divisions
- **Location Integration**: User's current city from `profiles.city_id` with database-connected city picker
- **Performance Optimization**: Indexed database queries for fast search option loading
- **Loading States**: Smooth loading indicators while fetching search options from Supabase
- **Error Handling**: Graceful fallbacks if database queries fail
- **Enum-based Type Safety**: RoomType enum ensures consistent display across SearchSection and rent cards

### **Database Service Layer**
- **CityService**: Complete city management with Arunachal Pradesh focus
  - `getArunachalCities()`: Fetches all AP cities for location picker
  - `getCityName(cityId)`: Resolves city names for display
  - `updateUserCity(cityId)`: Updates user profile location
- **Enhanced RoomService**: Advanced room filtering and search capabilities
  - `getAvailableRoomTypes()`: Dynamic room type dropdown population
  - `getAvailableOccupancyRanges()`: Smart occupancy filtering based on real data
  - `getAvailablePriceRange()`: Min/max pricing from actual inventory
  - All methods filter by `availability_status = 'available'` for accurate results

### **Enhanced Bottom Navigation**
- **Dark Mode Optimization**: Improved visibility with better color contrast
- **Theme-Aware Design**: Dynamic blue color scheme for both light and dark modes
- **Clean Visual Hierarchy**: Clear distinction between active and inactive states
- **Improved Accessibility**: Enhanced text and icon visibility in all themes

### **Advanced Filter Modal System**
- **Modular Architecture**: Separated filter modal into reusable widget (`filter_modal.dart`)
- **Beautiful Location Section**: Green gradient container with user location and "Any Location" options
- **Compact Grid Layout**: Vertical chip design for Room Type and Occupancy filters
- **Premium Price Range**: Enhanced slider with gradient background and proper spacing
- **Enhanced Buttons**: Reset button with error theming, Apply button with gradient and shadow effects
- **Smart Parameter Handling**: Converts between UI display strings and database filter parameters
- **Overflow Prevention**: Proper spacing and sizing to prevent rendering issues

### **Profile Screen Redesign**
- **Compact Header Layout**: Horizontal profile card with 70px photo, name, email, and status chip
- **2x2 Grid Menu System**: Efficient space usage with color-coded menu items
- **Gradient Card Design**: Beautiful containers with subtle gradients and color-coordinated borders
- **Space Optimization**: Reduced height from 85px to 80px cards with proper padding
- **Icon Enhancement**: 36x36px icon containers with gradient fills and themed colors
- **Color System**: Each menu item has unique color identity (Red, Blue, Yellow, Green, Purple)

### **Search Parameter Integration**
- **Query String Navigation**: Clean URL parameter passing from homepage to rent screen
- **Smart Parameter Conversion**: Converts UI selections to database filter parameters
- **Seamless UX**: Instant filtered results on rent screen arrival
- **Shareable URLs**: Bookmarkable search results with query parameters
- **Filter Integration**: Works seamlessly with existing filter modal system

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
- **UI/Navigation**: Beautiful drawer + compact floating blue bottom navigation + light/dark themes
- **Profile Management**: Complete CRUD with state management
- **Data Models**: 10 models matching database schema (including RoomDetail)
- **Core Screens**: Login, Register, Home, Rooms (formerly Rent), Building, Favorites, Profile, Settings
- **Room Detail Screen**: Complete room detail view with photo gallery, amenities, owner info
- **Building Screen**: Complete building listings with grid layout, search, and advanced filtering
- **Favorites Screen**: Mock implementation with empty state and feature preview
- **Navigation Architecture**: Nested GoRouter structure with proper parent-child relationships
- **Modern UI Design**: Blue floating navigation, horizontal room cards, immersive photo headers
- **Theme Integration**: Proper app bar colors, consistent theming across all screens
- **Layout Optimization**: Fixed SafeArea cutout issues for floating navigation screens
- **Data Layer**: Working Supabase nested queries for building/city information
- **Homepage Design**: Complete modern homepage with unified search interface
- **Location System**: Database-connected user location with full-page city picker
- **Advanced Search**: Dynamic search form with real room types, occupancy, and price data
- **Widget Architecture**: Modular LocationSection and SearchSection components
- **Database Integration**: Real-time data fetching for all search parameters
- **Theme-Aware Components**: Full light/dark mode support across all UI elements
- **Enhanced Navigation**: Improved bottom navigation visibility and theming
- **Room Type System**: Complete RoomType enum (Single, Double, Triple, Studio) with proper display consistency across all UI components
- **Search Integration**: Complete homepage to rent screen parameter passing with query string navigation
- **Room Filter System**: Beautiful, modular filter system with gradient designs and enhanced UX for room filtering
- **Building Filter System**: Complete building filtering with location, type, and distance-based filtering
- **BuildingFilterService**: Advanced database service for building type, city, and proximity filtering
- **Building Filter Modal**: Gradient-designed filter modal with location sections and building type selection
- **Profile Screen Enhancement**: Compact, beautiful profile design with 2x2 grid layout and gradient cards
- **Profile Photo Display**: Fixed profile photo rendering in detail screen with proper loading states

### ⏳ Next Steps
1. **APST Compatibility Filtering**: Implement tribal and professional access control for buildings and rooms
2. **Favorites Functionality**: Actual save/remove favorites with data persistence
3. **Subscription System**: Rental agreements and payments
4. **Reviews**: Rating system for buildings
5. **Image Upload**: Photo management for properties/profiles
6. **Notification System**: Push notifications and in-app alerts

---

*Meypato is a comprehensive tenant-focused rent management platform specifically designed for Arunachal Pradesh with APST tribal compatibility and modern Flutter architecture.*