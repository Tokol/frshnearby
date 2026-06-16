# FreshNearby

FreshNearby is a modern local food marketplace prototype that connects nearby customers with farmers and small producers. Farmers can list available products, manage stock, accept order requests, track fulfillment, and review sales insights. Customers can discover farms, follow producers, request products, track order progress, and leave optional reviews after delivery.

This repository currently contains the working Flutter prototype. A full public website can sit in front of it later with sections for who we are, what we do, farmers, customers, and a dedicated prototype entry point.

## Prototype Scope

FreshNearby is intentionally built as a realistic prototype rather than a static mockup. The app uses in-memory/mock data today, but the flows are structured to be replaced with Supabase or another backend later.

Current prototype features:

- Farmer dashboard with active orders, monthly sales, all-time sales, and shareable farm page.
- Product listing creation and editing with stock, price, product details, photos, pickup notes, and multilingual product dictionary.
- Public farm profile with follow/unfollow, product selection, cart, pickup/courier options, and request flow.
- Farmer order book grouped by order request, with accept, decline, ready, delivered, notes, and timestamps.
- Customer order history with milestone timeline, timestamps, payment authorization messaging, and delivery status.
- Optional customer rating and written review after delivery.
- Farmer-side visibility into customer reviews from completed order history.
- Farmer insights with date range reports, sales trend, top products, fulfillment split, and sales statement.
- English, Finnish, and Swedish language switching.
- Mobile-first UI with a quick prototype switch between farmer and consumer views.

## Product Idea

FreshNearby helps local producers sell directly without making order handling complicated.

For farmers:

- List products with price and available quantity.
- Share a public farm page link.
- Receive customer order requests.
- Accept or decline requests.
- Automatically reduce stock after acceptance.
- Mark orders ready and delivered.
- See monthly and custom-range sales insights.
- Track reviews from completed orders.

For customers:

- Browse nearby fresh listings.
- Follow farms.
- Add products to cart.
- Choose pickup or courier delivery.
- Pay/request in one flow.
- Track order milestones.
- Leave an optional review after delivery.

## Planned Website Structure

The public website can be added as a polished landing experience before the app:

- Hero: Fresh food, directly from local producers.
- Who we are: A short story about connecting communities and farms.
- What we do: Explain listings, requests, fulfillment, and trust.
- For farmers: Stock, orders, farm page, insights.
- For customers: Discovery, cart, order tracking, reviews.
- Why it matters: Local food, producer visibility, less friction.
- Prototype section: Link into the working Flutter demo.
- Roadmap: Supabase, real payments, courier integration, verification, analytics.

## Tech Stack

- Flutter
- Dart
- Riverpod for state management
- GoRouter for routing
- Flutter localization for English, Finnish, and Swedish
- Shared preferences for local prototype settings
- Mock repositories for current prototype data

Planned backend direction:

- Supabase for authentication, database, storage, and realtime updates.
- Payment authorization flow integration.
- Courier service integration.

## Getting Started

Install dependencies:

```bash
flutter pub get
```

Run the prototype on a local web server:

```bash
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5173
```

Open:

```text
http://127.0.0.1:5173
```

Useful prototype routes:

```text
/#/farmer/dashboard
/#/customer/home
/#/customer/farmers/farmer-1
/#/customer/deals
```

## Localization

FreshNearby currently supports:

- English
- Finnish
- Swedish

Localization files are in:

```text
lib/core/l10n/
```

After editing localization files, regenerate generated localization classes:

```bash
flutter gen-l10n
```

## Project Structure

```text
lib/
  core/
    l10n/
    router/
    theme/
    widgets/
  features/
    auth/
    catalog/
    customer/
    customer_marketplace/
    deals/
    farmer/
    listings/
    settings/
    shared/
```

Important prototype files:

```text
lib/features/catalog/data/product_dictionary.dart
lib/features/farmer/presentation/farmer_dashboard_screen.dart
lib/features/farmer/presentation/farmer_deals_screen.dart
lib/features/farmer/presentation/farmer_insights_screen.dart
lib/features/customer_marketplace/presentation/farmer_public_profile_screen.dart
lib/features/customer/presentation/customer_deals_screen.dart
```

## Prototype Notes

This project is not production-ready yet. Current limitations:

- Data is stored in mock/in-memory repositories.
- Authentication is prototype-level.
- Payments are simulated as authorization states.
- Courier delivery is calculated in-app, not connected to a real courier API.
- Farmer verification is represented in the UI but not backed by a live admin workflow.

## Roadmap

- Connect Supabase authentication and database.
- Add realtime stock and order updates.
- Add Supabase storage for farm, cover, and product images.
- Replace mock payment authorization with real payment provider integration.
- Add courier partner dispatch and tracking.
- Add farmer verification/admin dashboard.
- Add public marketing website with a prototype section.
- Improve desktop/web responsive layouts.
- Add production analytics and exportable sales reports.

## Status

FreshNearby is an active prototype focused on validating the farmer and customer experience before backend integration.
