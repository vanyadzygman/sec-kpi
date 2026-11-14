# Аудит

## Топ-3 розбіжності (діаграма ↔ spec ↔ попередні моделі)

### A1. UC-05 мав двох виконавців

- **Що не так:** у Modules UC-05 «Перевірити вільні місця» був за `BookingService`, а операція `freeSeats` за `ScheduleService`. Це суперечило AC-7 (кожен UC має рівно одного виконавця). До того ж `freeSeats` потребує кількості `Booking`, а ними володіє `BookingRepository`.
- **Проти чого:** spec ↔ Завдання 2 (UC-05) ↔ Завдання 3 (`freeSeats`).
- **Виправлення через spec:** UC-05 віддано `ScheduleService`, додано `IBookingRepository.countBySession`, залежність записано в Allowed dependencies і позначено припущенням (AC-12).
- **Коміт spec:** `bf14430`.

### A2. REQ-16 і REQ-18 не мали виконавця

- **Що не так:** вимоги lab2 просять хоча б одного `Trainer` при створенні заняття (REQ-16) і відмітку відвідування лише тренером цього заняття (REQ-18). В інтерфейсах не було операції, яка це перевіряє, а `createSession` не приймав тренерів.
- **Проти чого:** spec ↔ вимоги й Gherkin lab2 (REQ-16, REQ-18).
- **Виправлення через spec:** `IScheduleService` отримав `isTrainerOfSession` і `createSession` з переліком тренерів, позначено припущенням (AC-12).
- **Коміт spec:** `bf14430`.

### A3. Діаграма не рендерилась

- **Що не так:** у першому коді діаграми псевдонім `UI` збігався з назвою `package "UI"`, PlantUML видав помилку синтаксису в рядку 10.
- **Проти чого:** діаграма ↔ spec.
- **Виправлення через spec:** AC-13, псевдоніми унікальні й не збігаються з назвами пакетів. Діаграму перегенеровано новим промтом, без ручної правки.
- **Коміт spec:** `b2948a3`.

Крім того, AC-5 суперечив власному переліку залежностей (виклики між сервісами всередині одного шару). Його переписано в `bf14430`, перелік дозволених залежностей додано в spec.

Діаграму перегенеровано новим промтом (`ai/03-regen-prompt.md`, коміт `d14815a`), результат у `467fdf4`, рендер у `1a550e0`. Ручних правок діаграми без зміни spec немає.

## Трасування: компоненти до попередніх моделей

- **Дані (Завдання 1):** `ClientRepository` це `Client`, `ScheduleRepository` це `TrainingSession` і `Trainer`, `BookingRepository` це `Booking`, `SubscriptionRepository` це `Subscription` і `MembershipPlan`. Усі 6 сутностей закріплені, жодної без компонента.
- **Вимоги й UC (Завдання 2):** кожен UC-01…UC-13 має одного виконавця: `ClientService` (UC-01), `ScheduleService` (UC-02, UC-05, UC-10), `BookingService` (UC-03, UC-06, UC-11, UC-12), `SubscriptionService` (UC-04, UC-07, UC-13), `PaymentAdapter` (UC-08), `NotificationService` (UC-09).
- **Взаємодія (Завдання 3):** `hasActive` це `ISubscriptionService`, `exists` і `create` це `IBookingRepository`, `freeSeats` це `IScheduleService`, `getEmail` це `IClientService`, `sendConfirmation` це `INotificationService`. Назви збігаються символ у символ.
- **Процес (Завдання 4):** купівля проходить через `SubscriptionService`, `PaymentAdapter` (результати `Confirmed`, `Declined`, `NoResponse`) і `NotificationService`. `SubscriptionService` перетворює `Declined` на `Rejected(PAYMENT_DECLINED)`, а `NoResponse` на `Rejected(PAYMENT_UNKNOWN)`.

## Трасування: інтерфейси

- `IGymApi`: надає `Gym API`, потребує `Web UI`.
- `IClientService`: надає `ClientService`, потребують `Gym API`, `BookingService`, `SubscriptionService`.
- `IScheduleService`: надає `ScheduleService`, потребують `Gym API`, `BookingService`.
- `IBookingService`: надає `BookingService`, потребує `Gym API`.
- `ISubscriptionService`: надає `SubscriptionService`, потребують `Gym API`, `BookingService`.
- `IPaymentService`: надає `PaymentAdapter`, потребує `SubscriptionService`.
- `INotificationService`: надає `NotificationService`, потребують `BookingService`, `SubscriptionService`.
- `IBookingRepository`: надає `BookingRepository`, потребують `BookingService`, `ScheduleService`.
- Решта репозиторних інтерфейсів, `IDatabase`, `IPaymentGateway`, `IEmailSending`: по одному провайдеру й споживачу, інтерфейсів без пари немає.

## Межа системи

`Payment Gateway` і `Email Service` розташовані поза `Gym System` як зовнішні інтеграції, інших зовнішніх систем немає (AC-2, AC-9).

## Топ-3 помилки виходу AI

### E1. Конфлікт псевдонімів у PlantUML

- **Помилка:** псевдонім `UI` збігається з назвою пакета, діаграма не рендериться.
- **Промт:** `ai/02-diagram-prompt.md`, відповідь `ai/02-diagram-response.md` (коміт `95a9c2d`).
- **Фідбек і виправлення:** AC-13 (`b2948a3`), перегенерація в `ai/03-regen-response.md` (`d14815a`).

### E2. Двоє виконавців для UC-05

- **Помилка:** у spec, який склав AI, UC-05 був за `BookingService`, а `freeSeats` за `ScheduleService`.
- **Промт:** `ai/01-gap-analysis-prompt.md`, відповідь `ai/01-gap-analysis-response.md`, питання 1 (коміт `96d1e4e`).
- **Фідбек і виправлення:** рішення в `ai/01-gap-analysis-decisions.md` (`f314270`), spec `bf14430`.

### E3. AC-5 суперечив переліку залежностей

- **Помилка:** AC-5 вимагав залежностей лише згори вниз, а сервіси викликають один одного в межах шару (`BookingService` потребує `ISubscriptionService` та інших).
- **Промт:** `ai/01-gap-analysis-prompt.md`, відповідь `ai/01-gap-analysis-response.md`, питання 7 (коміт `96d1e4e`).
- **Фідбек і виправлення:** AC-5 переписано, додано розділ Allowed dependencies та ADR (`bf14430`, `a32ac00`).

## Недоліки, залишені навмисно

- Рендер дуже широкий (4173×1187), нотатки з операціями відсунуті праворуч від діаграми. Окремого критерію читабельності в spec немає.
- Автентифікація, керування `Trainer`, одночасні записи на останнє місце: у вимогах lab2 цього немає, зафіксовано в «Out of scope and assumptions» у `spec.md`.
