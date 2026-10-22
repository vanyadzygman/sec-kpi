Допоможи написати Gherkin-сценарії для системи спортзалу (Завдання 2 з курсу моделювання вимог).

Контекст. Актори: Client, Trainer, Administrator, Staff (узагальнення Trainer і Administrator), Payment Gateway (зовнішня система оплати), Email Service (зовнішня система листів). Визначення: активний абонемент це Subscription, де startDate ≤ сьогодні ≤ endDate; вільні місця = capacity мінус кількість Booking на заняття; скасування запису = видалення Booking; endDate = startDate + durationDays днів. У клієнта щонайбільше один активний Subscription одночасно.

Сутності з lab1 (назви брати символ у символ):

- Client: id, fullName, email (унікальний), phone, birthDate
- Trainer: id, fullName, specialization
- TrainingSession: id, title, startsAt, durationMin, capacity
- MembershipPlan: id, name, durationDays, price
- Booking: id, clientId, sessionId, bookedAt, attended
- Subscription: id, clientId, planId, startDate, endDate, paidAmount

Мої EARS-вимоги:

- REQ-01 WHEN відвідувач подає fullName та email, яких немає в жодного Client, система SHALL створити Client.
- REQ-02 IF email уже належить Client, THEN система SHALL відхилити реєстрацію.
- REQ-03 WHEN Client запитує розклад, система SHALL показати кожне TrainingSession з startsAt пізніше за поточний момент, із title, startsAt, durationMin і кількістю вільних місць.
- REQ-04 WHILE Client має активний Subscription, WHEN Client записується на TrainingSession з вільними місцями, система SHALL створити Booking з bookedAt = поточний момент і attended = false.
- REQ-05 IF Client не має активного Subscription, THEN система SHALL відхилити запис.
- REQ-06 IF кількість Booking на TrainingSession дорівнює capacity, THEN система SHALL відхилити запис.
- REQ-07 IF Booking з таким самим clientId і sessionId уже існує, THEN система SHALL відхилити повторний запис.
- REQ-08 WHEN Client скасовує Booking на TrainingSession, у якого startsAt пізніше за поточний момент, система SHALL видалити цей Booking.
- REQ-09 WHEN Client обирає MembershipPlan, система SHALL надіслати Payment Gateway запит на оплату суми price.
- REQ-10 WHEN Payment Gateway підтверджує оплату, система SHALL створити Subscription з startDate = поточна дата, endDate = startDate + durationDays днів і paidAmount = підтверджена сума.
- REQ-11 IF Payment Gateway відхиляє оплату, THEN система SHALL NOT створювати Subscription.
- REQ-12 WHEN створено Booking, система SHALL надіслати через Email Service лист-підтвердження на email відповідного Client.
- REQ-13 WHEN створено Subscription, система SHALL надіслати лист-підтвердження на email відповідного Client.
- REQ-14 IF Email Service не зміг надіслати лист, THEN система SHALL залишити створений Booking або Subscription чинним.
- REQ-15 WHEN Administrator створює TrainingSession, система SHALL зберегти title, startsAt, durationMin > 0 та capacity > 0.
- REQ-16 IF Administrator створює TrainingSession без жодного Trainer, THEN система SHALL відхилити створення.
- REQ-17 WHEN Staff відкриває список записаних на TrainingSession, система SHALL показати fullName кожного Client, який має Booking на це заняття.
- REQ-18 WHEN Trainer цього TrainingSession відмічає Client присутнім після startsAt, система SHALL встановити attended = true у відповідному Booking.
- REQ-19 Система SHALL NOT змінювати endDate існуючих Subscription, якщо змінилося durationDays у MembershipPlan.
- REQ-20 (нефункціональна, швидкість розкладу) навмисно НЕ покривається: для неї сценарій не пиши.

Мої use cases: UC-01 Зареєструватися; UC-02 Переглянути розклад; UC-03 Записатися на заняття (include UC-04 Перевірити активний абонемент, UC-05 Перевірити вільні місця); UC-06 Скасувати запис; UC-07 Купити абонемент (include UC-08 Обробити оплату); UC-09 Надіслати лист-підтвердження (extend для UC-03 і UC-07); UC-10 Створити заняття; UC-11 Переглянути список записаних; UC-12 Відмітити відвідування; UC-13 Створити тип абонемента.

Критерії з spec.md:

- AC-2: id сценаріїв у форматі SC-nn
- AC-3: назви сутностей і полів збігаються з lab1 символ у символ
- кожна група має хоча б один позитивний і один негативний сценарій

Завдання: напиши Gherkin-сценарії для REQ-01...REQ-19 у трьох файлах:

1. registration-and-booking.feature (REQ-01...REQ-08, UC-01...UC-06)
2. subscription-and-email.feature (REQ-09...REQ-14, UC-07...UC-09, а також REQ-19)
3. staff.feature (REQ-15...REQ-18, UC-10...UC-12)

Кожен сценарій: рядок з id і назвою (Scenario: SC-nn ...), над ним теги @REQ-xx та @UC-xx. Одна вимога може мати кілька сценаріїв, один сценарій може перевіряти кілька вимог. Ключові слова Feature, Scenario, Given, When, Then, And лишай англійськими, решту пиши українською. Не вигадуй сутностей і полів, яких немає в моделі. Якщо для сценарію ти змушений щось припустити, чого немає у вимогах, познач це окремим рядком коментаря (#) над сценарієм.
