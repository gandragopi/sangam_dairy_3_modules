# Sangam Dairy Premium UI Overhaul Plan

This plan outlines the complete visual transformation of the Sangam Dairy Flutter application into a premium, production-level UI with a clean light theme, while preserving all existing functionality and data.

## Goal Description
The objective is to upgrade the entire application's UI/UX from the Splash Screen to the final screen. We will use a consistent palette of Sangam Green, Cream, and Orange, with professional branding and modern design elements like rounded cards, subtle animations, and responsive layouts.

## User Review Required
> [!IMPORTANT]
> The overhaul will strictly follow the light theme requirement. This means some screens currently using dark backgrounds (like the Splash Screen) will be converted to a clean white/cream background with green/orange accents.

> [!NOTE]
> All existing logic, data, and navigation flows will remain untouched. The changes are purely visual and layout-related.

## Proposed Changes

### Core & Global Styling

#### [MODIFY] [app_theme.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/core/theme/app_theme.dart)
Define the centralized `AppTheme` with:
- `primaryColor`: Sangam Green (#087A35)
- `secondaryColor`: Accent Orange (#FFA817)
- `backgroundColor`: Light Greenish-White (#F8FAF7)
- `surfaceColor`: White
- `cardColor`: Cream (#FFF9EB)
- Premium `TextTheme` using modern sans-serif fonts.
- Unified `ButtonTheme` and `InputDecorationTheme`.

#### [NEW] [sangam_branding.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/widgets/sangam_branding.dart)
A set of reusable branding widgets:
- `SangamLogo`: Standardized logo widget.
- `SangamWatermark`: Subtle background branding element.
- `SangamCard`: Premium card wrapper with consistent shadows and border radius.

---

### Authentication Flow

#### [MODIFY] [splash_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/splash/splash_screen.dart)
- Transition from dark green to a premium white background.
- Use a large, high-resolution logo display.
- Modernize the onboarding carousel with clean typography and better spacing.

#### [MODIFY] [login_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/auth/login_screen.dart)
- Clean, focused layout with the logo at the top.
- Premium input fields and action buttons.
- Subtle background branding.

---

### Home & Discovery

#### [MODIFY] [home_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/home/home_screen.dart)
- Premium header with logo and user profile.
- Categorized sections with rounded cream cards.
- Improved product grid with better aspect ratios and spacing.

#### [MODIFY] [categories_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/categories/categories_screen.dart)
- Modern category list with custom icons/images.
- Consistent padding and alignment.

---

### Product & Cart

#### [MODIFY] [product_details_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/product/product_details_screen.dart)
- Large, clean product image display.
- Clear pricing and description layouts.
- Premium "Add to Cart" and "Subscribe" buttons.

#### [MODIFY] [cart_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/cart/cart_screen.dart)
- Modern list view for cart items.
- Clear summary section with cream background.
- Smooth transitions to checkout.

---

### Orders & Tracking

#### [MODIFY] [order_tracking_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/orders/order_tracking_screen.dart)
- Visual timeline for delivery status.
- Map integration (if any) styled to match the theme.
- Clear contact and delivery information.

---

### Profile & Account

#### [MODIFY] [profile_screen.dart](file:///C:/Users/penky/StudioProjects/sangam_dairy/lib/screens/profile/profile_screen.dart)
- Clean list of account options.
- User info section with a premium feel.
- Integrated wallet and referral views.

## Verification Plan

### Manual Verification
- **Visual Consistency:** Walk through every screen from Splash to Checkout to ensure theme consistency.
- **Responsiveness:** Test on mobile (Portrait) and Windows (Desktop window) to ensure layouts adapt gracefully.
- **Branding:** Verify the logo and watermark are used appropriately without cluttering.
- **Functionality Check:** Ensure all buttons, forms, and navigation items still work as intended.
