# Firebase Realtime Database Rules – Fix "Permission Denied" for Ombudsperson Complaint

If you see **"Error saving complaint"** or **"firebase_database permission denied"** when saving an Ombudsperson complaint, your Realtime Database security rules are blocking writes to the `complaints` path. Apply the rules below.

## Option A: Apply rules in Firebase Console (recommended)

1. Open [Firebase Console](https://console.firebase.google.com/) and select project **legal-sathi-f6009**.
2. In the left menu, go to **Build → Realtime Database**.
3. Open the **Rules** tab.
4. Replace the entire rules JSON with the contents of **`database.rules.json`** in this project (or copy from below).
5. Click **Publish**.

### Rules to use (copy-paste)

```json
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null && auth.uid == $uid",
        ".write": "auth != null && auth.uid == $uid"
      }
    },
    "complaints": {
      ".read": "auth != null && query.orderByChild == 'userId' && query.equalTo == auth.uid",
      "$complaintId": {
        ".read": "auth != null && data.child('userId').val() == auth.uid",
        ".write": "auth != null && newData.child('userId').val() == auth.uid"
      }
    }
  }
}
```

What this does:
- **users**: Only the signed-in user can read/write their own `users/<uid>` data (login/profile).
- **complaints**: Only signed-in users can create/update complaints where `userId` is their own `auth.uid`; they can only read complaints that belong to them.

## Option B: Deploy rules with Firebase CLI

From the project root (`fyp-project-code`):

```bash
firebase deploy --only database
```

(Make sure you have run `firebase login` and selected the correct project.)

---

After publishing the rules, try saving the Ombudsperson complaint again. The user must be **signed in** (not guest); guest users have no `auth.uid`, so they cannot write to `complaints`.
