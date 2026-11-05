# Activity 13 – Firebase Authentication in Flutter

**Course:** MAD 4360 – Mobile App Development  
**Student Name:** Akshitha Sainath Sanagarapu  
**Student ID:** 003027780  
**Track:** Graduate

## About the Project

For this activity, I worked on adding Firebase Authentication to a Flutter application. Instead of starting with a completely new project, I built on my previous Firebase Product Manager app from Activity 12.

The main goal was to allow users to create an account, sign in securely, view their profile, change their password, and sign out. I also wanted to make sure the app responded properly to invalid inputs and authentication errors.

I kept the existing Product Manager functionality and made it accessible from the profile screen after signing in.

## Features Implemented

- **Account Registration:** Users can create an account using their email address and password.
- **User Login:** Registered users can sign in with their credentials.
- **Profile Screen:** After signing in, users can view their registered email address.
- **Password Update:** Users can change their password after confirming their current password.
- **Logout:** Users can securely sign out and return to the login screen.
- **Input Validation:** The app checks email formatting, required fields, password length, and password confirmation.
- **Error Handling:** Firebase authentication errors are displayed through understandable messages.
- **Loading Indicators:** Buttons show progress while authentication requests are being processed.
- **Authentication State:** The app uses Firebase authentication state changes to determine which screen to display.

The Product Manager from Activity 12 is also included, with options to add, edit, delete, search, and filter products stored in Cloud Firestore.

## Tools and Technologies

- Flutter and Dart
- Firebase Authentication
- Firebase Core
- Cloud Firestore
- Android Studio and Pixel 10 Emulator
- Git and GitHub

## Project Structure

| File | Purpose |
|---|---|
| `lib/main.dart` | Initializes Firebase and starts the application |
| `lib/firebase_options.dart` | Stores the FlutterFire configuration |
| `lib/services/auth_service.dart` | Handles registration, login, logout, and password changes |
| `lib/screens/auth_gate.dart` | Determines which screen to display based on authentication status |
| `lib/screens/authentication_screen.dart` | Contains the login and registration forms |
| `lib/screens/profile_screen.dart` | Displays user information and account actions |
| `lib/screens/product_screen.dart` | Contains the existing Product Manager functionality |

## How to Run the Application

1. Clone the repository to your computer.
2. Open the project in VS Code or Android Studio.
3. Make sure Flutter and the Android development tools are installed.
4. Configure Firebase for the application and enable Email/Password authentication.
5. Install the dependencies:

   `flutter pub get`

6. Start an Android emulator and run:

   `flutter run`

An internet connection is required for Firebase Authentication and Firestore operations.

## Testing and Results

I ran the application using the Pixel 10 Android emulator and checked the main authentication features.

| Test Performed | Result |
|---|---|
| Register a new account | Passed |
| Sign in using registered credentials | Passed |
| Display registered email on the profile | Passed |
| Sign out and return to login | Passed |
| Update the account password | Passed |
| Attempt login using the previous password | Correctly rejected |
| Sign in using the updated password | Passed |
| Run `flutter analyze` | No issues found |
| Build release APK | Successful |

The old-password test was especially useful because it helped confirm that the password update was actually applied in Firebase rather than simply displaying a success message.

Additional cases, including session restoration after restarting the app and invalid form submissions, remain useful checks.

## Security Considerations

One important part of this activity was understanding the difference between authentication and authorization.

Firebase Authentication verifies the user's identity, while authorization determines which resources that user can access.

The app uses an authentication gate to control navigation to the profile screen. Password changes also require the user to reauthenticate using their current password.

For an application handling private user data, Firestore security rules would also need to enforce appropriate access restrictions. Protecting a screen in Flutter alone is not enough to secure the database.

## Building the APK

I generated the Android release APK using:

`flutter build apk --release`

The build completed successfully. The submission file is named:

`Activity13_Sanagarapu_Akshitha.apk`

The APK will be submitted separately along with the GitHub repository and activity documentation.

## AI Assistance

I used ChatGPT while developing this activity to help organize the authentication flow and identify important test scenarios.

I reviewed the implementation through Flutter static analysis and hands-on testing on the Android emulator. The graduate activity report provides more detail about the AI-assisted design, decisions, testing results, and limitations.

## Conclusion

Through this activity, I gained practical experience integrating Firebase Authentication into a Flutter application. I learned how registration, login, authentication state management, and password updates work together.

Building on my previous Product Manager app also helped me understand how authentication can be added to an existing application without removing its original functionality.