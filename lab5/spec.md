# Spec: Архітектура (Component Diagram), система спортзалу

## Intent

Описати архітектуру системи спортзалу компонентною діаграмою: компоненти, інтерфейси, залежності, межа системи й зовнішні інтеграції. Кожен компонент і кожна залежність трасується до попередніх моделей: даних (Завдання 1), вимог і UC (Завдання 2), взаємодії (Завдання 3) і процесу (Завдання 4).

## System boundary

Межа системи: `Gym System`. Усередині: UI, API, сервіси, доступ до даних і база. Поза межею, як зовнішні інтеграції, лише два актори-системи із Завдання 2: `Payment Gateway` і `Email Service`.

## Modules

Шари: UI, API, сервіси, Data Access, база даних.

- UI: `Web UI`, інтерфейс для `Client`, `Trainer` і `Administrator`.
- API: `Gym API`, єдина точка входу для UI.
- Сервіси:
  - `ClientService`: реєстрація й дані клієнта (UC-01, `getEmail`).
  - `ScheduleService`: розклад, створення занять, вільні місця (UC-02, UC-10, `freeSeats`).
  - `BookingService`: запис, скасування, список записаних, відмітка відвідування (UC-03, UC-05, UC-06, UC-11, UC-12).
  - `SubscriptionService`: купівля абонемента, перевірка активного, типи абонементів (UC-04, UC-07, UC-13, `hasActive`).
  - `PaymentAdapter`: обробка оплати через зовнішній шлюз (UC-08).
  - `NotificationService`: листи-підтвердження через зовнішній сервіс (UC-09).
- Data Access (репозиторії):
  - `ClientRepository`: сутність `Client`.
  - `ScheduleRepository`: сутності `TrainingSession` і `Trainer`.
  - `BookingRepository`: сутність `Booking`.
  - `SubscriptionRepository`: сутності `Subscription` і `MembershipPlan`.
- База: `Gym Database`, зберігає всі 6 сутностей lab1.

## Interfaces

Кожен інтерфейс має одного провайдера (provided) і хоча б одного споживача (required).

- `IGymApi`: надає `Gym API`, потребує `Web UI`.
- `IClientService` (`register`, `getEmail`): надає `ClientService`, потребують `Gym API`, `BookingService`, `SubscriptionService`.
- `IScheduleService` (`getSchedule`, `createSession`, `freeSeats`): надає `ScheduleService`, потребують `Gym API`, `BookingService`.
- `IBookingService` (`bookSession`, `cancelBooking`, `getRoster`, `markAttendance`): надає `BookingService`, потребує `Gym API`.
- `ISubscriptionService` (`purchase`, `hasActive`, `createPlan`): надає `SubscriptionService`, потребують `Gym API`, `BookingService`.
- `IPaymentService` (`requestPayment`): надає `PaymentAdapter`, потребує `SubscriptionService`.
- `INotificationService` (`sendConfirmation`): надає `NotificationService`, потребують `BookingService`, `SubscriptionService`.
- `IClientRepository`, `IScheduleRepository`, `IBookingRepository` (`exists`, `create`), `ISubscriptionRepository`: надають відповідні репозиторії, потребує відповідний сервіс.
- `IPaymentGateway`: надає зовнішній `Payment Gateway`, потребує `PaymentAdapter`.
- `IEmailSending`: надає зовнішній `Email Service`, потребує `NotificationService`.
- `IDatabase`: надає `Gym Database`, потребують усі репозиторії.

## Traceability

- Дані (lab1): усі 6 сутностей закріплені за репозиторіями, жодна не лишилась без компонента.
- Взаємодія (lab3): виклики `BookingService.bookSession` лягають на інтерфейси так: `Subscription.hasActive` це `ISubscriptionService.hasActive`, `Booking.exists` це `IBookingRepository.exists`, `TrainingSession.freeSeats` це `IScheduleService.freeSeats`, `Client.getEmail` це `IClientService.getEmail`, `EmailService.sendConfirmation` це `INotificationService.sendConfirmation`.
- Процес (lab4): купівля абонемента проходить через `SubscriptionService`, `PaymentAdapter` (оплата) і `NotificationService` (лист).
- Вимоги (lab2): кожен UC-01…UC-13 має компонент-виконавця (див. розділ Modules).

## Out of scope and assumptions

- Автентифікація й ролі доступу (OAuth, Identity): у вимогах lab2 цього немає, тому не моделюємо.
- SMS і інші канали повідомлень: у lab2 лише листи.
- Технології, розгортання, протоколи.

## Acceptance criteria

- AC-1: архітектуру описано однією компонентною діаграмою (PlantUML), без другої нотації.
- AC-2: межа системи `Gym System` показана явно, `Payment Gateway` і `Email Service` розташовані поза нею.
- AC-3: усі компоненти з розділу Modules присутні на діаграмі, шари UI, API, сервіси, Data Access і база розрізнювані.
- AC-4: кожен інтерфейс з розділу Interfaces має рівно одного провайдера (provided) і хоча б одного споживача (required), інтерфейсів без пари немає.
- AC-5: залежності йдуть згори вниз за шарами (UI, API, сервіси, Data Access, база), сервіси залежать один від одного лише через інтерфейси, циклічних залежностей немає.
- AC-6: кожна з 6 сутностей lab1 (`Client`, `Trainer`, `TrainingSession`, `MembershipPlan`, `Booking`, `Subscription`) закріплена за одним репозиторієм.
- AC-7: кожен UC-01…UC-13 має компонент, що його виконує.
- AC-8: операції на діаграмі збігаються з Завданням 3 і Завданням 4 символ у символ (`hasActive`, `exists`, `freeSeats`, `getEmail`, `sendConfirmation`, `bookSession`, `create`).
- AC-9: зовнішні інтеграції збігаються з акторами-системами lab2: `Payment Gateway` і `Email Service`, інших немає.
- AC-10: назви сутностей збігаються з `lab1/spec.md` символ у символ.
