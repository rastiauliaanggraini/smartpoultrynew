
# Project Blueprint

## Overview

This document outlines the plan for creating a Flutter application for "Smart Poultry" with a professional user interface, Firebase authentication, and intuitive navigation.

## Style and Design

- **Theme**: Modern, clean, and professional.
- **Color Palette**: 
  - Primary: A deep blue (`#1B3D6D`)
  - Accent: A vibrant yellow (`#FFD700`) for calls-to-action.
  - Background: A light off-white (`#F5F5F5`).
- **Typography**: `google_fonts` will be used for a clean and readable look. `Lato` for body text and `Montserrat` for headings.
- **Logo**: A placeholder logo for "Smart Poultry" will be added.
- **Layout**: Centered, single-column layout for login and registration forms for easy usability.

## Implemented Features

- Basic anonymous Firebase Authentication.
- Simple routing between a login and home screen.

## Current Plan: Professional Login & Registration

### 1. Add Dependencies
- Add `google_fonts` for custom typography.

### 2. Update `pubspec.yaml`
- Declare the `assets/images/` directory for the app logo.

### 3. Create Asset Directory and Logo
- Create the `assets/images` directory.
- Add a placeholder logo image to `assets/images/logo.png`.

### 4. Redesign Login Screen (`lib/login_screen.dart`)
- **UI Overhaul**:
    - Add the app logo.
    - Implement the new color scheme and typography.
    - Use `Card` widgets for a "lifted" feel.
    - Add distinct text fields for email and password.
- **Functionality**:
    - Implement Firebase email/password sign-in logic.
    - Add a "Forgot Password?" option (initially as a placeholder).
    - Add a "Don't have an account? Sign Up" button to navigate to the registration screen.
    - Include robust error handling and user feedback.

### 5. Create Registration Screen (`lib/registration_screen.dart`)
- **UI**:
    - Consistent design with the login screen (logo, colors, fonts).
    - Text fields for email, password, and password confirmation.
- **Functionality**:
    - Implement Firebase email/password account creation.
    - Add password strength validation.
    - Navigate to the home screen upon successful registration.

### 6. Update `main.dart`
- **Routing**: Add a new route for `/register`.
- **Authentication Redirect**: Implement a redirect in `GoRouter`.
    - If a user is not logged in, they will be redirected to the `/` (login) route, even if they try to access `/home`.
    - If a user is already logged in, they will be redirected to `/home` when they visit the `/` route.

### 7. Refine Home Screen (`lib/home_screen.dart`)
- Update the welcome message to display the user's email address for a more personalized experience.
