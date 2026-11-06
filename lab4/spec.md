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
