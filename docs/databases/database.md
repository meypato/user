# Meypato Database Schema Documentation

## Overview
Comprehensive database schema for **Meypato** - a tenant-focused rent management platform with cultural compatibility filtering specifically designed for **Arunachal Pradesh**, India. The platform includes APST (Arunachal Pradesh Scheduled Tribe) classification for cultural sensitivity and tribal compatibility.

## Database Architecture

### Core Entities
1. **User Management**: Profiles with verification system
2. **Property Management**: Buildings and Rooms
3. **Rental Operations**: Subscriptions and Payments
4. **Community Features**: Reviews and Ratings
5. **Cultural System**: Tribes, Professions, and Access Control
6. **Location Services**: Hierarchical geography (States → Cities)
7. **Amenities**: Feature management for properties

---

## Table Schemas

### 1. User Management

#### `profiles` - User Profiles
```sql
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY,                                    -- Links to auth.users
  full_name text NOT NULL,
  photo_url text,
  role user_role NOT NULL DEFAULT 'tenant',              -- tenant | owner
  identification_file_url text,                          -- ID document
  police_verification_file_url text,                     -- Police verification
  age integer CHECK (age BETWEEN 18 AND 120),
  sex sex_type,                                          -- male | female | other
  tribe_id uuid REFERENCES tribes(id),                   -- Cultural filtering
  profession_id uuid REFERENCES professions(id),         -- Professional filtering
  apst apst_status,                                      -- Arunachal Pradesh Scheduled Tribe status
  address_line1 text,
  address_line2 text,
  country text NOT NULL DEFAULT 'India',
  state_id uuid NOT NULL REFERENCES states(id),
  city_id uuid NOT NULL REFERENCES cities(id),
  pincode text CHECK (pincode ~ '^[0-9]{6}$'),          -- 6-digit Indian pincode
  phone text CHECK (phone ~ '^[+]?[0-9]{10,15}$'),
  email text UNIQUE CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
  emergency_contact_name text,
  emergency_contact_phone text CHECK (emergency_contact_phone ~ '^[+]?[0-9]{10,15}$'),
  is_verified boolean NOT NULL DEFAULT false,
  verification_state verification_status NOT NULL DEFAULT 'unverified',
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

**Key Features:**
- Multi-role system (tenant/owner)
- 3-tier verification system
- Cultural/professional compatibility
- Hierarchical location structure
- Document storage support

---

### 2. Property Management

#### `buildings` - Property Listings
```sql
CREATE TABLE public.buildings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES profiles(id),
  name text NOT NULL,
  building_type building_type NOT NULL DEFAULT 'apartment',  -- apartment | pg | house
  address_line1 text NOT NULL,
  address_line2 text,
  country text NOT NULL DEFAULT 'India',
  state_id uuid NOT NULL REFERENCES states(id),
  city_id uuid NOT NULL REFERENCES cities(id),
  pincode text CHECK (pincode ~ '^[0-9]{6}$'),
  latitude double precision,                               -- GPS coordinates
  longitude double precision,
  contact_person_name text,
  contact_person_phone text CHECK (contact_person_phone ~ '^[+]?[0-9]{10,15}$'),
  building_id text UNIQUE,                                -- Auto-generated ID
  rules_file_url text,                                    -- Building rules document
  photos jsonb DEFAULT '[]',                              -- Array of photo URLs
  google_maps_link text,
  created_by_agent_id uuid REFERENCES profiles(id),       -- Property agent
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### `rooms` - Individual Rental Units
```sql
CREATE TABLE public.rooms (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  building_id uuid NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  name text NOT NULL,
  room_number text NOT NULL,
  room_id text UNIQUE,                                    -- Auto-generated ID
  room_type room_type NOT NULL DEFAULT 'single',         -- single | shared | studio
  fee numeric(10,2) NOT NULL,                            -- Monthly rent
  security_fee numeric(10,2),                            -- Security deposit
  maximum_occupancy integer NOT NULL DEFAULT 1,
  availability_status room_availability NOT NULL DEFAULT 'available', -- available | occupied | maintenance
  description text,
  photos jsonb DEFAULT '[]',                              -- Array of photo URLs
  created_by_agent_id uuid REFERENCES profiles(id),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  UNIQUE(building_id, room_number)                        -- Unique room per building
);
```

---

### 3. Rental Operations

#### `subscriptions` - Active Rental Agreements
```sql
CREATE TABLE public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  room_id uuid NOT NULL REFERENCES rooms(id),
  tenant_id uuid NOT NULL REFERENCES profiles(id),
  monthly_rent numeric(10,2) NOT NULL CHECK (monthly_rent > 0),
  security_deposit numeric(10,2) DEFAULT 0 CHECK (security_deposit >= 0),
  start_date date NOT NULL DEFAULT CURRENT_DATE,
  termination_date date,
  agreement_file_url text,                                -- Digital rental agreement
  status varchar(20) DEFAULT 'active' CHECK (status IN ('active', 'pending_termination', 'terminated')),
  is_active boolean DEFAULT true,
  terminated_by_agent_id uuid REFERENCES profiles(id),
  termination_reason text,
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- CRITICAL CONSTRAINT: Only one active subscription per room
CREATE UNIQUE INDEX one_active_subscription_per_room 
ON subscriptions(room_id) WHERE is_active = true;
```

#### `payments` - Monthly Rent Payments
```sql
CREATE TABLE public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id uuid NOT NULL REFERENCES subscriptions(id) ON DELETE CASCADE,
  month_year date NOT NULL,                               -- Payment month (YYYY-MM-01)
  amount_paid numeric(10,2) NOT NULL CHECK (amount_paid > 0),
  paid_date date NOT NULL DEFAULT CURRENT_DATE,
  payment_method text,                                    -- UPI | Card | Cash | Bank Transfer
  transaction_reference text,                             -- Payment gateway reference
  payment_group_id uuid,                                  -- For bulk payments
  is_last_payment boolean DEFAULT false,                  -- Final payment indicator
  notes text,
  created_at timestamptz NOT NULL DEFAULT now(),
  
  UNIQUE(subscription_id, month_year)                     -- One payment per month per subscription
);
```

---

### 4. Community Features

#### `reviews` - Building Ratings and Feedback
```sql
CREATE TABLE public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  building_id uuid NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  reviewer_id uuid NOT NULL REFERENCES profiles(id),
  subscription_id uuid REFERENCES subscriptions(id),     -- Links to actual tenancy
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  review_text text,
  photos_url text[],                                      -- Array of review photos
  is_verified boolean NOT NULL DEFAULT false,            -- Verified tenant review
  helpful_count integer NOT NULL DEFAULT 0,              -- Community helpfulness
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Unique review per subscription to prevent spam
  UNIQUE(building_id, reviewer_id, subscription_id) WHERE subscription_id IS NOT NULL
);
```

---

### 5. Cultural Compatibility System

#### `tribes` - Cultural/Tribal Categories
```sql
CREATE TABLE public.tribes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,                             -- e.g., "General", "OBC", "SC", "ST"
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### `professions` - Professional Categories
```sql
CREATE TABLE public.professions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,                             -- e.g., "Student", "IT Professional", "Doctor"
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### `building_tribe_exceptions` - Tribe-based Access Control
```sql
CREATE TABLE public.building_tribe_exceptions (
  building_id uuid NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  tribe_id uuid NOT NULL REFERENCES tribes(id),
  PRIMARY KEY (building_id, tribe_id)
);
```

#### `building_profession_exceptions` - Profession-based Access Control
```sql
CREATE TABLE public.building_profession_exceptions (
  building_id uuid NOT NULL REFERENCES buildings(id) ON DELETE CASCADE,
  profession_id uuid NOT NULL REFERENCES professions(id),
  PRIMARY KEY (building_id, profession_id)
);
```

**Access Control Logic:**
- **Inclusion by Default**: Users can access any building unless specifically restricted
- **Exception-based Filtering**: Buildings can exclude specific tribes/professions
- **Owner Discretion**: Property owners control access rules

---

### 6. Location Services

#### `states` - Indian States
```sql
CREATE TABLE public.states (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,                             -- e.g., "Karnataka", "Tamil Nadu"
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
```

#### `cities` - Cities within States
```sql
CREATE TABLE public.cities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  state_id uuid NOT NULL REFERENCES states(id) ON DELETE CASCADE,
  name text NOT NULL,                                    -- e.g., "Bangalore", "Chennai"
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  UNIQUE(state_id, name)                                 -- Unique city per state
);
```

---

### 7. Amenities Management

#### `amenities` - Feature Categories
```sql
CREATE TABLE public.amenities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text UNIQUE NOT NULL,                             -- e.g., "WiFi", "AC", "Parking"
  category text,                                         -- e.g., "Basic", "Premium", "Safety"
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  CHECK (length(trim(name)) > 0),
  CHECK (length(trim(category)) > 0)
);
```

#### `room_amenities` - Room-Amenity Mapping
```sql
CREATE TABLE public.room_amenities (
  room_id uuid NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  amenity_id uuid NOT NULL REFERENCES amenities(id),
  PRIMARY KEY (room_id, amenity_id)
);
```

---

## Entity Relationships Diagram

```
auth.users (Supabase)
    ↓
profiles ←→ tribes, professions, states, cities
    ↓
buildings ←→ building_tribe_exceptions, building_profession_exceptions
    ↓
rooms ←→ amenities (via room_amenities)
    ↓
subscriptions ←→ profiles (tenant)
    ↓
payments, reviews
```

---

## Key Business Rules

### 1. Subscription Management
- **One Active Subscription**: Each room can only have one active tenant
- **Monthly Payments**: One payment per month per subscription
- **Subscription Lifecycle**: active → pending_termination → terminated

### 2. Verification System
- **3-Tier Process**: Document → Police → Profile verification
- **States**: unverified → pending → verified → rejected
- **Document Requirements**: ID proof + Police verification mandatory

### 3. Cultural Compatibility
- **Inclusion by Default**: Open access unless restricted
- **Exception-based**: Specific exclusions per building
- **Dual Filtering**: Both tribe and profession-based restrictions

### 4. Payment Tracking
- **Monthly Constraint**: Prevents duplicate payments for same month
- **Transaction Audit**: Complete payment history with references
- **Security Deposits**: Separate tracking from monthly rent

### 5. Review System
- **Verified Reviews**: Linked to actual subscriptions
- **Rating Scale**: 1-5 stars with validation
- **Photo Support**: Multiple review photos per review

---

## Database Indexes

### Performance Critical Indexes
```sql
-- User lookups
CREATE INDEX profiles_role_idx ON profiles(role);
CREATE INDEX profiles_verification_state_idx ON profiles(verification_state);
CREATE INDEX profiles_state_city_idx ON profiles(state_id, city_id);

-- Property searches
CREATE INDEX buildings_state_city_idx ON buildings(state_id, city_id);
CREATE INDEX rooms_availability_status_idx ON rooms(availability_status);
CREATE INDEX rooms_fee_idx ON rooms(fee);

-- Subscription management
CREATE INDEX idx_subscriptions_tenant_id ON subscriptions(tenant_id);
CREATE INDEX idx_subscriptions_active ON subscriptions(is_active) WHERE is_active = true;

-- Payment tracking
CREATE INDEX idx_payments_month_year ON payments(month_year);
CREATE INDEX idx_payments_paid_date ON payments(paid_date);

-- Review system
CREATE INDEX reviews_building_id_idx ON reviews(building_id);
CREATE INDEX reviews_rating_idx ON reviews(rating);
```

---

## Data Types & Enums

### Custom Enums
```sql
-- User roles
CREATE TYPE user_role AS ENUM ('tenant', 'owner', 'agent', 'admin');

-- Building types
CREATE TYPE building_type AS ENUM ('apartment', 'house', 'pg', 'hostel', 'commercial');

-- Room types
CREATE TYPE room_type AS ENUM ('single', 'double', 'triple', 'studio');

-- Room availability
CREATE TYPE room_availability AS ENUM ('available', 'occupied', 'maintenance', 'reserved');

-- Verification status
CREATE TYPE verification_status AS ENUM ('unverified', 'pending', 'verified', 'rejected');

-- Gender types
CREATE TYPE sex_type AS ENUM ('male', 'female', 'other');

-- APST status for Arunachal Pradesh Scheduled Tribe classification
CREATE TYPE apst_status AS ENUM ('APST', 'Non-APST');
```

---

## Security Considerations

### Row Level Security (RLS)
- **Profile Access**: Users can only access their own profiles
- **Building Visibility**: Based on cultural compatibility rules
- **Payment Privacy**: Tenants see only their payment history
- **Review Integrity**: Verified reviews from actual tenants

### Data Validation
- **Phone Numbers**: Regex validation for Indian/international formats
- **Email Addresses**: Standard email format validation
- **Pincode**: 6-digit Indian pincode format
- **Age Restrictions**: 18-120 years for legal tenancy
- **Rating Bounds**: 1-5 star rating system

---

## Future Enhancements

### Phase 2 Features
- **Notification System**: Payment reminders, lease renewals
- **Messaging System**: Tenant-owner communication
- **Document Management**: Digital lease agreements
- **Analytics**: Usage patterns and insights

### Phase 3 Features
- **IoT Integration**: Smart home device management
- **AI Recommendations**: Property matching algorithms
- **Marketplace**: Furniture and services
- **Multi-language**: Localization support

---

*This database schema supports a comprehensive tenant-focused rental platform with cultural sensitivity for the Indian market, built on Supabase PostgreSQL with Flutter frontend integration.*