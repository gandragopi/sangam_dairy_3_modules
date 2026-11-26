# Sangam Dairy Premium UI/UX Transformation

This plan outlines the complete visual transformation of the Sangam Dairy application into a premium, production-level UI while preserving all existing functionality, logic, and navigation.

## Goal
To elevate the visual design of the Sangam Dairy app to a "beautiful, premium" level using a light theme with the Sangam Dairy color palette (Green, Cream, Orange) and professional logo placement.

## User Review Required
> [!IMPORTANT]
> - All existing business logic, navigation flows, and features will remain UNTOUCHED.
> - The transformation will focus exclusively on visual elements: layouts, spacing, typography, cards, buttons, icons, animations, and responsiveness.
> - The theme will be a clean **Light Theme** throughout the entire application.

## Open Questions
- Are there any specific premium UI styles you prefer (e.g., Glassmorphism, Neumorphism, or Minimalistic Flat Design)? I will proceed with a **Modern Minimalist Premium** style unless otherwise specified.

## Proposed Changes

### Core UI & Theme
- [MODIFY] [app_theme.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/core/theme/app_theme.dart): Refine the light theme with professional typography (e.g., "Manrope" or "Poppins" if available, otherwise optimized system fonts), enhanced card elevations, and premium button styles.
- [MODIFY] [sangam_branding.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/widgets/sangam_branding.dart): Enhance branding widgets like `SangamLogo` and `SangamWatermark` for a more premium look.

### Splash & Authentication
- [MODIFY] [splash_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/splash/splash_screen.dart): Revamp the splash/intro screens with smooth animations, high-quality branding, and premium layouts.
- [MODIFY] [login_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/auth/login_screen.dart), [otp_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/auth/otp_screen.dart), [signup_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/auth/signup_screen.dart): Transform the authentication flow with modern, spacious inputs, clear visual hierarchy, and professional branding elements.

### Home & Discovery
- [MODIFY] [home_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/home/home_screen.dart): Redesign the home dashboard with premium product grids, modern category icons, refined banners, and a clean header.
- [MODIFY] [search_explore_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/search/search_explore_screen.dart): Optimize search functionality with premium layouts and better result presentation.
- [MODIFY] [categories_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/categories/categories_screen.dart), [category_products_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/categories/category_products_screen.dart): Enhance category browsing with clean grids and premium imagery presentation.

### Product & Transactions
- [MODIFY] [product_details_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/product/product_details_screen.dart): Create a luxurious product details view with smooth image transitions and clear CTA buttons.
- [MODIFY] [cart_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/cart/cart_screen.dart), [checkout_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/checkout/checkout_screen.dart), [payment_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/checkout/payment_screen.dart): Streamline the checkout experience with premium card summaries, clear progress indicators, and modern payment method selectors.
- [MODIFY] [order_success_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/orders/order_success_screen.dart): Add a delightful premium success animation and clear next steps.

### User Account & Specialized Features
- [MODIFY] [profile_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/profile/profile_screen.dart): Redesign the profile hub with premium list items, clean iconography, and professional branding.
- [MODIFY] [orders_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/orders/orders_screen.dart), [order_tracking_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/orders/order_tracking_screen.dart): Modernize order history and tracking with clean status timelines and premium detail cards.
- [MODIFY] [wallet_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/wallet/wallet_screen.dart), [subscriptions_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/subscriptions/subscriptions_screen.dart), [referral_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/referral/referral_screen.dart): Elevate these specialized screens with premium visualizations and focused layouts.
- [MODIFY] [notifications_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/notifications/notifications_screen.dart), [wishlist_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/wishlist/wishlist_screen.dart), [help_support_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/support/help_support_screen.dart): Polish these utility screens to match the overall premium aesthetic.

## Verification Plan

### Manual Verification
- Review every screen on mobile and desktop layout to ensure premium visual consistency.
- Verify that the Sangam Dairy logo and branding elements are correctly placed.
- Confirm that all existing features (cart, checkout, search, etc.) function exactly as before.
