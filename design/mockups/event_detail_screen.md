# Event Detail Screen Mockup

## Screen Overview
The Event Detail Screen displays comprehensive information about a specific event, allowing users to view all details, edit the event, share it, or delete it.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Event Details" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen
- **Right Icons**:
  - Edit icon
  - Share icon
  - Delete icon (red color)

### Event Header
- **Height**: Auto
- **Background**: #4285F4 (Primary Blue)
- **Padding**: 24dp
- **Content**:
  - Event title: 24sp, bold, white
  - Date: 16sp, white
  - Time: 16sp, white (or "All day" if applicable)
  - Color indicator: 8dp vertical bar on left side

### Content Container
- **Background**: White
- **Border Radius**: 16dp top corners (curved top)
- **Margin Top**: -16dp (overlaps with header)
- **Padding**: 24dp
- **Layout**: Vertical scrolling container

### Information Sections
Each section follows the same structure:
- **Section Header**:
  - Icon: Relevant icon for the section
  - Title: Section name in 18sp, bold
  - Divider: 1dp line below header
- **Section Content**:
  - Padding: 16dp top and bottom
  - Text: 16sp for main content

#### Date & Time Section
- **Icon**: Clock icon
- **Title**: "Date & Time"
- **Content**:
  - Start date and time
  - End date and time
  - Duration
  - All day indicator (if applicable)
  - Reminder setting

#### Location Section (if available)
- **Icon**: Location pin icon
- **Title**: "Location"
- **Content**:
  - Location text
  - Map preview (120dp height, rounded corners)
  - "View Map" button

#### Description Section (if available)
- **Icon**: Text document icon
- **Title**: "Description"
- **Content**: Event description text with proper formatting

#### Attendees Section (if available)
- **Icon**: People icon
- **Title**: "Attendees"
- **Content**: List of attendees with:
  - Circular avatar or initials (40dp)
  - Name
  - Email or status

### Action Buttons
- **Layout**: Row of buttons at bottom
- **Padding**: 24dp
- **Buttons**:
  - **Edit Event**:
    - Style: Primary button
    - Icon: Edit icon
    - Text: "Edit"
  - **Delete Event**:
    - Style: Outlined button with red text
    - Icon: Delete icon
    - Text: "Delete"
  - **Share Event**:
    - Style: Outlined button
    - Icon: Share icon
    - Text: "Share"

## Interactions
- Tapping Edit icon or Edit button navigates to Event Creation screen with pre-filled data
- Tapping Share icon or Share button opens platform share sheet
- Tapping Delete icon or Delete button shows confirmation dialog
- Tapping "View Map" opens map application with location
- Tapping back arrow returns to previous screen

## Delete Confirmation Dialog
- **Title**: "Delete Event"
- **Message**: "Are you sure you want to delete [Event Title]?"
- **Buttons**:
  - "Cancel" (text button)
  - "Delete" (contained button with red background)

## Visual Notes
- Use visual hierarchy to emphasize important information
- Apply consistent spacing between sections
- Use icons to improve scannability
- Ensure adequate contrast for text readability
- Implement subtle animations for button interactions
- Use elevation to create depth between content sections
