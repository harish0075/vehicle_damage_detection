# Debugging: Detections Not Saving to Timeline

## Quick Checklist

When you tap "Save to Timeline", check the following in order:

### 1. Check if You're Signed In
**Look for this message in console/logs:**
- ❌ `User not logged in. Please sign in to save detections.`
  - **Fix:** Sign in using Google or Anonymous authentication

### 2. Check Firestore Rules
**Error message:** `[cloud_firestore/permission-denied]`
  - **Fix:** Update Firestore security rules (see FIRESTORE_RULES.md)

### 3. Check Save Process
**Look for these console messages:**
```
🔍 Attempting to save detection...
   Damages count: 2
   Image path: /path/to/image.jpg
   Image dimensions: 1920 x 1080
📝 Saving detection to Firestore...
   User ID: abc123xyz
   Damages: 2
   Image path: /path/to/image.jpg
✅ Detection saved successfully with ID: det_12345
```

**If you see:**
- ❌ `User not logged in` → Sign in first
- ❌ `permission-denied` → Fix Firestore rules
- ❌ Any other error → Check the error message

### 4. Check Timeline Loading
**After saving, look for:**
```
📖 Loading detections for user: abc123xyz
📦 Loaded 1 detections from Firestore
```

**If you see:**
- ⚠️ `No user logged in, returning empty stream` → Sign in first
- `Loaded 0 detections` → Detections might not be saving OR rules blocking reads

### 5. Test Authentication Status

Add this debug code temporarily to check user:

**In `damage_detection_screen.dart` before saving:**
```dart
import 'package:firebase_auth/firebase_auth.dart';

// Add inside _saveToTimeline before the try block:
final currentUser = FirebaseAuth.instance.currentUser;
print('Current user: ${currentUser?.uid}');
print('Is anonymous: ${currentUser?.isAnonymous}');
print('Email: ${currentUser?.email}');
```

## Common Issues & Solutions

### Issue: "Detection saved" but nothing in timeline

**Possible causes:**
1. **Firestore rules blocking reads** - Can write but can't read
2. **Timeline not refreshing** - Try switching tabs or restarting app
3. **User signed out** - Check authentication status

**Solution:**
```bash
# Check Firestore in Firebase Console
1. Go to Firestore Database
2. Navigate to: users → [your-uid] → detections
3. Check if documents exist
```

### Issue: No success or error message

**Cause:** Silent failure or exception not caught

**Solution:** Check console for ANY error messages

### Issue: Firebase says "insufficient permissions"

**Cause:** Firestore security rules are too restrictive

**Solution:**
```javascript
// In Firebase Console → Firestore → Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/detections/{detection} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Quick Test

1. **Make sure you're signed in** (check top of Timeline screen for logout button)
2. **Detect a damage**
3. **Tap "Save to Timeline"**
4. **Watch the console logs**
5. **Switch to Timeline tab**
6. **Look for the detection**

If still not working, check Flutter console output and share the error messages!
