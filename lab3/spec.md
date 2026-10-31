# Spec: Взаємодія (Sequence Diagrams), UC-03 «Записатися на заняття»

## Intent

Показати, що відбувається всередині системи, коли `Client` записується на `TrainingSession` (UC-03 із Завдання 2). Розглядаємо лише цей UC і його сценарії, а не всю систему.

## Scenarios

Сценарії беремо з Gherkin Завдання 2 (`lab2/scenarios/`).

| Діаграма | Сценарій Gherkin | Результат                                           |
| -------- | ---------------- | --------------------------------------------------- |
| D1       | SC-05            | запис створено                                      |
| D2       | SC-15            | запис створено, лист надіслано                      |
| D3       | SC-17            | запис створено, лист не вдався, `Booking` лишається |
| D4       | SC-06            | відмова: у клієнта немає жодного `Subscription`     |
| D5       | SC-07            | відмова: `Subscription` прострочений                |
| D6       | SC-09            | відмова: повторний запис                            |
| D7       | SC-08            | відмова: немає вільних місць                        |

Кожен сценарій має власну діаграму. SC-06 і SC-07 різняться даними: у SC-06 у клієнта немає жодного `Subscription`, а в SC-07 він є, але `endDate` минув. На діаграмах D4 і D5 це показано поясненням (`note`) біля повідомлення `hasActive`.

## Participants

Учасники відповідають сутностям lab1 і зовнішній системі з lab2:

| Учасник             | Тип              | Звідки                                               |
| ------------------- | ---------------- | ---------------------------------------------------- |
| `Client` (actor)    | актор            | людина, що викликає запис (сутність `Client` у lab1) |
| `BookingService`    | компонент        | керує сценарієм запису (UC-03)                       |
| `Subscription`      | сутність         | lab1, перевірка активного абонемента (UC-04)         |
| `TrainingSession`   | сутність         | lab1, перевірка вільних місць (UC-05)                |
| `Booking`           | сутність         | lab1, перевірка повтору й створення запису           |
| `Client` (сутність) | сутність         | lab1, джерело `email` для листа                      |
| `Email Service`     | зовнішня система | lab2, лист-підтвердження (UC-09)                     |

## Steps

Порядок перевірок у `BookingService.bookSession(clientId, sessionId)`: активний `Subscription` (REQ-05), потім повторний запис (REQ-07), потім вільні місця (REQ-06).

1. `Client` (actor) викликає `BookingService.bookSession(clientId, sessionId)`.
2. `BookingService` перевіряє `Subscription.hasActive(clientId)`. Якщо `false`, повертає `Rejected(NO_ACTIVE_SUBSCRIPTION)` (D4: `Subscription` немає, D5: `endDate` минув).
3. `BookingService` перевіряє `Booking.exists(clientId, sessionId)`. Якщо `true`, повертає `Rejected(ALREADY_BOOKED)` (D6).
4. `BookingService` запитує `TrainingSession.freeSeats(sessionId)`. Якщо 0, повертає `Rejected(NO_FREE_SEATS)` (D7).
5. `BookingService` створює `Booking.create(clientId, sessionId)` з `bookedAt` = поточний момент і `attended` = false (D1).
6. `BookingService` отримує `Client.getEmail(clientId)` і ініціює `EmailService.sendConfirmation(email)`. Результат листа не змінює результат запису (REQ-14): надіслано (D2) або не вдалося, і `Booking` лишається (D3).
7. `BookingService` повертає `Client` (actor) результат: `BookingConfirmed(bookingId)` або `Rejected(reason)`, де `reason` це `NO_ACTIVE_SUBSCRIPTION`, `ALREADY_BOOKED` або `NO_FREE_SEATS`.

## Acceptance criteria

- AC-1: кожна діаграма відповідає одному рядку таблиці Scenarios, і кроки збігаються з Gherkin.
- AC-2: учасники діаграм збігаються з таблицею Participants, назви сутностей з `lab1/spec.md` символ у символ.
- AC-3: у кожній діаграмі є хоча б один фрагмент `alt`, `opt` або `loop`. У D1 це `alt` за результатом перевірок.
- AC-4: у кожній діаграмі є повідомлення виклику й `return`, а також `activate`/`deactivate`.
- AC-5: activation bar `BookingService` починається до умовного фрагмента й закінчується після нього, а не обривається в одній гілці.
- AC-6: назви викликів виглядають як реальні методи (`hasActive()`, `freeSeats()`) і збігаються з розділом Steps.
- AC-7: порядок перевірок із розділу Steps однаковий на всіх діаграмах.
- AC-8: збій Email Service не змінює результат запису (REQ-14).
- AC-9: кожен сценарій Gherkin із таблиці Scenarios має власну діаграму.
- AC-10: результати `return` збігаються з типами з кроку 7 розділу Steps.

## Out of scope and assumptions

- Перевірка існування `clientId` і `sessionId`, а також запис на заняття, що вже почалося: у Gherkin Завдання 2 цього немає, тому не моделюємо.
- Одночасні записи на останнє місце: гонку між перевіркою `freeSeats` і `Booking.create` не моделюємо. Правило lab1 (число `Booking` не перевищує `capacity`) вважаємо гарантованим на рівні даних.
- Порядок перевірок (абонемент, повтор, місця): у Gherkin кожен сценарій перевіряє одну умову, тому порядок у комбінаціях умов обрано в spec.
