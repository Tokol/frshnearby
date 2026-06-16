# FreshNearby

FreshNearby is a modern local food marketplace prototype that connects nearby customers with farmers and small producers. Farmers can list available products, manage stock, accept order requests, track fulfillment, and review sales insights. Customers can discover farms, follow producers, request products, track order progress, and leave optional reviews after delivery.

This repository contains a public FreshNearby website and the working Flutter prototype. The website introduces the idea, explains the farmer/customer value, and links into the prototype section.

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

## Website Structure

The root route is a polished landing experience before the app:

- Hero: Fresh food, directly from local producers.
- Who we are: A short story about connecting communities and farms.
- What we do: Explain listings, requests, fulfillment, and trust.
- For farmers: Stock, orders, farm page, insights.
- For customers: Discovery, cart, order tracking, reviews.
- Why it matters: Local food, producer visibility, less friction.
- Prototype section: Link into the working Flutter demo.
- Roadmap: farmer-first market pages, customer onboarding, local trust, logistics, and regional supply chain growth.

## Tech Stack

- Flutter
- Dart
- Riverpod for state management
- GoRouter for routing
- Flutter localization for English, Finnish, and Swedish
- Shared preferences for local prototype settings
- Mock repositories for current prototype data

Planned product direction:

- Farmer-first tools that feel like a simple digital market stand.
- Customer onboarding around trusted farms, repeat orders, and transparent status.
- A local supply chain that connects demand, stock, pickup, courier delivery, and reviews.

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
/#/
/#/prototype
/#/farmer/dashboard
/#/customer/home
/#/customer/farmers/farmer-1
/#/customer/deals
```

The public website lives at `/#/`. The prototype entry point is `/#/prototype`.

## GitHub Pages

This repository includes a GitHub Actions workflow:

```text
.github/workflows/flutter-web.yml
```

On every push to `main`, it:

- checks out the repository
- installs Flutter
- runs `flutter pub get`
- runs `flutter gen-l10n`
- builds Flutter web with `--base-href /frshnearby/`
- deploys `build/web` to GitHub Pages

In GitHub, enable Pages with:

```text
Settings -> Pages -> Source -> GitHub Actions
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

- Start farmer-first with a simple market stand farmers can share anywhere.
- Onboard nearby customers into trusted farm pages and repeat ordering.
- Build a local food ecosystem where demand, stock and orders stay visible.
- Grow pickup and courier flows into a FreshNearby supply chain.
- Scale region by region with stronger farm identity, reviews and insights.
- Add deeper sales reporting once real farmer usage creates meaningful data.

## Status

FreshNearby is an active prototype focused on validating the farmer and customer experience before backend integration.
