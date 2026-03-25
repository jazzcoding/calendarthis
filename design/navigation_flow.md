# CalendarThis! Navigation Flow

## App Entry Points

### Primary Flow
```
Splash Screen → Onboarding Screens (first launch only) → Home Screen
```

### Secondary Entry Points
```
Share Text from Other App → Text Extraction Screen
Android Context Menu → Text Extraction Screen
App Icon Launch → Splash Screen → Home Screen
Notification Tap → Event Detail Screen
```

## Main Navigation Paths

### Home Screen Navigation
```
Home Screen → Create Event → Event Creation Screen
Home Screen → View Events → Saved Events Screen
Home Screen → Scan from Image → Camera Capture Screen
Home Screen → Settings Icon → Settings Screen
Home Screen → Menu Icon → Navigation Drawer
```

### Navigation Drawer Paths
```
Navigation Drawer → Home → Home Screen
Navigation Drawer → Create Event → Event Creation Screen
Navigation Drawer → Events → Saved Events Screen
Navigation Drawer → Scan from Image → Camera Capture Screen
Navigation Drawer → Extract from Text → Text Extraction Screen
Navigation Drawer → Settings → Settings Screen
Navigation Drawer → Help & Feedback → Help Screen
```

### Event Management Flow
```
Saved Events Screen → Event Card → Event Detail Screen
Event Detail Screen → Edit Icon → Event Creation Screen (Edit Mode)
Event Creation Screen → Save → Saved Events Screen
Event Detail Screen → Delete → Confirmation Dialog → Saved Events Screen
```

### Text Extraction Flow
```
Text Extraction Screen → Extract → Results View
Text Extraction Screen → Create Event → Event Creation Screen (Pre-filled)
```

### Image Capture Flow
```
Camera Capture Screen → Take Photo → Processing → Results View
Camera Capture Screen → Gallery Icon → Image Selection → Processing → Results View
Camera Capture Results → Create Event → Event Creation Screen (Pre-filled)
```

## Modal Flows

### Permission Requests
```
Onboarding (Last Screen) → Calendar Permission Dialog
Onboarding (Last Screen) → Notification Permission Dialog
Camera Capture (First Use) → Camera Permission Dialog
```

### Confirmation Dialogs
```
Event Detail (Delete) → Delete Confirmation Dialog
Event Creation (Back/Close) → Discard Changes Dialog
Settings (Reset) → Reset Confirmation Dialog
```

## Screen States

### Home Screen States
- Default state (with upcoming events)
- Empty state (no events)
- Loading state

### Saved Events Screen States
- List view (default)
- Calendar view
- Empty state
- Loading state
- Search active state
- Filter active state

### Text Extraction Screen States
- Input state (empty)
- Input state (with text)
- Processing state
- Results state
- Error state

### Camera Capture Screen States
- Camera preview state
- Processing state
- Results state
- Permission denied state
- Error state

## Transition Patterns

### Standard Transitions
- Push navigation (screen slides in from right)
- Pop navigation (screen slides out to right)
- Modal presentation (screen slides up from bottom)
- Modal dismissal (screen slides down)

### Special Transitions
- Splash to Home (fade transition)
- Onboarding pagination (horizontal slide)
- Tab switching (crossfade)
- View toggle in Saved Events (crossfade)

## Deep Linking

### Supported Deep Links
```
calendarthis://event/{event_id} → Event Detail Screen
calendarthis://create → Event Creation Screen
calendarthis://extract → Text Extraction Screen
calendarthis://scan → Camera Capture Screen
calendarthis://settings → Settings Screen
```
