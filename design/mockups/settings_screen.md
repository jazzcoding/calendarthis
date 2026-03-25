# Settings Screen Mockup

## Screen Overview
The Settings Screen allows users to configure app preferences, manage account settings, and access additional information about the app.

## Layout Structure

### App Bar
- **Height**: 56dp
- **Background**: #4285F4 (Primary Blue)
- **Title**: "Settings" in white, 20sp
- **Left Icon**: Back arrow to return to previous screen

### Settings Container
- **Background**: #F8F9FA
- **Padding**: 16dp top and bottom
- **Layout**: Vertical scrolling list of settings sections

### Settings Sections

#### App Preferences Section
- **Section Header**:
  - Title: "App Preferences" in 16sp, medium, #5F6368
  - Padding: 16dp horizontal, 8dp vertical
- **Settings Items**:
  - **Theme**:
    - Icon: Palette icon
    - Title: "Theme"
    - Subtitle: "Light" / "Dark" / "System Default"
    - Control: Dropdown or navigation chevron
  - **Notifications**:
    - Icon: Bell icon
    - Title: "Notifications"
    - Subtitle: "On" / "Off"
    - Control: Switch
  - **Default Reminder Time**:
    - Icon: Alarm icon
    - Title: "Default Reminder"
    - Subtitle: Current setting (e.g., "30 minutes before")
    - Control: Dropdown or navigation chevron
  - **Time Format**:
    - Icon: Clock icon
    - Title: "Time Format"
    - Subtitle: "12-hour" / "24-hour"
    - Control: Switch or segmented control
  - **First Day of Week**:
    - Icon: Calendar icon
    - Title: "First Day of Week"
    - Subtitle: Current setting (e.g., "Sunday")
    - Control: Dropdown or navigation chevron

#### Calendar Integration Section
- **Section Header**:
  - Title: "Calendar Integration" in 16sp, medium, #5F6368
  - Padding: 16dp horizontal, 8dp vertical
- **Settings Items**:
  - **Default Calendar**:
    - Icon: Calendar icon
    - Title: "Default Calendar"
    - Subtitle: Current setting (e.g., "Google Calendar")
    - Control: Dropdown or navigation chevron
  - **Sync Frequency**:
    - Icon: Sync icon
    - Title: "Sync Frequency"
    - Subtitle: Current setting (e.g., "Automatic")
    - Control: Dropdown or navigation chevron
  - **Calendar Accounts**:
    - Icon: Account icon
    - Title: "Calendar Accounts"
    - Subtitle: "Manage connected accounts"
    - Control: Navigation chevron

#### AI Settings Section
- **Section Header**:
  - Title: "AI Settings" in 16sp, medium, #5F6368
  - Padding: 16dp horizontal, 8dp vertical
- **Settings Items**:
  - **AI Model**:
    - Icon: Brain icon
    - Title: "AI Model"
    - Subtitle: Current setting (e.g., "Standard")
    - Control: Dropdown or navigation chevron
  - **Extraction Confidence**:
    - Icon: Check icon
    - Title: "Minimum Confidence"
    - Subtitle: Current setting (e.g., "Medium")
    - Control: Dropdown or navigation chevron
  - **Save Extraction History**:
    - Icon: History icon
    - Title: "Save Extraction History"
    - Subtitle: "On" / "Off"
    - Control: Switch

#### About Section
- **Section Header**:
  - Title: "About" in 16sp, medium, #5F6368
  - Padding: 16dp horizontal, 8dp vertical
- **Settings Items**:
  - **Version**:
    - Icon: Info icon
    - Title: "Version"
    - Subtitle: Current version (e.g., "1.0.0")
    - Control: None
  - **Privacy Policy**:
    - Icon: Lock icon
    - Title: "Privacy Policy"
    - Control: Navigation chevron
  - **Terms of Service**:
    - Icon: Document icon
    - Title: "Terms of Service"
    - Control: Navigation chevron
  - **Open Source Licenses**:
    - Icon: Code icon
    - Title: "Open Source Licenses"
    - Control: Navigation chevron
  - **Send Feedback**:
    - Icon: Feedback icon
    - Title: "Send Feedback"
    - Control: Navigation chevron

### Action Buttons (Optional)
- **Reset to Defaults**:
  - Style: Outlined button
  - Text: "Reset to Defaults"
  - Position: Bottom of screen
  - Margin: 24dp

## Settings Item Structure
- **Height**: 56dp
- **Background**: White
- **Padding**: 16dp horizontal
- **Layout**: Row with icon, text, and control
- **Divider**: 1dp line between items
- **Icon**:
  - Size: 24dp
  - Color: #5F6368
  - Margin Right: 16dp
- **Text**:
  - Title: 16sp, regular, #202124
  - Subtitle (if present): 14sp, regular, #5F6368
- **Control**:
  - Position: Right aligned
  - Type: Varies by setting (switch, dropdown, chevron)

## Interactions
- Tapping items with navigation chevron opens detailed settings screens
- Toggling switches immediately applies settings
- Tapping dropdown items opens selection dialog
- Tapping "Reset to Defaults" shows confirmation dialog
- Tapping back arrow returns to previous screen

## Confirmation Dialog
- **Title**: "Reset Settings"
- **Message**: "Are you sure you want to reset all settings to default values?"
- **Buttons**:
  - "Cancel" (text button)
  - "Reset" (contained button)

## Visual Notes
- Group related settings together
- Use consistent iconography throughout
- Apply subtle dividers between sections
- Ensure adequate touch targets for all interactive elements
- Use visual hierarchy to distinguish between sections
- Implement smooth transitions for settings changes
