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

## Relationships

- `Client` 1 — N `Booking` (`makes`): клієнт має 0 або більше записів, кожен запис належить рівно одному клієнту.
- `TrainingSession` 1 — N `Booking` (`receives`): на заняття може бути 0 або більше записів, кожен запис стосується рівно одного заняття.
- `Client` 1 — N `Subscription` (`buys`): клієнт має 0 або більше покупок абонементів, кожна покупка належить рівно одному клієнту.
- `MembershipPlan` 1 — N `Subscription` (`is purchased as`): тип абонемента куплено 0 або більше разів, кожна покупка стосується рівно одного типу.
- `Trainer` M — N `TrainingSession` (`leads`): тренер веде 0 або більше занять, на занятті є щонайменше один тренер. Зв'язок не має власних атрибутів.

## Acceptance criteria

- AC-1: кожна сутність має PK `id` типу `int`; усі FK теж `int`.
- AC-2: `Trainer` ↔ `TrainingSession` показано прямим зв'язком M:N, без сполучної сутності чи таблиці.
- AC-3: асоціативні сутності є лише там, де зв'язок має власні атрибути: `Booking` і `Subscription`.
- AC-4: кардинальності на діаграмі збігаються з розділом Relationships.
- AC-5: назви сутностей, полів і типів на діаграмі збігаються зі spec символ у символ.
- AC-6: модель у 3НФ: жоден неключовий атрибут не залежить від іншого неключового атрибута тієї ж сутності.
- AC-7: `endDate` зберігається навмисно: період дії покупки фіксується на момент купівлі й не змінюється, якщо потім зміниться `durationDays` плану.
- AC-8: діаграма не містить фізичної схеми (SQL, ORM).
- AC-9: правила, які діаграмою не виразити, записано тут: пара (`clientId`, `sessionId`) у `Booking` унікальна; кількість записів на заняття не перевищує `capacity`; `endDate` не раніше `startDate`.
- AC-10: кожен зв'язок на діаграмі має назву зі spec (у дужках у Relationships); усі назви різні.
- AC-11: ключі на діаграмі позначаються так: `PK` (первинний), `FK` (зовнішній), `UK` (унікальний атрибут, наразі лише `Client.email`).
- AC-12: правила з AC-9 дубльовано в `model.mmd` коментарями `%%` (по одному рядку на правило), щоб їх було видно поруч із моделлю.
