# Splash Screen and App Icon Mockup

## App Icon Design

### Concept
The CalendarThis! app icon represents the core functionality of the app: extracting event details from text to create calendar events. The design combines a calendar element with a text extraction visual cue.

### Icon Composition
- **Base Shape**: Rounded square (squircle)
- **Background**: Gradient from #4285F4 (Google Blue) to #34A853 (Google Green)
- **Primary Element**: Stylized calendar page
  - White/light background
  - Blue header section
  - Visible date numbers
- **Secondary Element**: Text extraction visual
  - Highlighted text line or magnifying glass
  - Accent color: #FBBC05 (Google Yellow)
- **Visual Style**: Material Design principles
  - Clean, minimal design
  - Bold colors
  - Subtle shadows for depth

### Size Variations
- **Play Store Icon**: 512px × 512px
- **App Icon**: 192px × 192px
- **Notification Icon**: 96px × 96px
- **Settings Icon**: 48px × 48px

### Platform-Specific Adaptations

#### Android
- **Adaptive Icon**:
  - **Foreground Layer**: Calendar and text elements
  - **Background Layer**: Gradient background
  - **Safe Zone**: All critical elements within 66% center area

#### iOS
- **App Store Icon**: Full rounded square design
- **Home Screen Icon**: Automatically rounded by iOS

### Color Specifications
- **Primary Blue**: #4285F4
- **Secondary Green**: #34A853
- **Accent Yellow**: #FBBC05
- **Calendar Page**: #FFFFFF
- **Calendar Header**: #4285F4
- **Text Elements**: #202124

## Splash Screen Design

### Layout Structure
- **Background**: Gradient from #4285F4 (top) to #34A853 (bottom)
- **Content**: Centered vertically and horizontally
- **Duration**: 2-3 seconds before transitioning to home or onboarding

### Content Elements
- **App Logo**:
  - Size: 120dp × 120dp
  - Position: Center of screen
  - Animation: Subtle scale-up and fade-in
- **App Name**:
  - Text: "CalendarThis!"
  - Style: 32sp, bold, white
  - Position: Below logo, 16dp margin
  - Animation: Fade-in after logo appears
- **Tagline** (optional):
  - Text: "Smart Calendar Assistant"
  - Style: 16sp, regular, white
  - Position: Below app name, 8dp margin
  - Animation: Fade-in after app name
- **Loading Indicator** (optional):
  - Style: Circular progress indicator
  - Size: 48dp diameter
  - Color: White
  - Position: Below tagline, 24dp margin
  - Animation: Continuous rotation

### Animation Sequence
1. Background gradient appears (instant)
2. Logo scales up slightly and fades in (0.3s)
3. App name fades in (0.3s, starts at 0.2s)
4. Tagline fades in (0.3s, starts at 0.4s)
5. Hold complete screen (1.5s)
6. Transition to next screen (0.5s fade out)

### Responsive Behavior
- **Phone**: Full-screen design as described
- **Tablet**: Same design, proportionally sized elements
- **Orientation**: Works in both portrait and landscape

## Technical Specifications

### App Icon Technical Requirements
- **Format**: PNG with transparency
- **Color Space**: sRGB
- **Compression**: Lossless
- **Corner Radius**: 
  - Android: Handled by adaptive icon system
  - iOS: Approximately 20% of icon width

### Splash Screen Technical Implementation
- **Android**:
  - Implementation: Use splash screen API for Android 12+
  - Backward compatibility: Use theme-based splash for older versions
- **iOS**:
  - Implementation: Use LaunchScreen.storyboard
  - Assets: Include all required image sizes

### Asset Delivery
- **Icon Formats**: PNG and vector source files (SVG or AI)
- **Splash Assets**: PNG and vector source files
- **Color Specifications**: HEX, RGB, and CMYK values
- **Guidelines**: Documentation for implementation

## Visual Notes
- Ensure the app icon is recognizable at small sizes
- Use consistent visual language between icon and app interface
- Apply appropriate contrast for accessibility
- Test splash screen on various device sizes and orientations
- Ensure smooth transitions between splash screen and first app screen
- Optimize assets for file size while maintaining quality
