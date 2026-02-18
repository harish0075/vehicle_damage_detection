# Firestore Security Rules - Copy these to Firebase Console

## Problem
If detections aren't saving to Firestore, your security rules might be blocking writes.

## Solution

Go to Firebase Console → Firestore Database → Rules and update to:

```
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Allow users to read/write their own detection data
    match /users/{userId}/detections/{detection} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Allow users access to their user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Testing Authentication

To check if you're logged in, look for these debug messages in the console:

**When saving:**
- ✅ `📝 Saving detection to Firestore...` - Save attempt started
- ✅ `User ID: <some-id>` - User is authenticated
- ✅ `✅ Detection saved successfully` - Save completed
- ❌ `User not logged in` - Sign in required

**When loading:**
- ✅ `📖 Loading detections for user: <id>` - Loading attempts
- ✅ `📦 Loaded X detections` - Shows count
- ❌ `⚠️ No user logged in` - Sign in required

## Quick Fix: Enable Anonymous Authentication

If Google Sign-In isn't working yet:

1. Go to Firebase Console → Authentication
2. Click "Sign-in method"
3. Enable "Anonymous" provider
4. In the app, tap "Continue Anonymously"

This will allow you to test the save functionality while Google Sign-In is being configured.
