# Spec: Процес, UC-07 «Купити абонемент»

## Intent

Описати одним activity-процесом, як `Client` купує `MembershipPlan` і що відбувається з оплатою, `Subscription` та листом-підтвердженням. Процес деталізує UC-07 із Завдання 2 разом із підкроками UC-08 (оплата) та UC-09 (лист). Розглядаємо лише цей процес, а не всю систему.

## Form

Одна форма: activity-діаграма (PlantUML) із swimlanes. Машину станів не використовуємо. Причина: у процесі є різні ролі та паралельна гілка, які activity показує прямо (див. ADR).

## Roles (swimlanes)

- `Client`: людина, яка обирає абонемент (актор lab2).
- `System`: система спортзалу, виконує перевірки й створює дані.
- `Payment Gateway`: зовнішня система оплати (актор lab2).
- `Email Service`: зовнішня система листів (актор lab2).

## Steps

1. Початок: `Client` обирає `MembershipPlan` (UC-07).
2. `System` перевіряє `Subscription.hasActive(clientId)`. Якщо `true`, завершує процес результатом `Rejected(ACTIVE_SUBSCRIPTION_EXISTS)` (правило lab1: щонайбільше один активний `Subscription`).
3. `System` надсилає `Payment Gateway` запит на оплату суми `price` (REQ-09, UC-08).
4. `Payment Gateway` повертає результат: оплату підтверджено або відхилено.
5. Якщо відхилено, `System` не створює `Subscription` і завершує процес результатом `Rejected(PAYMENT_DECLINED)` (REQ-11).
6. Якщо підтверджено, `System` створює `Subscription` із `startDate` = поточна дата, `endDate` = `startDate` + `durationDays` днів і `paidAmount` = підтверджена сума (REQ-10).
7. Далі дві паралельні гілки (`fork`):
   - Гілка листа: `System` отримує `Client.getEmail(clientId)` і ініціює `EmailService.sendConfirmation(email)` (REQ-13, UC-09). Якщо лист не вдався, `Subscription` лишається чинним (REQ-14).
   - Гілка результату: `System` готує `PurchaseConfirmed(subscriptionId)` для `Client`.
8. Гілки зливаються (`join`), `System` повертає `Client` результат, кінець.

## Acceptance criteria

- AC-1: процес описано однією формою, activity-діаграмою, без другої нотації.
- AC-2: є початковий і кінцевий вузли, кожен шлях доходить до кінця, недосяжних дій немає.
- AC-3: у діаграмі є щонайменше одне розгалуження, де всі виходи підписані умовами й покривають усі можливі результати.
- AC-4: є щонайменше одна паралельна гілка, кожен `fork` має відповідний `join`.
- AC-5: swimlanes збігаються з розділом Roles.
- AC-6: назви сутностей і полів збігаються з `lab1/spec.md` символ у символ.
- AC-7: кроки відповідають UC-07, UC-08, UC-09, вимогам REQ-09…REQ-14 і сценаріям Gherkin SC-12…SC-18 із Завдання 2.
- AC-8: однакові операції мають такі самі назви, як у Завданні 3 (`getEmail`, `sendConfirmation`, `hasActive`).
- AC-9: збій листа не змінює результат покупки (REQ-14).
- AC-10: результати збігаються з типами `PurchaseConfirmed(subscriptionId)` та `Rejected(reason)`, де `reason` це `ACTIVE_SUBSCRIPTION_EXISTS` або `PAYMENT_DECLINED`.

## Out of scope and assumptions

- Відсутність відповіді від `Payment Gateway` (таймаут): у вимогах lab2 цього немає.
- Повернення коштів, повторна спроба оплати, часткова оплата.
- Знижки: у сценаріях lab2 `paidAmount` дорівнює `price`, хоча lab1 (AC-13) допускає різницю.
- Перевірка, що `MembershipPlan` існує: не моделюємо.
