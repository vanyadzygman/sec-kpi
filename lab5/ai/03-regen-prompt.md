Перегенеруй UML component diagram у PlantUML за оновленою специфікацією. Попередня версія не відрендерилась: помилка синтаксису в рядку 10 (component "Web UI" as UI), бо псевдонім UI збігається з назвою package "UI". Це порушує AC-13.

Специфікація:

# Spec: Архітектура (Component Diagram), система спортзалу

## Intent

Описати архітектуру системи спортзалу компонентною діаграмою: компоненти, інтерфейси, залежності, межа системи й зовнішні інтеграції. Кожен компонент і кожна залежність трасується до попередніх моделей: даних (Завдання 1), вимог і UC (Завдання 2), взаємодії (Завдання 3) і процесу (Завдання 4).

## System boundary

Межа системи: `Gym System`. Усередині: UI, API, сервіси, доступ до даних і база. Поза межею, як зовнішні інтеграції, лише два актори-системи із Завдання 2: `Payment Gateway` і `Email Service`.

## Modules

Шари: UI, API, сервіси, Data Access, база даних.

- UI: `Web UI`, інтерфейс для `Client`, `Trainer` і `Administrator`.
- API: `Gym API`, єдина точка входу для UI. Перевіряє роль актора (`Client`, `Trainer`, `Administrator`, `Staff`) перед викликом сервісу.
- Сервіси (кожен UC має рівно одного виконавця):
  - `ClientService`: реєстрація й дані клієнта (UC-01, `getEmail`).
  - `ScheduleService`: розклад, вільні місця, створення занять, перевірка тренера заняття (UC-02, UC-05, UC-10).
  - `BookingService`: запис, скасування, список записаних, відмітка відвідування (UC-03, UC-06, UC-11, UC-12).
  - `SubscriptionService`: купівля абонемента, перевірка активного, типи абонементів (UC-04, UC-07, UC-13).
  - `PaymentAdapter`: обробка оплати через зовнішній шлюз, розпізнає відсутність відповіді (UC-08).
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
- `IScheduleService` (`getSchedule`, `createSession` з переліком тренерів, `freeSeats`, `isTrainerOfSession`): надає `ScheduleService`, потребують `Gym API`, `BookingService`.
- `IBookingService` (`bookSession`, `cancelBooking`, `getRoster`, `markAttendance`): надає `BookingService`, потребує `Gym API`.
- `ISubscriptionService` (`purchase`, `hasActive`, `createPlan`): надає `SubscriptionService`, потребують `Gym API`, `BookingService`.
- `IPaymentService` (`requestPayment`, повертає `Confirmed(amount)`, `Declined` або `NoResponse`): надає `PaymentAdapter`, потребує `SubscriptionService`.
- `INotificationService` (`sendConfirmation`): надає `NotificationService`, потребують `BookingService`, `SubscriptionService`.
- `IClientRepository`: надає `ClientRepository`, потребує `ClientService`.
- `IScheduleRepository`: надає `ScheduleRepository`, потребує `ScheduleService`.
- `IBookingRepository` (`exists`, `create`, `countBySession`): надає `BookingRepository`, потребують `BookingService`, `ScheduleService`.
- `ISubscriptionRepository`: надає `SubscriptionRepository`, потребує `SubscriptionService`.
- `IPaymentGateway`: надає зовнішній `Payment Gateway`, потребує `PaymentAdapter`.
- `IEmailSending`: надає зовнішній `Email Service`, потребує `NotificationService`.
- `IDatabase`: надає `Gym Database`, потребують усі репозиторії.

## Allowed dependencies between services

Сервіси залежать лише від інтерфейсів, цикли заборонені. Дозволені залежності:

- `BookingService` потребує `ISubscriptionService`, `IScheduleService`, `IClientService`, `INotificationService`, `IBookingRepository`.
- `SubscriptionService` потребує `IClientService`, `IPaymentService`, `INotificationService`, `ISubscriptionRepository`.
- `ScheduleService` потребує `IScheduleRepository`, `IBookingRepository` (лише `countBySession` для `freeSeats`).
- `ClientService`, `PaymentAdapter`, `NotificationService` залежать лише від свого репозиторію або зовнішнього шлюзу.

## Traceability

- Дані (lab1): усі 6 сутностей закріплені за репозиторіями, жодна не лишилась без компонента.
- Взаємодія (lab3): виклики `BookingService.bookSession` лягають на інтерфейси так: `Subscription.hasActive` це `ISubscriptionService.hasActive`, `Booking.exists` це `IBookingRepository.exists`, `TrainingSession.freeSeats` це `IScheduleService.freeSeats`, `Booking.create` це `IBookingRepository.create`, `Client.getEmail` це `IClientService.getEmail`, `EmailService.sendConfirmation` це `INotificationService.sendConfirmation`.
- Процес (lab4): купівля абонемента проходить через `SubscriptionService`, `PaymentAdapter` (три результати оплати) і `NotificationService` (лист). `SubscriptionService` перетворює `Declined` на `Rejected(PAYMENT_DECLINED)`, а `NoResponse` на `Rejected(PAYMENT_UNKNOWN)`.
- Вимоги (lab2): кожен UC-01…UC-13 має одного виконавця (див. розділ Modules). REQ-16 і REQ-18 виконують `createSession` і `isTrainerOfSession`.

## Out of scope and assumptions

- Автентифікація (OAuth, Identity): у вимогах lab2 цього немає. Роль актора перевіряє `Gym API`, а як актор підтверджує свою роль, не моделюємо.
- SMS і інші канали повідомлень: у lab2 лише листи.
- Одночасні записи на останнє місце: `freeSeats` і `create` лишаються окремими викликами (як у lab3), гонку не моделюємо й вважаємо, що правило `capacity` гарантує `Gym Database`.
- Керування самими `Trainer` (створення, зміна): у lab2 немає UC.
- Технології, розгортання, протоколи.

## Acceptance criteria

- AC-1: архітектуру описано однією компонентною діаграмою (PlantUML), без другої нотації.
- AC-2: межа системи `Gym System` показана явно, `Payment Gateway` і `Email Service` розташовані поза нею.
- AC-3: усі компоненти з розділу Modules присутні на діаграмі, шари UI, API, сервіси, Data Access і база розрізнювані.
- AC-4: кожен інтерфейс з розділу Interfaces має рівно одного провайдера (provided) і хоча б одного споживача (required), інтерфейсів без пари немає.
- AC-5: залежності між шарами йдуть згори вниз (UI, API, сервіси, Data Access, база). Залежності сервіс-сервіс існують лише через інтерфейси й лише з розділу Allowed dependencies, циклів немає.
- AC-6: кожна з 6 сутностей lab1 (`Client`, `Trainer`, `TrainingSession`, `MembershipPlan`, `Booking`, `Subscription`) закріплена за одним репозиторієм.
- AC-7: кожен UC-01…UC-13 має рівно одного виконавця серед сервісів.
- AC-8: операції на діаграмі збігаються з Завданням 3 і Завданням 4 символ у символ (`hasActive`, `exists`, `freeSeats`, `getEmail`, `sendConfirmation`, `bookSession`, `create`).
- AC-9: зовнішні інтеграції збігаються з акторами-системами lab2: `Payment Gateway` і `Email Service`, інших немає.
- AC-10: назви сутностей збігаються з `lab1/spec.md` символ у символ.
- AC-11: результати `requestPayment` (`Confirmed`, `Declined`, `NoResponse`) покривають усі три виходи оплати із Завдання 4.
- AC-12: кожне припущення, якого немає у вимогах lab2 (перевірка ролі в `Gym API`, `countBySession`, `isTrainerOfSession`), позначено на діаграмі нотаткою.
- AC-13: код діаграми валідний для PlantUML: псевдоніми компонентів і інтерфейсів унікальні й не збігаються з назвами `package`. Діаграма успішно рендериться.

Попередній код:

@startuml
skinparam linetype ortho
skinparam defaultFontSize 12
skinparam dpi 150
top to bottom direction

rectangle "Gym System" {

package "UI" {
component "Web UI" as UI
}

package "API" {
component "Gym API" as GymAPI
interface IGymApi
}

package "Services" {
component "ClientService" as ClientService
component "ScheduleService" as ScheduleService
component "BookingService" as BookingService
component "SubscriptionService" as SubscriptionService
component "PaymentAdapter" as PaymentAdapter
component "NotificationService" as NotificationService

    interface IClientService
    interface IScheduleService
    interface IBookingService
    interface ISubscriptionService
    interface IPaymentService
    interface INotificationService

}

package "Data Access" {
component "ClientRepository" as ClientRepository
component "ScheduleRepository" as ScheduleRepository
component "BookingRepository" as BookingRepository
component "SubscriptionRepository" as SubscriptionRepository

    interface IClientRepository
    interface IScheduleRepository
    interface IBookingRepository
    interface ISubscriptionRepository

}

package "Database" {
database "Gym Database" as DB
interface IDatabase
}
}

component "Payment Gateway" as PG <<external>>
component "Email Service" as ES <<external>>
interface IPaymentGateway
interface IEmailSending

' provided interfaces
GymAPI - IGymApi
ClientService - IClientService
ScheduleService - IScheduleService
BookingService - IBookingService
SubscriptionService - ISubscriptionService
PaymentAdapter - IPaymentService
NotificationService - INotificationService
ClientRepository - IClientRepository
ScheduleRepository - IScheduleRepository
BookingRepository - IBookingRepository
SubscriptionRepository - ISubscriptionRepository
DB - IDatabase
PG - IPaymentGateway
ES - IEmailSending

' required interfaces: UI and API
UI ..> IGymApi
GymAPI ..> IClientService
GymAPI ..> IScheduleService
GymAPI ..> IBookingService
GymAPI ..> ISubscriptionService

' required interfaces: services
BookingService ..> ISubscriptionService
BookingService ..> IScheduleService
BookingService ..> IClientService
BookingService ..> INotificationService
BookingService ..> IBookingRepository

SubscriptionService ..> IClientService
SubscriptionService ..> IPaymentService
SubscriptionService ..> INotificationService
SubscriptionService ..> ISubscriptionRepository

ScheduleService ..> IScheduleRepository
ScheduleService ..> IBookingRepository

ClientService ..> IClientRepository

PaymentAdapter ..> IPaymentGateway
NotificationService ..> IEmailSending

' required interfaces: data access
ClientRepository ..> IDatabase
ScheduleRepository ..> IDatabase
BookingRepository ..> IDatabase
SubscriptionRepository ..> IDatabase

' assumptions (AC-12)
note right of GymAPI
Перевіряє роль актора перед викликом сервісу.
припущення, немає у вимогах lab2
end note

note right of IScheduleService
getSchedule, createSession, freeSeats,
isTrainerOfSession
припущення (isTrainerOfSession),
немає у вимогах lab2
end note

note right of IBookingRepository
exists, create, countBySession
припущення (countBySession),
немає у вимогах lab2
end note

note right of IPaymentService
requestPayment повертає:
Confirmed(amount), Declined, NoResponse
end note

note right of ISubscriptionService
purchase, hasActive, createPlan
end note

note right of IClientService
register, getEmail
end note

note right of IBookingService
bookSession, cancelBooking,
getRoster, markAttendance
end note

note right of INotificationService
sendConfirmation
end note
@enduml

Вимоги ті самі, що в попередньому промті (межа Gym System, шари UI, API, Services, Data Access, Database, зовнішні Payment Gateway і Email Service поза межею, provided через lollipop, required через залежності, залежності лише з Allowed dependencies, notes про припущення за AC-12, три результати requestPayment), плюс:

- Усі псевдоніми унікальні й не збігаються з назвами package та між собою. Для Web UI використай псевдонім WebUI, для бази DB.
- Назви package лиши, але не використовуй їх як псевдоніми компонентів.
- Не використовуй конструкцій, у яких не впевнений, що вони валідні в PlantUML. Мета: код, що рендериться без помилок.
  Віддай лише код діаграми.
