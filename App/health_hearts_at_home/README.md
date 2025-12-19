# health_hearts_at_home

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


my backend should have this 

GET    /api/children              - List all children for user
POST   /api/children              - Create new child
GET    /api/children/:id          - Get specific child
PUT    /api/children/:id          - Update child info
DELETE /api/children/:id          - Delete child

GET    /api/tracking/:childId     - Get all tracking entries for child
POST   /api/tracking              - Add new tracking entry
PUT    /api/tracking/:id          - Update tracking entry
DELETE /api/tracking/:id          - Delete tracking entry

GET    /api/content               - Get content items
GET    /api/content?category=tutorials&language=en - Filter by category

GET    /api/hospital-info         - Get hospital information
GET    /api/contacts              - Get all contacts
