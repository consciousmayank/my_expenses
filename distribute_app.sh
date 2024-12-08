#!/bin/bash

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Firebase App ID - Replace this with your app ID
FIREBASE_APP_ID="1:257610787314:android:38ddce9dcb19916a8e236b"
GROUP_NAME="testers"
RELEASE_NOTES_FILE="release_notes.txt"

# Function to increment version
increment_version() {
    local version=$1
    local position=$2
    
    # Split version number into array
    IFS='.' read -ra VERSION_PARTS <<< "$version"
    
    # Increment the specified position
    case $position in
        "major")
            ((VERSION_PARTS[0]++))
            VERSION_PARTS[1]=0
            VERSION_PARTS[2]=0
            ;;
        "minor")
            ((VERSION_PARTS[1]++))
            VERSION_PARTS[2]=0
            ;;
        "patch")
            ((VERSION_PARTS[2]++))
            ;;
    esac
    
    # Join array back into string
    echo "${VERSION_PARTS[0]}.${VERSION_PARTS[1]}.${VERSION_PARTS[2]}"
}

# Check if release notes file exists, create if it doesn't
if [ ! -f "$RELEASE_NOTES_FILE" ]; then
    echo -e "${YELLOW}Creating release notes template...${NC}"
    cat > "$RELEASE_NOTES_FILE" << EOL
Version Updates:
- Feature: Add your new features here
- Fix: Add your bug fixes here
- Update: Add your updates here

Additional Notes:
- Add any additional notes here
EOL
    echo -e "${GREEN}Created $RELEASE_NOTES_FILE. Please update it with your release notes.${NC}"
    echo -e "${YELLOW}Please update the release notes and run the script again.${NC}"
    exit 0
fi

# Read release notes
if [ ! -s "$RELEASE_NOTES_FILE" ]; then
    echo -e "${RED}Release notes file is empty. Please add release notes to $RELEASE_NOTES_FILE${NC}"
    exit 1
fi

RELEASE_NOTES=$(<"$RELEASE_NOTES_FILE")

echo -e "${YELLOW}Starting app distribution process...${NC}"

# Update version in pubspec.yaml
echo -e "${YELLOW}Updating version number...${NC}"
CURRENT_VERSION=$(grep "version: " pubspec.yaml | sed 's/version: //')
NEW_VERSION=$(increment_version "$CURRENT_VERSION" "patch")
sed -i.bak "s/version: .*/version: $NEW_VERSION/" pubspec.yaml
rm pubspec.yaml.bak

echo -e "${GREEN}Version updated from $CURRENT_VERSION to $NEW_VERSION${NC}"

# Update release notes to include version and date
FINAL_RELEASE_NOTES="Version $NEW_VERSION - $(date '+%Y-%m-%d %H:%M')\n\n$RELEASE_NOTES"

# Check if firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Firebase CLI not found. Installing...${NC}"
    npm install -g firebase-tools
fi

# Ensure user is logged in to Firebase
echo -e "${YELLOW}Checking Firebase login status...${NC}"
firebase login --interactive

# Clean the project
echo -e "${YELLOW}Cleaning project...${NC}"
flutter clean

# Get dependencies
echo -e "${YELLOW}Getting dependencies...${NC}"
flutter pub get

# Build the release APK
echo -e "${YELLOW}Building release APK...${NC}"
flutter build apk --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo -e "${GREEN}Build successful!${NC}"
    
    # Upload to Firebase App Distribution
    echo -e "${YELLOW}Uploading to Firebase App Distribution...${NC}"
    firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" \
        --app "$FIREBASE_APP_ID" \
        --groups "$GROUP_NAME" \
        --release-notes "$FINAL_RELEASE_NOTES"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Upload successful! Your app has been distributed to the testers.${NC}"
        echo -e "${GREEN}Version: $NEW_VERSION${NC}"
        
        # Clear release notes file after successful distribution
        echo -e "${YELLOW}Clearing release notes for next update...${NC}"
        cat > "$RELEASE_NOTES_FILE" << EOL
Version Updates:
- Feature: Add your new features here
- Fix: Add your bug fixes here
- Update: Add your updates here

Additional Notes:
- Add any additional notes here
EOL
    else
        echo -e "${RED}Failed to upload to Firebase App Distribution.${NC}"
        exit 1
    fi
else
    echo -e "${RED}Build failed!${NC}"
    exit 1
fi
