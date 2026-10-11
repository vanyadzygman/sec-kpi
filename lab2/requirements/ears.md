# EARS-вимоги

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

## Навмисно непокрита вимога

REQ-20 не матиме Gherkin-сценарію. Gherkin описує поведінку («Дано, Коли, Тоді»), а швидкість треба міряти окремим тестом продуктивності під навантаженням.
