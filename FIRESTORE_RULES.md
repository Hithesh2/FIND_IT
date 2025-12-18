# Firestore Security Rules for Find It App

Update your Firestore rules with the following to fix the permission error:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Protect Users so only the owner can edit
    match /Users/{userId} {
      allow read, write: if request.auth != null &&
                         request.auth.uid == userId;
    }

    // ChatRooms collection - allow authenticated users to read/write
    match /ChatRooms/{chatId} {
      // Allow read if user is a participant
      allow read: if request.auth != null &&
                  (resource.data.participant1Id == request.auth.uid ||
                   resource.data.participant2Id == request.auth.uid);
      
      // Allow create if user is a participant
      allow create: if request.auth != null &&
                     (request.resource.data.participant1Id == request.auth.uid ||
                      request.resource.data.participant2Id == request.auth.uid);
      
      // Allow update if user is a participant
      allow update: if request.auth != null &&
                     (resource.data.participant1Id == request.auth.uid ||
                      resource.data.participant2Id == request.auth.uid);
      
      // Messages subcollection
      match /messages/{messageId} {
        // Allow read if user is a participant in the parent chat room
        allow read: if request.auth != null &&
                    (get(/databases/$(database)/documents/ChatRooms/$(chatId)).data.participant1Id == request.auth.uid ||
                     get(/databases/$(database)/documents/ChatRooms/$(chatId)).data.participant2Id == request.auth.uid);
        
        // Allow create if user is the sender
        allow create: if request.auth != null &&
                       request.resource.data.senderId == request.auth.uid;
        
        // Allow update if user is the sender or receiver
        allow update: if request.auth != null &&
                       (resource.data.senderId == request.auth.uid ||
                        resource.data.receiverId == request.auth.uid);
      }
    }

    // LostItems and FoundItems collections - allow authenticated users to read/write
    match /LostItems/{itemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                     request.resource.data.reportedBy == request.auth.uid;
      allow delete: if request.auth != null && 
                     resource.data.reportedBy == request.auth.uid;
    }

    match /FoundItems/{itemId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                     request.resource.data.reportedBy == request.auth.uid;
      allow delete: if request.auth != null && 
                     resource.data.reportedBy == request.auth.uid;
    }

    // Default rule for any other collections (if needed)
    match /{collection}/{docId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## How to Update Firestore Rules

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Firestore Database** → **Rules** tab
4. Replace the existing rules with the rules above
5. Click **Publish**

## What These Rules Do

- **Users Collection**: Only the owner can read/write their own user data
- **ChatRooms Collection**: 
  - Users can only read chat rooms where they are a participant
  - Users can create chat rooms where they are a participant
  - Users can update chat rooms where they are a participant
- **Messages Subcollection**:
  - Users can read messages in chat rooms where they are a participant
  - Users can create messages (as sender)
  - Users can update their own messages or messages sent to them
- **LostItems/FoundItems**: 
  - All authenticated users can read
  - All authenticated users can create
  - Only the reporter can update/delete their own items

