# WidMate App Icon Generation Guide

## Overview
This guide explains how to generate the app icon for WidMate from the provided SVG design.

## Design Files
- **Source SVG**: `assets/icons/app_icon.svg`
- **Design Description**: `assets/icons/icon_description.md`

## Required Icon Sizes

### Android
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS
- `ios/Runner/Assets.xcassets/AppIcon.appiconset/` (various sizes)
- 20x20, 29x29, 40x40, 60x60, 76x76, 83.5x83.5, 1024x1024

### Web
- `web/icons/Icon-192.png` (192x192)
- `web/icons/Icon-512.png` (512x512)
- `web/favicon.png` (32x32)

### Windows
- `windows/runner/Resources/app_icon.ico` (multiple sizes)

### macOS
- `macos/Runner/Assets.xcassets/AppIcon.appiconset/` (various sizes)

## Generation Tools

### Option 1: Online Tools
1. **Favicon.io**: https://favicon.io/
2. **App Icon Generator**: https://appicon.co/
3. **Icon Kitchen**: https://icon.kitchen/

### Option 2: Design Software
1. **Adobe Illustrator**: Export SVG to PNG/ICO
2. **Figma**: Export SVG to PNG/ICO
3. **GIMP**: Import SVG, export as PNG/ICO
4. **Inkscape**: Export SVG to PNG/ICO

### Option 3: Command Line Tools
1. **ImageMagick**: Convert SVG to PNG
2. **Inkscape CLI**: Export SVG to PNG
3. **rsvg-convert**: Convert SVG to PNG

## Generation Steps

### 1. Prepare the SVG
- Ensure the SVG is 512x512px
- Check all gradients and colors are correct
- Verify all elements are properly aligned

### 2. Generate Android Icons
```bash
# Using ImageMagick
convert assets/icons/app_icon.svg -resize 72x72 android/app/src/main/res/mipmap-hdpi/ic_launcher.png
convert assets/icons/app_icon.svg -resize 48x48 android/app/src/main/res/mipmap-mdpi/ic_launcher.png
convert assets/icons/app_icon.svg -resize 96x96 android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
convert assets/icons/app_icon.svg -resize 144x144 android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
convert assets/icons/app_icon.svg -resize 192x192 android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
```

### 3. Generate iOS Icons
```bash
# Generate all required iOS sizes
convert assets/icons/app_icon.svg -resize 40x40 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-40.png
convert assets/icons/app_icon.svg -resize 60x60 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-60.png
convert assets/icons/app_icon.svg -resize 80x80 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-80.png
convert assets/icons/app_icon.svg -resize 120x120 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-120.png
convert assets/icons/app_icon.svg -resize 152x152 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-152.png
convert assets/icons/app_icon.svg -resize 167x167 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-167.png
convert assets/icons/app_icon.svg -resize 1024x1024 ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-1024.png
```

### 4. Generate Web Icons
```bash
# Generate web icons
convert assets/icons/app_icon.svg -resize 192x192 web/icons/Icon-192.png
convert assets/icons/app_icon.svg -resize 512x512 web/icons/Icon-512.png
convert assets/icons/app_icon.svg -resize 32x32 web/favicon.png
```

### 5. Generate Windows Icon
```bash
# Generate Windows ICO file
convert assets/icons/app_icon.svg -resize 256x256 windows/runner/Resources/app_icon.ico
```

### 6. Generate macOS Icons
```bash
# Generate macOS icons
convert assets/icons/app_icon.svg -resize 16x16 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon-16.png
convert assets/icons/app_icon.svg -resize 32x32 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon-32.png
convert assets/icons/app_icon.svg -resize 128x128 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon-128.png
convert assets/icons/app_icon.svg -resize 256x256 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon-256.png
convert assets/icons/app_icon.svg -resize 512x512 macos/Runner/Assets.xcassets/AppIcon.appiconset/icon-512.png
```

## Quality Checklist
- [ ] All icons are crisp and clear
- [ ] Colors match the design specification
- [ ] Gradients are smooth
- [ ] Text is readable at small sizes
- [ ] Icons work on both light and dark backgrounds
- [ ] All required sizes are generated
- [ ] Icons are properly placed in correct directories

## Testing
1. Build the app for each platform
2. Check icon appearance in:
   - App launcher
   - Taskbar/dock
   - Notifications
   - Settings
   - File manager

## Troubleshooting
- If icons appear blurry, ensure source SVG is high quality
- If colors are wrong, check SVG color definitions
- If icons don't appear, verify file paths and names
- If gradients are missing, ensure SVG gradients are properly defined
