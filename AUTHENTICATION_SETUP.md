# Authentication Setup with Supabase

## Overview

The AIVO app now includes proper authentication with Supabase and optional login.

## Key Changes

### 1. **Optional Login**
- Users can now access the app without signing in (as guests)
- Login/Sign Up options are available when users want to create an account

### 2. **Navigation Flow**
```
Splash Screen
├── "Continue as Guest" → Home Screen (without authentication)
└── "Sign In" → Login/Sign Up
    └── After success → Home Screen (with authentication)
```

### 3. **Settings Screen**
- Displays "Sign In" button if user is not authenticated
- Displays current user email and "Sign Out" button if user is authenticated

### 4. **Authentication Service**
- Located at: `lib/services/auth_service.dart`
- Provides methods for:
  - `signUp()` - Create new account
  - `signIn()` - Login to existing account
  - `signOut()` - Logout
  - `isAuthenticated()` - Check if user is logged in
  - `getCurrentUser()` - Get current user
  - `getCurrentUserEmail()` - Get current user email

## Setup Instructions

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Create a new project
3. Note your **Project URL** and **Anon Key**

### 2. Update Configuration
Edit `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

### 3. Enable Email Authentication (Optional but Recommended)
In Supabase Dashboard:
1. Go to Authentication → Providers
2. Enable Email/Password provider
3. Configure email templates if needed

### 4. Get Dependencies
```bash
flutter pub get
```

## Features

### Guest Access
- Users can browse products, view cart, and chat without logging in
- All features work for guests

### Authenticated Users
- Account management
- Order history
- Saved preferences
- Exclusive features

### Error Handling
- Invalid credentials → Show error message
- Network errors → Show error message
- Loading state → Show spinner during request

## Testing

### Test Account (After Setup)
You can create test accounts in Supabase Dashboard or through the app Sign Up screen.

### Test Credentials Example
```
Email: test@example.com
Password: testpassword123
```

## Security Notes

⚠️ **Important**: Never commit real Supabase credentials to version control!

For production, use environment variables or Firebase Config.

## Troubleshooting

### Problem: "Supabase not initialized"
**Solution**: Make sure you've updated `supabase_config.dart` with your real credentials

### Problem: "Sign in failed: User not found"
**Solution**: Create an account first using Sign Up, or use "Continue as Guest"

### Problem: App crashes on startup
**Solution**: Check that `SupabaseConfig` values are correct without trailing spaces

## Future Enhancements

- [ ] Social login (Google, Apple)
- [ ] Password reset
- [ ] Profile management
- [ ] Two-factor authentication
- [ ] Biometric authentication
