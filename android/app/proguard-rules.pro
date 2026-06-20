# Stripe PaymentSheet — optional push provisioning classes (not used in this app)
-dontwarn com.stripe.android.pushProvisioning.**

# Local notifications (release APK)
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class androidx.core.app.NotificationManagerCompat** { *; }
