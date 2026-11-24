Нижче вимоги. Ключові слова EARS лишаю англійськими, решту пишу українською.

| id     | шаблон                   | текст вимоги                                                                                                                                                                                              |
| ------ | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| REQ-01 | Подія (WHEN)             | WHEN відвідувач подає `fullName` та `email`, яких немає в жодного `Client`, система SHALL створити `Client`.                                                                                              |
| REQ-02 | Помилка (IF)             | IF поданий `email` уже належить `Client`, THEN система SHALL відхилити реєстрацію.                                                                                                                        |
| REQ-03 | Подія (WHEN)             | WHEN `Client` запитує розклад, система SHALL показати кожне `TrainingSession`, у якого `startsAt` пізніше за поточний момент, із полями `title`, `startsAt`, `durationMin` і кількістю вільних місць.     |
| REQ-04 | Складний (WHILE + WHEN)  | WHILE `Client` має активний `Subscription`, WHEN `Client` записується на `TrainingSession`, у якого є вільні місця, система SHALL створити `Booking` з `bookedAt` = поточний момент і `attended` = false. |
| REQ-05 | Помилка (IF)             | IF `Client` не має активного `Subscription`, THEN система SHALL відхилити запис на `TrainingSession`.                                                                                                     |
| REQ-06 | Помилка (IF)             | IF кількість `Booking` на `TrainingSession` дорівнює `capacity`, THEN система SHALL відхилити запис на це заняття.                                                                                        |
| REQ-07 | Помилка (IF)             | IF `Booking` з таким самим `clientId` і `sessionId` уже існує, THEN система SHALL відхилити повторний запис.                                                                                              |
| REQ-08 | Подія (WHEN)             | WHEN `Client` скасовує `Booking` на `TrainingSession`, у якого `startsAt` пізніше за поточний момент, система SHALL видалити цей `Booking`.                                                               |
| REQ-09 | Подія (WHEN)             | WHEN `Client` обирає `MembershipPlan` для купівлі, система SHALL надіслати Payment Gateway запит на оплату суми `price`.                                                                                  |
| REQ-10 | Подія (WHEN)             | WHEN Payment Gateway підтверджує оплату, система SHALL створити `Subscription` з `startDate` = поточна дата, `endDate` = `startDate` + `durationDays` днів і `paidAmount` = підтверджена сума.            |
| REQ-11 | Помилка (IF)             | IF Payment Gateway відхиляє оплату, THEN система SHALL NOT створювати `Subscription`.                                                                                                                     |
| REQ-12 | Подія (WHEN)             | WHEN створено `Booking`, система SHALL надіслати через Email Service лист-підтвердження на `email` відповідного `Client`.                                                                                 |
| REQ-13 | Подія (WHEN)             | WHEN створено `Subscription`, система SHALL надіслати через Email Service лист-підтвердження на `email` відповідного `Client`.                                                                            |
| REQ-14 | Помилка (IF)             | IF Email Service не зміг надіслати лист, THEN система SHALL залишити створений `Booking` або `Subscription` чинним.                                                                                       |
| REQ-15 | Подія (WHEN)             | WHEN `Administrator` створює `TrainingSession`, система SHALL зберегти `title`, `startsAt`, `durationMin` > 0 та `capacity` > 0, які він вказав.                                                          |
| REQ-16 | Помилка (IF)             | IF `Administrator` створює `TrainingSession` без жодного `Trainer`, THEN система SHALL відхилити створення заняття.                                                                                       |
| REQ-17 | Подія (WHEN)             | WHEN `Staff` відкриває список записаних на `TrainingSession`, система SHALL показати `fullName` кожного `Client`, який має `Booking` на це заняття.                                                       |
| REQ-18 | Подія (WHEN)             | WHEN `Trainer` цього `TrainingSession` відмічає `Client` присутнім після `startsAt`, система SHALL встановити `attended` = true у відповідному `Booking`.                                                 |
| REQ-19 | Завжди                   | Система SHALL NOT змінювати `endDate` існуючих `Subscription`, якщо змінилося `durationDays` у `MembershipPlan`.                                                                                          |
| REQ-20 | Завжди (нефункціональна) | Система SHALL повертати розклад за запитом `Client` не довше ніж за 2 секунди.                                                                                                                            |

**Чому REQ-20 не можна перевірити Gherkin.** Gherkin описує поведінку («Дано, Коли, Тоді») і перевіряє, чи вона правильна. Швидкість це вимір часу під навантаженням. Для цього потрібен окремий тест продуктивності: засікти час при багатьох одночасних запитах. Тому REQ-20 навмисно лишається без сценарію (критерій AC-6).

**Де я вийшов за межі твого `spec.md`.** Це припущення, і ти маєш вирішити, що з ними робити:

1. **REQ-08:** скасувати запис можна лише до початку заняття. У spec такого правила немає.
2. **REQ-18:** відмічати присутність можна лише після `startsAt`. Це теж моє припущення.
3. **REQ-20:** число «2 секунди» я вибрав сам, у spec його немає.
4. **REQ-15:** я написав, що адміністратор вказує поля, і не визначав, які з них обов'язкові. Spec цього теж не каже.
5. **REQ-04:** це складний шаблон (WHILE + WHEN разом). Вимога має один тригер і одну реакцію, а `WHILE` описує умову, у якій вона діє. Якщо вважаєш, що це порушує AC-1, скажи, і розіб'ємо.
6. Таймаут оплати (що робити, якщо Payment Gateway взагалі не відповів) я не включав, бо в spec нема числа.
