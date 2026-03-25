# Event Creation Screen Mockup

## Screen Overview
The Event Creation Screen allows users to create new events or edit existing ones, with fields for all event details and options to save or discard changes.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Create Event" or "Edit Event" in white, 20sp
- **Left Icon**: Close (X) icon to cancel
- **Right Icon**: Save/check icon to save event

### Form Container
- **Background**: White
- **Padding**: 24dp
- **Layout**: Vertical scrolling form

### Form Fields

#### Title Field
- **Label**: "Event Title" (required)
- **Input**: Text field
- **Style**: Material outlined text field
- **Height**: 56dp
- **Margin Bottom**: 24dp

#### Date & Time Section
- **Section Header**: "Date & Time" in 18sp, bold
- **All Day Toggle**:
  - Label: "All Day"
  - Control: Switch
  - Position: Right aligned
- **Start Date**:
  - Label: "Start Date"
  - Input: Date picker field
  - Icon: Calendar icon
- **Start Time** (hidden if All Day is on):
  - Label: "Start Time"
  - Input: Time picker field
  - Icon: Clock icon
- **End Date**:
  - Label: "End Date"
  - Input: Date picker field
  - Icon: Calendar icon
- **End Time** (hidden if All Day is on):
  - Label: "End Time"
  - Input: Time picker field
  - Icon: Clock icon
- **Reminder**:
  - Label: "Reminder"
  - Input: Dropdown
  - Options: None, 5 minutes, 15 minutes, 30 minutes, 1 hour, 1 day
  - Default: 30 minutes

#### Location Field
- **Label**: "Location"
- **Input**: Text field with autocomplete
- **Icon**: Location pin
- **Style**: Material outlined text field
- **Height**: 56dp
- **Margin**: 24dp top and bottom

#### Description Field
- **Label**: "Description"
- **Input**: Multiline text field
- **Style**: Material outlined text field
- **Height**: 120dp (expandable)
- **Margin**: 24dp top and bottom

#### Attendees Section
- **Section Header**: "Attendees" in 18sp, bold
- **Add Attendee**:
  - Input: Text field with email validation
  - Button: "Add" button
- **Attendee List**:
  - Layout: Vertical list of added attendees
  - Item: Chip with name/email and remove (X) icon
  - Empty State: "No attendees added"

### Action Buttons
- **Layout**: Row of buttons at bottom
- **Padding**: 24dp
- **Buttons**:
  - **Save**:
    - Style: Primary button
    - Text: "Save Event"
    - Width: 50% of available space
  - **Cancel**:
    - Style: Outlined button
    - Text: "Cancel"
    - Width: 50% of available space

## Date Picker Dialog
- **Title**: "Select Date"
- **Layout**: Calendar month view
- **Controls**:
  - Month/year selector
  - Day grid
  - "Cancel" and "OK" buttons

## Time Picker Dialog
- **Title**: "Select Time"
- **Layout**: Clock face or digital time input
- **Controls**:
  - Hour/minute selectors
  - AM/PM toggle (if 12-hour format)
  - "Cancel" and "OK" buttons

## Interactions
- Tapping date fields opens date picker dialog
- Tapping time fields opens time picker dialog
- Toggling "All Day" hides/shows time fields
- Tapping "Add" for attendees adds email to attendee list
- Tapping X on attendee chip removes that attendee
- Tapping Save icon or Save button validates form and saves event
- Tapping Close icon or Cancel button shows discard confirmation dialog
- Form validation shows error messages for invalid or missing required fields

## Discard Confirmation Dialog
- **Title**: "Discard Changes"
- **Message**: "Are you sure you want to discard your changes?"
- **Buttons**:
  - "Cancel" (text button)
  - "Discard" (contained button)

## Visual Notes
- Group related fields together
- Use consistent spacing between form sections
- Apply visual indicators for required fields
- Show validation errors inline
- Use field focus states to guide user through form completion
- Implement smooth transitions between form states
- Ensure form is scrollable for smaller screens
