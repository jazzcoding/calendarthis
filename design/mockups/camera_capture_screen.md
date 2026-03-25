# Camera Capture and Image Extraction Screen Mockup

## Screen Overview
The Camera Capture Screen allows users to take photos of text containing event details or select images from their gallery. The app then processes these images to extract event information, which users can review and edit before creating an event.

## Layout Structure

### Camera Capture Mode

#### App Bar
- **Height**: 56dp
- **Background**: Semi-transparent black (70% opacity)
- **Title**: "Scan Event Details" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen
- **Right Icons**:
  - Flash toggle (on/off/auto)
  - Gallery picker icon

#### Camera Preview
- **Layout**: Full screen camera preview
- **Aspect Ratio**: Match device camera (typically 4:3 or 16:9)
- **Overlay**: Light frame indicating optimal text capture area
- **Guidelines**: Text indicating "Position text within frame"

#### Capture Controls
- **Position**: Bottom of screen
- **Background**: Semi-transparent black (70% opacity)
- **Height**: 80dp
- **Content**:
  - Capture button (large circular button)
  - Switch camera button (front/back)
  - Cancel button

### Image Processing Mode

#### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Processing Image" in white, 20sp
- **Left Icon**: Back arrow to return to camera

#### Processing View
- **Background**: #F8F9FA
- **Content**:
  - Captured image (scaled to fit screen width)
  - Processing indicator (circular progress)
  - Status text: "Extracting text..." / "Analyzing content..." / "Identifying event details..."

### Results Review Mode

#### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Review Extracted Details" in white, 20sp
- **Left Icon**: Back arrow to return to camera
- **Right Icon**: Edit icon

#### Image Thumbnail
- **Position**: Top of screen
- **Size**: 30% of screen height, maintaining aspect ratio
- **Background**: #E0E0E0
- **Border**: 1dp #BDBDBD
- **Corner Radius**: 8dp

#### Extracted Text Preview
- **Background**: White
- **Border**: 1dp #E0E0E0
- **Corner Radius**: 8dp
- **Padding**: 16dp
- **Max Height**: 120dp (scrollable if content exceeds)
- **Content**: Raw extracted text with recognized event details highlighted

#### Extracted Event Details
- **Layout**: Similar to Text Extraction Results Screen
- **Fields**:
  - Event Title
  - Date
  - Start Time
  - End Time
  - Location
  - Description
- **Field Structure**:
  - Label: Field name in 14sp, medium
  - Confidence Indicator: Colored pill showing confidence level
  - Value: Extracted value in editable text field

#### Action Buttons
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

## Gallery Selection Mode

#### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Select Image" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen

#### Gallery Grid
- **Layout**: Grid of image thumbnails (3 columns)
- **Thumbnail Size**: Equal width, maintaining aspect ratio
- **Spacing**: 4dp between items
- **Selection Indicator**: Blue overlay with check icon

#### Action Button
- **Position**: Bottom center
- **Style**: Primary button
- **Text**: "Process Selected Image"
- **Width**: 80% of screen width
- **Visibility**: Shown only when an image is selected

## Permission Requests
- **Camera Permission Dialog**:
  - Title: "Camera Access"
  - Message: "CalendarThis! needs access to your camera to scan text for event details."
  - Buttons: "Deny" and "Allow"
- **Gallery Permission Dialog**:
  - Title: "Photo Library Access"
  - Message: "CalendarThis! needs access to your photos to select images containing event details."
  - Buttons: "Deny" and "Allow"

## Error States
- **Camera Unavailable**:
  - Illustration: Camera with error icon
  - Message: "Camera unavailable. Please check permissions."
  - Action: "Open Settings" button
- **Text Recognition Failed**:
  - Illustration: Document with error icon
  - Message: "Could not recognize text in image. Please try again with a clearer image."
  - Action: "Try Again" button
- **No Event Details Found**:
  - Illustration: Calendar with question mark
  - Message: "No event details found in the text. Please try another image or enter details manually."
  - Action: "Create Manual Event" button

## Interactions
- Tapping capture button takes a photo
- Tapping gallery icon opens image picker
- Tapping back arrow in camera mode returns to previous screen
- Tapping back arrow in processing or results mode returns to camera mode
- Tapping "Create Event" creates an event with the extracted details
- Tapping "Edit Manually" opens the Event Creation screen with pre-filled data
- Tapping edit icon in results mode allows editing of extracted text

## Visual Notes
- Use camera viewfinder guides to help users position text properly
- Apply subtle animations for transitions between modes
- Show clear loading states during image processing
- Use color coding for confidence levels to help users identify fields that may need correction
- Ensure adequate contrast for text and controls overlaid on camera preview
- Implement proper error handling with clear user guidance
- Optimize camera settings for text recognition (focus, exposure)
