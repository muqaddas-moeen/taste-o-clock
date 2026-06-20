# Taste O'Clock


<p align="center">
  <img width="220"  alt="auth_screen" src="https://github.com/user-attachments/assets/1a6ace39-91ac-4df2-8d9a-8f3ad3d2833e" />
  <img width="220"  alt="menu_screen" src="https://github.com/user-attachments/assets/20d3f756-7c7e-449b-a6fd-7ac1dc82dc3a" />
  <img width="220"  alt="orders_screen" src="https://github.com/user-attachments/assets/94c4ac5f-27cc-4ee4-ba32-e1db65c5a5e3" />
  <img width="220"  alt="cart_screen" src="https://github.com/user-attachments/assets/4bf8f41a-21e8-4349-b96c-894820a51eb7" />
  <img width="220"  alt="checkout_screen" src="https://github.com/user-attachments/assets/2faa0640-1c6d-4d93-b80e-9c4f09bed3d9" />
    <img width="220" alt="add_payment_card_view" src="https://github.com/user-attachments/assets/40500d5b-02f3-4279-899b-d0de93ad1ce9" />
<img width="220" alt="track_order_screen_with_order_placed_status" src="https://github.com/user-attachments/assets/78f6c02a-6014-4865-9117-c543dceb6466" />
<img width="220" alt="track_order_screen_with_preparing_status" src="https://github.com/user-attachments/assets/5def2b3f-621d-4f87-b319-df060a389470" />
<img width="220"  alt="track_order_screen_with_delivered_status" src="https://github.com/user-attachments/assets/4fb2f298-0a69-4547-8554-70cc8052afb6" />
<img width="220" alt="profile_screen" src="https://github.com/user-attachments/assets/1606a892-4a8a-4050-a16e-fe5b82a78319" />
<img width="220" alt="profile_screen_with_location" src="https://github.com/user-attachments/assets/49139d8a-79fc-4fae-bc8e-2ac917676544" />
</p>




Flutter food delivery app with Firebase backend, local caching, Stripe card payments, and in-app notifications.

## Features

- Google Sign-In and session restore
- Product menu with categories, search, and offline cache
- Cart and checkout (cash on delivery or Stripe card)
- Order tracking with live Firestore updates
- Real-time in-app notifications with persistent local notification history and tracking.
- Profile: delivery location, payment preference, sign out

## Tech stack

- **Flutter** + **GetX** (state, routing, DI)
- **Firebase** Auth, Firestore, Cloud Messaging
- **Hive** local storage
- **Stripe** PaymentSheet via deployed payment API
- **ScreenUtil** responsive layout

## Project structure

```
lib/app/
  core/       config, errors, middleware, widgets, animations
  data/       models, services, repositories
  modules/    feature screens (auth, product, cart, checkout, order, …)
  routes/     GetX pages and route names
  theme/      colors, typography, decorations
  bindings/   global DI (InitialBinding)
```

Flow: **View → Controller → Repository → Service**

## Prerequisites

- Flutter SDK 3.x (project uses FVM optional)
- Firebase project with Android/iOS apps configured (`firebase_options.dart`)
- Stripe account (test mode is fine for demo)
- Deployed payment server for card checkout (see below)

## Setup

1. **Clone and install**

   ```bash
   flutter pub get
   ```

2. **Environment file**

   Copy `.env.example` to `.env` at the project root:

   ```bash
   cp .env.example .env
   ```

   Set your Stripe **publishable** key only:

   ```env
   STRIPE_PUBLISHABLE_KEY=pk_test_...
   ```

   Never put `sk_` secret keys in the app. The secret key lives on the payment server only.

3. **Firebase**
   - Add `google-services.json` (Android) and GoogleService-Info.plist (iOS) if not already present
   - Deploy Firestore rules: `firebase deploy --only firestore:rules`

4. **Payment server (card payments)**

   Card checkout calls a backend that creates Stripe PaymentIntents. The app is configured to use:

   `https://paymentserver-7q1hoy0b.b4a.run`

   Health check: `GET /health`  
   Payment intent: `POST /create-payment-intent`

   The server must have `STRIPE_SECRET_KEY` set (B4A or your host). The app publishable key must belong to the same Stripe account.

5. **Run**

   ```bash
   flutter run
   ```

   Use a full restart after changing `.env` (hot reload does not reload assets).

## Tests

```bash
flutter test
```

## Build release APK

```bash
flutter build apk --release
```

Ensure `.env` contains a valid `STRIPE_PUBLISHABLE_KEY` before building; it is bundled as an asset.

## Security notes

- Only Stripe **publishable** keys belong in `.env`; secret keys stay on the payment server.
- Firestore rules enforce user-scoped reads/writes and block client order status changes.
- Profile and checkout inputs are validated/sanitized before Firestore writes.
- FCM device tokens are stored on the user profile for server-side push only.

## Performance notes

- Product and cart images use memory-cache sizing to reduce decode cost.
- Lists use pagination, debounced search, and scoped `Obx` rebuilds in the cart tab.
- Run `flutter analyze` and `flutter test` before release builds.

## Notes for reviewers

- Main navigation uses a bottom tab shell: Menu, Orders, Cart, Profile
- Cash on delivery works without Stripe configuration
- Card payments require both a valid publishable key in `.env` and a running payment server
