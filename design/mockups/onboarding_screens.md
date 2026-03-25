# Onboarding Screens Mockup

## Overview
The Onboarding Screens introduce new users to the CalendarThis! app, highlighting key features and guiding them through initial setup. The design consists of a series of full-screen pages that users can swipe through.

## Common Elements Across All Screens

### Layout Structure
- **Full Screen**: Each onboarding screen takes up the entire device screen
- **Status Bar**: Transparent or colored to match screen background
- **Navigation**:
  - Skip button (top right)
  - Next/Previous indicators (bottom)
  - Progress indicators (bottom center)

### Navigation Controls
- **Skip Button**:
  - Position: Top right corner
  - Text: "Skip"
  - Style: Text button, white or contrasting color
  - Padding: 16dp
- **Next Button**:
  - Position: Bottom right
  - Text: "Next" (or "Get Started" on final screen)
  - Style: Contained button with contrasting color
  - Size: 120dp width, 48dp height
  - Margin: 24dp from bottom and right
- **Back Button** (not on first screen):
  - Position: Bottom left
  - Text: "Back"
  - Style: Text button with contrasting color
  - Margin: 24dp from bottom and left
- **Progress Indicators**:
  - Position: Bottom center
  - Style: Dots (active dot larger/different color)
  - Count: One per onboarding screen
  - Spacing: 8dp between dots

## Screen 1: Welcome

### Background
- **Color**: Gradient from #4285F4 (top) to #34A853 (bottom)
- **Opacity**: 100%

### Content
- **Logo**:
  - Position: Center top, 25% from top of screen
  - Size: 120dp x 120dp
  - Image: App logo (calendar icon)
- **Title**:
  - Text: "Welcome to CalendarThis!"
  - Style: 28sp, bold, white
  - Position: Below logo, 16dp margin
- **Subtitle**:
  - Text: "Your smart calendar assistant"
  - Style: 18sp, regular, white
  - Position: Below title, 8dp margin
- **Description**:
  - Text: "Extract event details from text and create calendar events with just a few taps"
  - Style: 16sp, regular, white
  - Position: Below subtitle, 16dp margin
  - Width: 80% of screen width, centered
- **Illustration**:
  - Position: Bottom half of screen
  - Size: 60% of screen width, aspect ratio preserved
  - Image: Illustration of app main features
  - Margin Bottom: 120dp (to leave room for navigation)

## Screen 2: Text Extraction

### Background
- **Color**: #34A853 (Google Green)
- **Opacity**: 100%

### Content
- **Illustration**:
  - Position: Center top, 15% from top of screen
  - Size: 60% of screen width, aspect ratio preserved
  - Image: Illustration showing text being converted to calendar event
- **Title**:
  - Text: "Smart Text Extraction"
  - Style: 28sp, bold, white
  - Position: Below illustration, 24dp margin
- **Description**:
  - Text: "Share text from any app or paste directly. Our AI will identify event details automatically."
  - Style: 16sp, regular, white
  - Position: Below title, 16dp margin
  - Width: 80% of screen width, centered
- **Feature Points**:
  - Layout: Vertical list of points with icons
  - Position: Below description, 24dp margin
  - Items:
    - "Extract from messages, emails, and notes"
    - "Identify dates, times, locations, and more"
    - "Edit and confirm before saving"
  - Style: 16sp, regular, white with leading icons
  - Icon Size: 24dp
  - Spacing: 16dp between items

## Screen 3: Calendar Integration

### Background
- **Color**: #FBBC05 (Google Yellow)
- **Opacity**: 100%

### Content
- **Illustration**:
  - Position: Center top, 15% from top of screen
  - Size: 60% of screen width, aspect ratio preserved
  - Image: Illustration showing calendar with events
- **Title**:
  - Text: "Seamless Calendar Integration"
  - Style: 28sp, bold, white
  - Position: Below illustration, 24dp margin
- **Description**:
  - Text: "Create events in your favorite calendars and keep everything synchronized."
  - Style: 16sp, regular, white
  - Position: Below title, 16dp margin
  - Width: 80% of screen width, centered
- **Feature Points**:
  - Layout: Vertical list of points with icons
  - Position: Below description, 24dp margin
  - Items:
    - "Works with Google Calendar, Outlook, and more"
    - "View all your events in one place"
    - "Get reminders when events are approaching"
  - Style: 16sp, regular, white with leading icons
  - Icon Size: 24dp
  - Spacing: 16dp between items

## Screen 4: Permissions

### Background
- **Color**: #EA4335 (Google Red)
- **Opacity**: 100%

### Content
- **Illustration**:
  - Position: Center top, 15% from top of screen
  - Size: 50% of screen width, aspect ratio preserved
  - Image: Illustration showing app permissions concept
- **Title**:
  - Text: "Just One More Step"
  - Style: 28sp, bold, white
  - Position: Below illustration, 24dp margin
- **Description**:
  - Text: "CalendarThis! needs a few permissions to work properly."
  - Style: 16sp, regular, white
  - Position: Below title, 16dp margin
  - Width: 80% of screen width, centered
- **Permissions List**:
  - Layout: Vertical list of permissions with icons and explanations
  - Position: Below description, 24dp margin
  - Items:
    - **Calendar**:
      - Icon: Calendar icon
      - Title: "Calendar Access"
      - Description: "To create and manage events"
    - **Notifications**:
      - Icon: Bell icon
      - Title: "Notifications"
      - Description: "For event reminders"
  - Style: Title 16sp bold, description 14sp regular, white
  - Icon Size: 24dp
  - Spacing: 24dp between items
- **Get Started Button**:
  - Text: "Get Started"
  - Style: Contained button with white background and primary color text
  - Size: 200dp width, 48dp height
  - Position: Bottom center, 80dp from bottom

## Interactions
- Swiping left/right navigates between screens
- Tapping "Next" advances to the next screen
- Tapping "Back" returns to the previous screen
- Tapping "Skip" goes directly to the home screen
- Tapping "Get Started" on the final screen begins permission requests
- Dots at bottom indicate current position and total number of screens

## Permission Requests
After the onboarding flow, the app will request necessary permissions:
1. Calendar permission dialog
2. Notification permission dialog

## Visual Notes
- Use consistent typography and spacing across all screens
- Apply smooth transitions between screens
- Use high-quality illustrations that reflect the app's brand
- Ensure text has adequate contrast against backgrounds
- Implement responsive layout for different screen sizes
- Consider accessibility for all interactive elements
