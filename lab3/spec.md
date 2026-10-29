# Spec: Взаємодія (Sequence Diagrams), UC-03 «Записатися на заняття»

## Intent

Показати, що відбувається всередині системи, коли `Client` записується на `TrainingSession` (UC-03 із Завдання 2). Розглядаємо лише цей UC і його сценарії, а не всю систему.

## Scenarios

Сценарії беремо з Gherkin Завдання 2 (`lab2/scenarios/`). Сценарії з однаковим потоком об'єднано в одну діаграму.

| Діаграма | Сценарії Gherkin    | Результат                                         |
| -------- | ------------------- | ------------------------------------------------- |
| D1       | SC-05, SC-15, SC-17 | запис створено, лист надіслано або лист не вдався |
| D2       | SC-06, SC-07        | відмова: немає активного `Subscription`           |
| D3       | SC-09               | відмова: повторний запис                          |
| D4       | SC-08               | відмова: немає вільних місць                      |

SC-06 (жодного `Subscription`) і SC-07 (прострочений) мають однаковий потік: перевірка повертає «немає активного». Тому вони разом на D2.

## Participants

Учасники відповідають сутностям lab1 і зовнішній системі з lab2:

| Учасник           | Тип              | Звідки                                       |
| ----------------- | ---------------- | -------------------------------------------- |
| `Client`          | актор            | сутність `Client`                            |
| `BookingService`  | компонент        | керує сценарієм запису (UC-03)               |
| `Subscription`    | сутність         | lab1, перевірка активного абонемента (UC-04) |
| `TrainingSession` | сутність         | lab1, перевірка вільних місць (UC-05)        |
| `Booking`         | сутність         | lab1, створення запису                       |
| `Email Service`   | зовнішня система | lab2, лист-підтвердження (UC-09)             |

## Steps

Порядок перевірок у `BookingService.book(clientId, sessionId)`: активний `Subscription` (REQ-05), потім повторний запис (REQ-07), потім вільні місця (REQ-06).

1. `Client` викликає `bookSession(clientId, sessionId)`.
2. `BookingService` перевіряє `Subscription.hasActive(clientId)`. Якщо ні, повертає відмову (D2).
3. `BookingService` перевіряє `Booking.exists(clientId, sessionId)`. Якщо так, повертає відмову (D3).
4. `BookingService` запитує `TrainingSession.freeSeats(sessionId)`. Якщо 0, повертає відмову (D4).
5. `BookingService` створює `Booking.create(clientId, sessionId)` з `bookedAt` = поточний момент і `attended` = false (D1).
6. `BookingService` ініціює `EmailService.sendConfirmation(email)`. Збій листа не скасовує `Booking` (REQ-14).
7. `BookingService` повертає `Client` підтвердження.

## Acceptance criteria

- AC-1: кожна діаграма відповідає одному рядку таблиці Scenarios, і кроки збігаються з Gherkin.
- AC-2: учасники діаграм збігаються з таблицею Participants, назви сутностей з `lab1/spec.md` символ у символ.
- AC-3: у кожній діаграмі є хоча б один фрагмент `alt`, `opt` або `loop`.
- AC-4: у кожній діаграмі є повідомлення виклику й `return`, а також `activate`/`deactivate`.
- AC-5: activation bar `BookingService` починається до умовного фрагмента й закінчується після нього, а не обривається в одній гілці.
- AC-6: назви викликів виглядають як реальні методи (`hasActive()`, `freeSeats()`).
- AC-7: порядок перевірок із розділу Steps однаковий на всіх діаграмах.
- AC-8: збій Email Service не змінює результат запису (REQ-14).
