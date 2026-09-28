# Spec: Gym domain

## Intent

Змоделювати дані спортзалу: клієнти купують абонементи й записуються на групові заняття, які проводять тренери.

## Entities and attributes

- `Client`: `id` (PK, int), `fullName` (string), `email` (string, unique), `phone` (string), `birthDate` (date)
- `Trainer`: `id` (PK, int), `fullName` (string), `specialization` (string)
- `TrainingSession`: `id` (PK, int), `title` (string), `startsAt` (datetime), `durationMin` (int), `capacity` (int)
- `MembershipPlan`: `id` (PK, int), `name` (string), `durationDays` (int), `price` (decimal)
- `Booking`: `id` (PK, int), `clientId` (FK, int), `sessionId` (FK, int), `bookedAt` (datetime), `attended` (boolean)
- `Subscription`: `id` (PK, int), `clientId` (FK, int), `planId` (FK, int), `startDate` (date), `endDate` (date), `paidAmount` (decimal)
