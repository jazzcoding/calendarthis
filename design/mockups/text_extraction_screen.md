# Text Extraction Screen Mockup

## Screen Overview
The Text Extraction Screen allows users to input or paste text containing event details, which the app will analyze to automatically extract event information. Users can review and edit the extracted information before creating an event.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Extract Event Details" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen
- **Right Icon**: Help icon (question mark)

### Input Section
- **Background**: #F8F9FA
- **Padding**: 16dp
- **Border Radius**: 8dp
- **Margin**: 16dp
- **Content**:
  - **Header**: "Enter or paste text containing event details" in 16sp
  - **Text Area**:
    - Height: 120dp
    - Background: White
    - Border: 1dp #E0E0E0
    - Border Radius: 8dp
    - Padding: 12dp
  - **Action Buttons**:
    - "Clear" (text button)
    - "Extract" (primary button)
  - **Example Text**: "Example: Meeting with John on Monday at 2pm at Coffee Shop to discuss project proposal"

### Processing Indicator
- **Type**: Linear progress indicator
- **Color**: #4285F4 (Primary Blue)
- **Visibility**: Shown only during extraction process

### Results Section
- **Background**: White
- **Padding**: 16dp
- **Margin**: 16dp
- **Border Radius**: 8dp
- **Elevation**: 2dp
- **Header**: "Extracted Event Details" in 18sp, bold

#### Extracted Fields
Each field follows the same structure:
- **Field Container**:
  - Background: White
  - Border: 1dp #E0E0E0
  - Border Radius: 8dp
  - Padding: 12dp
  - Margin Bottom: 16dp
- **Field Header**:
  - Label: Field name in 14sp, medium
  - Confidence Indicator: Colored pill showing confidence level
- **Field Content**:
  - Input: Editable text field
  - Style: Material filled text field

#### Confidence Indicators
- **High Confidence**: Green pill with "High" text
- **Medium Confidence**: Yellow pill with "Medium" text
- **Low Confidence**: Red pill with "Low" text

#### Extracted Field Types
- **Title**:
  - Label: "Event Title"
  - Required: Yes
- **Date**:
  - Label: "Date"
  - Format: Date picker field
  - Required: Yes
- **Start Time**:
  - Label: "Start Time"
  - Format: Time picker field
- **End Time**:
  - Label: "End Time"
  - Format: Time picker field
- **Location**:
  - Label: "Location"
  - Format: Text field
- **Description**:
  - Label: "Description"
  - Format: Multiline text field
- **Attendees**:
  - Label: "Attendees"
  - Format: Chips for each attendee

### Action Buttons
- **Layout**: Row of buttons at bottom
- **Padding**: 24dp
- **Buttons**:
  - **Create Event**:
    - Style: Primary button
    - Text: "Create Event"
    - Width: 50% of available space
  - **Edit Manually**:
    - Style: Outlined button
    - Text: "Edit Manually"
    - Width: 50% of available space

## Help Dialog
- **Title**: "Text Extraction Help"
- **Content**:
  - Instructions on how to use the text extraction feature
  - Examples of text formats that work well
  - Tips for improving extraction accuracy
- **Button**: "Got it" to dismiss dialog

## Interactions
- Tapping "Extract" analyzes the input text and displays results
- Tapping "Clear" empties the input text area
- Tapping "Create Event" creates an event with the extracted details
- Tapping "Edit Manually" opens the Event Creation screen with pre-filled data
- Tapping the Help icon opens the Help dialog
- All extracted fields are editable to correct any errors
- Date and time fields open appropriate pickers when tapped

## Visual Notes
- Use color coding for confidence levels to help users identify fields that may need correction
- Apply subtle animations when transitioning between input and results views
- Show loading/processing state during extraction
- Provide clear feedback for successful extraction
- Use consistent spacing and typography throughout
- Ensure all fields are easily editable
- Implement error states for failed extractions
