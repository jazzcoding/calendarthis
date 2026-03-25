# Home Screen Mockup

## Screen Overview
The Home Screen serves as the main entry point to the CalendarThis! app, providing quick access to key features and a summary of upcoming events.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "CalendarThis!" in white, 20sp, centered
- **Left Icon**: Menu (hamburger) to open drawer navigation
- **Right Icon**: Settings icon

### Hero Section
- **Height**: 180dp
- **Background**: Gradient from #4285F4 to #34A853
- **Content**:
  - App logo (calendar icon): 80dp x 80dp, centered
  - Tagline: "Smart Calendar Assistant" in white, 16sp, centered
  - Brief description: "Extract event details from text and create calendar events easily" in white, 14sp, centered

### Quick Actions Section
- **Layout**: Horizontal row of 3 action buttons
- **Spacing**: 16dp between buttons
- **Padding**: 24dp from screen edges
- **Buttons**:
  - **Create Event**:
    - Icon: Plus icon
    - Text: "Create Event"
    - Style: Primary button
  - **View Events**:
    - Icon: Calendar icon
    - Text: "View Events"
    - Style: Secondary button
  - **Extract Text**:
    - Icon: Text icon
    - Text: "Extract Text"
    - Style: Secondary button

### Recent Events Section
- **Header**:
  - Title: "Upcoming Events" in 18sp, bold
  - Action: "View All" text button
- **Content**:
  - If events exist: List of up to 3 event cards
  - If no events: Empty state with illustration and "No upcoming events" message
- **Event Card**:
  - Height: 80dp
  - Border-left: 4dp colored bar based on event type
  - Content:
    - Event title: 16sp, bold
    - Date and time: 14sp, with clock icon
    - Location (if available): 14sp, with location icon

### Feature Highlight Section
- **Layout**: Card with illustration and text
- **Content**:
  - Illustration: Image showing text extraction feature
  - Title: "Extract Events from Text" in 18sp, bold
  - Description: Brief explanation of the feature
  - Action Button: "Try Now" primary button

### Bottom Navigation (Optional)
- **Height**: 56dp
- **Background**: White
- **Items**:
  - Home (active)
  - Events
  - Create
  - Settings

## Interactions
- Tapping "Create Event" navigates to Event Creation screen
- Tapping "View Events" navigates to Saved Events screen
- Tapping "Extract Text" navigates to Text Extraction screen
- Tapping an event card opens the Event Detail screen for that event
- Tapping "View All" in Recent Events section navigates to Saved Events screen
- Tapping "Try Now" in Feature Highlight navigates to Text Extraction screen
- Tapping menu icon opens the navigation drawer
- Tapping settings icon navigates to Settings screen

## Visual Notes
- Use shadow elevation to create depth hierarchy
- Implement subtle animations for button interactions
- Use consistent iconography throughout
- Ensure adequate contrast for text readability
- Apply rounded corners to all cards and buttons
