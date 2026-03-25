# Saved Events Screen Mockup

## Screen Overview
The Saved Events Screen displays all events created or saved by the user, with options to view them in a list or calendar format. It provides filtering, searching, and quick access to event details.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Saved Events" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen
- **Right Icons**:
  - Search icon
  - View toggle icon (list/calendar)

### View Toggle
- **Type**: Segmented control
- **Options**: "List" and "Calendar"
- **Default**: "List"
- **Position**: Below app bar, full width
- **Height**: 48dp
- **Style**: Material segmented button

### List View

#### Filter Section
- **Height**: 56dp
- **Background**: #F8F9FA
- **Content**:
  - Dropdown for time filter (All, Today, This Week, This Month)
  - Sort button with options (Date, Title, Location)

#### Event List
- **Layout**: Vertical scrolling list
- **Padding**: 16dp horizontal, 8dp vertical between items
- **Event Card**:
  - Height: Auto (minimum 80dp)
  - Background: White
  - Border Radius: 12dp
  - Border-left: 4dp colored bar based on event type
  - Elevation: 2dp
  - Content:
    - Event title: 16sp, bold
    - Date and time: 14sp, with clock icon
    - Location (if available): 14sp, with location icon
  - Right Icon: Chevron indicating tap to view details

#### Empty State
- **Content**:
  - Illustration: Calendar with no events
  - Message: "No events found"
  - Action Button: "Create Event" primary button

### Calendar View

#### Calendar Widget
- **Height**: 320dp
- **Type**: Month view calendar
- **Features**:
  - Month/year header with navigation arrows
  - Day of week labels
  - Date grid with current day highlighted
  - Event indicators (colored dots) on days with events
  - Selected day highlighted

#### Selected Day Events
- **Header**: Selected date in text format (e.g., "June 15, 2023")
- **Content**: List of events for the selected day
  - If events exist: Scrollable list of event cards (similar to List View)
  - If no events: Message "No events on this day" with add button

### Floating Action Button
- **Position**: Bottom right corner
- **Icon**: Plus icon
- **Background**: #4285F4 (Primary Blue)
- **Size**: 56dp x 56dp
- **Elevation**: 6dp

## Interactions
- Tapping view toggle switches between List and Calendar views
- Tapping an event card opens the Event Detail screen for that event
- Tapping the search icon opens search interface
- Tapping filter or sort options updates the displayed events
- In Calendar View, tapping a day selects it and shows events for that day
- Tapping the FAB navigates to Event Creation screen
- Pull-to-refresh updates the event list

## Calendar View Details

### Month Header
- **Height**: 48dp
- **Content**: Month and year text with left/right arrows
- **Style**: 18sp, bold, centered

### Weekday Header
- **Height**: 32dp
- **Content**: Short weekday names (S, M, T, W, T, F, S)
- **Style**: 14sp, centered

### Date Grid
- **Layout**: 7 columns (days of week)
- **Cell Size**: Equal width, 40dp height
- **Current Day**: Outlined circle
- **Selected Day**: Filled circle with #4285F4 background
- **Event Indicators**: Up to 3 small colored dots below date
- **Out-of-month Dates**: Lighter text color (#BDBDBD)

## Visual Notes
- Use consistent spacing between all elements
- Apply color coding to event cards based on event type or category
- Ensure calendar date selection is clearly visible
- Use subtle animations for view transitions
- Implement skeleton loading state while events are being fetched
