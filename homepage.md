# Meypato Homepage Redesign Plan

## Overview
Complete redesign of the home screen to create a **tenant-focused** landing page with proper app introduction, location display, rent search functionality, and featured room recommendations.

---

## 🎯 Target Layout Structure

```
┌─────────────────────────────────────┐
│ ≡  Home                        🔔   │ ← AppBar (existing)
├─────────────────────────────────────┤
│                                     │
│ 🏠 Welcome to Meypato               │ ← Section 1: Welcome
│ Your trusted rent management        │
│ platform for Arunachal Pradesh     │
│ with APST compatibility             │
│                                     │
├─────────────────────────────────────┤
│ 📍 Your Location                    │ ← Section 2: Location
│ 📍 Itanagar, Arunachal Pradesh     │
│ [Change]                            │
│                                     │
├─────────────────────────────────────┤
│ 🔍 Find Your Perfect Room          │ ← Section 3: Search Form
│                                     │
│ [Room Type: Single ▼]              │
│ [Price: ₹5,000 - ₹15,000]          │
│ [City: Itanagar ▼]                 │
│                                     │
│ [🔍 Search Rooms] ──────────────────┼→ Navigate to /rent
│                                     │
├─────────────────────────────────────┤
│ ⭐ Featured Rooms                   │ ← Section 4: Featured Rooms
│                                     │
│ [Room Card] [Room Card] [Room Card] │   (Horizontal scroll)
│                                     │
│ [View All Rooms] ───────────────────┼→ Navigate to /rent
│                                     │
├─────────────────────────────────────┤
│               { 100px }             │ ← Bottom nav spacing
└─────────────────────────────────────┘
```

---

## 📱 Section Breakdown

### **Section 1: Welcome & Introduction**
**Purpose**: Introduce Meypato and its purpose

**Content**:
- App logo/icon (🏠)
- "Welcome to Meypato" title
- Brief description: "Your trusted rent management platform for Arunachal Pradesh"
- Subtitle: "Find APST-compatible housing with cultural sensitivity"

**Design**:
```dart
Container(
  padding: EdgeInsets.all(20),
  child: Column(
    children: [
      // App Icon
      Container(
        width: 80, height: 80,
        decoration: BoxDecoration(
          color: primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(40)
        ),
        child: Icon(Icons.home, size: 40, color: primaryBlue)
      ),

      // Title
      Text('Welcome to Meypato', style: heading1),

      // Description
      Text('Your trusted rent management platform for Arunachal Pradesh with APST compatibility',
           style: body, textAlign: center)
    ]
  )
)
```

---

### **Section 2: User Location Display**
**Purpose**: Show user's current selected city with option to change

**Data Source**:
- Profile service (user's selected city)
- Default: "Itanagar, Arunachal Pradesh"

**Content**:
- Location icon
- "Your Location" label
- Current city display
- "Change" button

**Design**:
```dart
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: primaryBlue.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: primaryBlue.withOpacity(0.2))
  ),
  child: Row(
    children: [
      Icon(Icons.location_on, color: primaryBlue),
      Expanded(
        child: Column(
          crossAxisAlignment: start,
          children: [
            Text('Your Location', style: caption),
            Text('Itanagar, Arunachal Pradesh', style: subtitle)
          ]
        )
      ),
      TextButton(
        onPressed: _showLocationPicker,
        child: Text('Change', color: primaryBlue)
      )
    ]
  )
)
```

---

### **Section 3: Rent Search Form**
**Purpose**: Quick search form that navigates to rent_screen.dart

**Based on Database Schema** (`rooms` table):
- `room_type`: Single, Double, Triple, Studio
- `fee`: ₹1,000 - ₹25,000 range
- Location: Arunachal Pradesh cities

**Form Fields**:
1. **Room Type Dropdown**
   ```dart
   DropdownButton<String>(
     value: _selectedRoomType,
     items: ['Any', 'Single', 'Double', 'Triple', 'Studio']
   )
   ```

2. **Price Range Slider**
   ```dart
   RangeSlider(
     values: RangeValues(_minPrice, _maxPrice),
     min: 1000, max: 25000,
     divisions: 24
   )
   ```

3. **City Selection**
   ```dart
   DropdownButton<String>(
     value: _selectedCity,
     items: ['Any', 'Itanagar', 'Naharlagun', 'Pasighat', 'Tawang']
   )
   ```

4. **Search Button**
   ```dart
   ElevatedButton(
     onPressed: () => context.go('/rent'),
     child: Row(
       children: [
         Icon(Icons.search),
         Text('Search Rooms')
       ]
     )
   )
   ```

**Navigation**: Direct to `/rent` screen with optional filter parameters

---

### **Section 4: Featured Rooms** ⭐
**Purpose**: Show 3-4 highlighted available rooms to encourage exploration

**Data Source**:
- `RoomService.getAvailableRooms(limit: 4, featured: true)`
- Display recently added or popular rooms
- Fallback to any available rooms

**Content**:
- "Featured Rooms" section title
- Horizontal scrollable room cards (similar to rent_item_card.dart)
- "View All Rooms" button

**Room Card Design** (Compact version):
```dart
Container(
  width: 280,
  margin: EdgeInsets.only(right: 16),
  decoration: BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [lightShadow]
  ),
  child: Column(
    children: [
      // Room Photo
      ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(room.photos[0], height: 120, fit: cover)
      ),

      // Room Details
      Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: start,
          children: [
            Text(room.name, style: subtitle, maxLines: 1),
            Text('₹${room.fee}/month', style: priceStyle),
            Text('${room.building.city.name}', style: caption),

            // APST Badge (if compatible)
            if (room.building.isAPSTCompatible)
              Container(
                padding: EdgeInsets.symmetric(h: 8, v: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6)
                ),
                child: Text('APST Welcome', style: greenCaption)
              )
          ]
        )
      )
    ]
  )
)
```

**Navigation**: Tap on card → Navigate to `/rent/:roomId` (room detail screen)

---

## 🔧 Implementation Plan

### **Phase 1: Layout Structure**
1. Replace current `_buildSearchScreen()` with new sectioned layout
2. Implement proper scrolling with `SingleChildScrollView`
3. Add section spacing and proper padding
4. Ensure bottom navigation compatibility (100px bottom spacing)

### **Phase 2: Welcome Section**
1. Create `_buildWelcomeSection()` widget
2. Add Meypato branding and description
3. Include APST compatibility messaging
4. Style with app theme colors

### **Phase 3: Location Section**
1. Create `_buildLocationSection()` widget
2. Add location display with user's city
3. Implement "Change Location" functionality
4. Store location preference in user profile

### **Phase 4: Search Form Section**
1. Create `_buildSearchFormSection()` widget
2. Implement room type dropdown
3. Add price range slider
4. Add city selection dropdown
5. Create search button with navigation to `/rent`
6. Optional: Pass search parameters to rent screen

### **Phase 5: Featured Rooms Section**
1. Create `_buildFeaturedRoomsSection()` widget
2. Integrate with `RoomService.getAvailableRooms()`
3. Create compact room cards (reuse/modify `RentItemCard`)
4. Implement horizontal scrolling
5. Add "View All Rooms" button
6. Handle navigation to room details

### **Phase 6: Testing & Refinement**
1. Test all navigation flows
2. Verify responsive design
3. Run `flutter analyze`
4. Test on different screen sizes
5. Ensure proper theme adaptation (light/dark)

---

## 🎨 Design Specifications

### **Colors** (from AppColors)
- Primary: `AppColors.primaryBlue`
- Background: `theme.colorScheme.surface`
- Cards: `theme.colorScheme.surface` with shadows
- Text: `AppColors.textPrimary` / `AppColors.textPrimaryDark`
- Accent: Green for APST badges, price highlights

### **Typography**
- Section titles: 18px, FontWeight.w600
- Card titles: 16px, FontWeight.w500
- Body text: 14px, FontWeight.w400
- Captions: 12px, FontWeight.w400

### **Spacing**
- Section padding: 20px horizontal, 16px vertical
- Card margins: 16px between cards
- Internal spacing: 8px, 12px, 16px increments

### **Card Shadows**
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 10,
  offset: Offset(0, 2)
)
```

---

## 🚀 Navigation Flow

```
HomePage
├── Welcome Section (static)
├── Location Section → Location Picker Modal
├── Search Form → context.go('/rent')
└── Featured Rooms
    ├── Room Card → context.go('/rent/:roomId')
    └── View All → context.go('/rent')
```

---

## 📊 Data Requirements

### **APIs Needed**:
1. `RoomService.getAvailableRooms(limit: 4)` - Featured rooms
2. `ProfileService.getUserLocation()` - User's city
3. `LocationService.getCities()` - City dropdown options

### **State Management**:
- Search form state (room type, price range, city)
- User location state
- Featured rooms loading state
- Error handling for API calls

---

## ✅ Success Criteria

1. **Functional**: All sections work and navigate correctly
2. **Design**: Consistent with app theme and modern UI principles
3. **Performance**: Smooth scrolling and fast loading
4. **Responsive**: Works on different screen sizes
5. **Accessible**: Proper contrast and touch targets
6. **Cultural**: APST compatibility clearly communicated

---

*This homepage will serve as the main entry point for tenants to discover Meypato's features and quickly find suitable housing options with cultural compatibility.*