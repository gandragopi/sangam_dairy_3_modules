# Implementation Plan: Advanced E-commerce Features for Sangam Dairy Backend

This plan outlines the addition of advanced features requested for the Sangam Dairy backend: Profile & Addresses, Subscriptions, Delivery Calendar, Offers & Deals, Wallet & Loyalty, Referral, and Notifications.

## User Review Required

> [!NOTE]
> All new entities will be designed to integrate seamlessly with the existing H2 (local) and PostgreSQL (production) database configurations using Spring Data JPA.

## Proposed Changes

### [Entities & Repositories]

#### [NEW] [Address.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/Address.java)
- Entity representing saved delivery addresses for customers.

#### [NEW] [Subscription.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/Subscription.java)
- Entity for recurring milk/dairy product delivery subscriptions (frequency, start date, status).

#### [NEW] [DeliverySchedule.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/DeliverySchedule.java)
- Entity for tracking daily delivery calendar schedules.

#### [NEW] [Offer.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/Offer.java)
- Entity for promotional discount codes and deals.

#### [NEW] [WalletTransaction.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/WalletTransaction.java)
- Entity for user wallet balance and loyalty reward points transactions.

#### [NEW] [Referral.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/Referral.java)
- Entity for tracking user referrals and rewards.

#### [NEW] [Notification.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/entity/Notification.java)
- Entity for user notifications.

---

### [Controllers]

#### [NEW] [ProfileController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/ProfileController.java)
- Endpoints for managing user profiles and addresses (`/api/users`, `/api/addresses`).

#### [NEW] [SubscriptionController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/SubscriptionController.java)
- Endpoints for managing dairy subscriptions (`/api/subscriptions`).

#### [NEW] [DeliveryController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/DeliveryController.java)
- Endpoints for delivery calendar schedule (`/api/deliveries`).

#### [NEW] [OfferController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/OfferController.java)
- Endpoints for promotional offers (`/api/offers`).

#### [NEW] [WalletController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/WalletController.java)
- Endpoints for wallet and loyalty points (`/api/wallet`).

#### [NEW] [ReferralController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/ReferralController.java)
- Endpoints for referral tracking (`/api/referrals`).

#### [NEW] [NotificationController.java](file:///C:/Users/penky/StudioProjects/sangam_dairy_backend/src/main/java/com/sangam/sangamdairybackend/controller/NotificationController.java)
- Endpoints for notifications (`/api/notifications`).

## Verification Plan

### Automated Tests
- Run `./mvnw.cmd test` to verify application context loading and entity mappings.

### Manual Verification
- Verify endpoints via H2 console or Postman/Flutter app integration.
