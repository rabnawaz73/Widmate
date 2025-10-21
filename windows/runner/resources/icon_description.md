# Windows App Icon for WidMate

## Required Files:
- app_icon.ico (Windows icon file)
- app_icon.ico (16x16, 32x32, 48x48, 64x64, 128x128, 256x256)

## Generation Instructions:
1. Use the SVG file from assets/icons/app_icon.svg
2. Export as ICO file with multiple sizes
3. Place in windows/runner/Resources/ directory
4. Update windows/runner/main.cpp to reference the icon

## Icon Usage:
- Used for Windows taskbar
- Used for Windows start menu
- Used for Windows file explorer
- Used for Windows notifications
