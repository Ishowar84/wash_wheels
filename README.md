# WashWheels

WashWheels is a cross-platform application built with Flutter that serves as a marketplace connecting car owners with car wash service providers. The app supports two distinct user roles: customers who can book services, and providers who manage their services and schedules.

## Core Features

### For Customers
-   **User Authentication:** Secure sign-up and login for car owners.
-   **Service Booking:** A streamlined flow to book a car wash by selecting a service package, provider, location, and time.
-   **Real-time Availability:** Check provider availability before confirming a booking to avoid scheduling conflicts.
-   **Booking Management:** View a comprehensive list of upcoming and past bookings with their statuses (Pending, Confirmed, Completed, etc.).
-   **Marketplace:** Browse and view car care products.
-   **Profile Management:** View account details like email and account type.

### For Service Providers
-   **User Authentication:** Secure sign-up and login for service providers.
-   **Request Management:** View and accept or decline new booking requests from customers.
-   **Interactive Schedule:** Manage and view confirmed appointments on a daily and monthly calendar powered by `table_calendar`.
-   **Profile Management:** View account details.

## Technical Stack

-   **Framework:** Flutter
-   **Backend & Database:** Firebase (Authentication, Cloud Firestore)
-   **State Management:** `flutter_bloc` / `Cubit` for predictable and scalable state management.
-   **Cloud Functions:** A `functions` directory is set up for future backend logic using Firebase Functions.
-   **Platform Support:** Configured for Android, iOS, and Web.

## Project Structure
The core application logic resides in the `lib` directory, organized as follows:

-   **`lib/auth/`**: Contains all authentication-related UI (Login, Signup, Role Selection) and state management (`AuthCubit`, `RoleCubit`).
-   **`lib/core/`**: Defines core application components, including data models (`User`, `Booking`, `ServicePackage`) and global theme settings.
-   **`lib/features/`**: Houses the primary feature modules, divided by user role for clear separation of concerns.
    -   `customer/`: Screens and business logic for the customer experience, including the booking flow, bookings list, and marketplace.
    -   `provider/`: Screens and business logic for the service provider, primarily schedule management.
    -   `common/`: Shared widgets and pages used by both roles, such as the `ProfilePage`.
-   **`lib/main.dart`**: The main entry point of the application, responsible for initializing Firebase, setting up Bloc providers, and defining the primary `AuthWrapper` for routing.

## Getting Started

To run this project locally, follow these steps.

### Prerequisites
-   Flutter SDK installed on your machine.
-   An active Firebase project.

### 1. Clone the Repository
```bash
git clone https://github.com/ishowar84/wash_wheels.git
cd wash_wheels
```

### 2. Firebase Configuration
This project is configured to use Firebase. You will need to connect it to your own Firebase project.

1.  Create a project on the [Firebase Console](https://console.firebase.google.com/).
2.  Follow the official [FlutterFire documentation](https://firebase.flutter.dev/docs/cli) to use the FlutterFire CLI to configure your app. This will automatically generate a `lib/firebase_options.dart` file and configure the native projects.
3.  Ensure your `android/app/google-services.json` and `ios/Runner/GoogleService-Info.plist` files are correctly placed and configured for their respective platforms.

### 3. Install Dependencies
Run the following command to fetch all the required packages.
```bash
flutter pub get
```

### 4. Run the Application
Connect a device or start an emulator and run the app.
```bash
flutter run
