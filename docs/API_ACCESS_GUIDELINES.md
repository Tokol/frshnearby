# API Access Guidelines

These rules apply to all Flutter-to-backend calls in FRSH Nearby.

## Authentication

Flutter must send the Firebase ID token in the request header:

```http
Authorization: Bearer <firebase_id_token>
```

The backend verifies this token with Firebase Admin and reads the secure UID from the decoded token. Do not send `uid`, `firebaseUid`, or `userId` in a normal request body to identify the current user.

Correct:

```graphql
mutation CreateListing($input: CreateListingInput!) {
  createListing(input: $input) { id }
}
```

The backend uses the decoded token UID to find the actor.

Avoid:

```graphql
mutation CreateListing($input: CreateListingInput!) {
  createListing(input: { userId: "some-user-id", ... }) { id }
}
```

Client-provided user IDs can be forged. Only admin-only APIs should accept a target user ID, and those APIs must be protected by admin guards.

## Token Refresh

Firebase ID tokens are short-lived. Flutter stores:

- `auth_token`: current Firebase ID token.
- `refresh_token`: Firebase refresh token.

When an API request returns `401`, `ApiClient` asks the auth repository to refresh the ID token, updates the `Authorization` header, and retries the request once.

If refresh fails, Flutter clears the local auth tokens and the user must sign in again.

## Adding New Flutter API Calls

Use `ApiClient.postGraphQL` for GraphQL requests:

```dart
final response = await apiClient.postGraphQL<Map<String, dynamic>>(
  r'''
  query Session {
    session {
      user { id email }
    }
  }
  ''',
);
```

This keeps token refresh behavior consistent for future requests.

## Backend Rules

Backend resolvers should:

- Use `FirebaseAuthGuard` for user-specific APIs.
- Read the current user from the verified token/session.
- Ignore client-provided current-user IDs.
- Accept target user IDs only for guarded admin operations.
- Return `401` when the auth token is missing, invalid, expired, or revoked.
