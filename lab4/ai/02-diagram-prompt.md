Намалюй activity-діаграму в PlantUML (новий синтаксис activity з swimlanes) за моєю специфікацією Завдання 4.

# Spec: Процес, UC-07 «Купити абонемент»

## Intent

Описати одним activity-процесом, як `Client` купує `MembershipPlan` і що відбувається з оплатою, `Subscription` та листом-підтвердженням. Процес деталізує UC-07 із Завдання 2 разом із підкроками UC-08 (оплата) та UC-09 (лист). Розглядаємо лише цей процес, а не всю систему.

## Form

Одна форма: activity-діаграма (PlantUML) із swimlanes. Машину станів не використовуємо. Причина: у процесі є різні ролі та паралельна гілка, які activity показує прямо (див. ADR).

## Roles (swimlanes)

- `Client`: людина, яка обирає абонемент і отримує результат (актор lab2).
- `System`: система спортзалу, виконує перевірки й створює дані.
- `Payment Gateway`: зовнішня система оплати (актор lab2).
- `Email Service`: зовнішня система листів (актор lab2).

## Steps

1. Початок: `Client` обирає `MembershipPlan` (UC-07).
2. `System` перевіряє `Subscription.hasActive(clientId)`. Якщо `true`, завершує процес результатом `Rejected(ACTIVE_SUBSCRIPTION_EXISTS)`. Це нове правило процесу, яке гарантує правило lab1 (щонайбільше один активний `Subscription`), а у вимогах lab2 такої відмови немає.
3. `System` надсилає `Payment Gateway` запит на оплату суми `price` (REQ-09, UC-08).
4. `Payment Gateway` повертає один із трьох результатів: оплату підтверджено, відхилено або відповіді немає.
5. Якщо відхилено, `System` не створює `Subscription` і завершує процес результатом `Rejected(PAYMENT_DECLINED)` (REQ-11).
6. Якщо відповіді немає, `System` не створює `Subscription` і завершує процес результатом `Rejected(PAYMENT_UNKNOWN)`. Це припущення: у вимогах lab2 таймаут не описано.
7. Якщо підтверджено, `System` створює `Subscription` із `startDate` = поточна дата, `endDate` = `startDate` + `durationDays` днів і `paidAmount` = підтверджена сума, якою б вона не була (REQ-10, lab1 AC-13). Створення записів вважаємо надійним, збій після оплати не моделюємо.
8. Далі дві паралельні гілки (`fork`):
   - Гілка листа: `System` отримує `Client.getEmail(clientId)` і ініціює `EmailService.sendConfirmation(email)` (REQ-13, UC-09). Результат листа (надіслано або не вдалося) не змінює результат покупки (REQ-14).
   - Гілка результату: `System` готує `PurchaseConfirmed(subscriptionId)` для `Client`.
9. Гілки зливаються (`join`), `System` повертає `Client` результат, кінець.

## Acceptance criteria

- AC-1: процес описано однією формою, activity-діаграмою, без другої нотації.
- AC-2: є початковий і кінцевий вузли, кожен шлях доходить до кінця, недосяжних дій немає.
- AC-3: розгалуження після відповіді `Payment Gateway` має три виходи (підтверджено, відхилено, немає відповіді), кожен підписаний умовою. Розгалуження перевірки `hasActive` має два виходи (`true`, `false`).
- AC-4: є щонайменше одна паралельна гілка, кожен `fork` має відповідний `join`.
- AC-5: swimlanes збігаються з розділом Roles.
- AC-6: назви сутностей і полів збігаються з `lab1/spec.md` символ у символ.
- AC-7: кроки відповідають UC-07, UC-08, UC-09, вимогам REQ-09…REQ-14 і сценаріям Gherkin SC-12…SC-18 із Завдання 2.
- AC-8: однакові операції мають такі самі назви, як у Завданні 3 (`getEmail`, `sendConfirmation`, `hasActive`).
- AC-9: збій листа не змінює результат покупки (REQ-14).
- AC-10: результати збігаються з типами `PurchaseConfirmed(subscriptionId)` та `Rejected(reason)`, де `reason` це `ACTIVE_SUBSCRIPTION_EXISTS`, `PAYMENT_DECLINED` або `PAYMENT_UNKNOWN`.
- AC-11: кожне розгалуження й результат, яких немає у вимогах lab2 (`ACTIVE_SUBSCRIPTION_EXISTS`, `PAYMENT_UNKNOWN`), позначено на діаграмі нотаткою «припущення, немає у вимогах lab2».
- AC-12: прямого порівняння з Завданням 3 немає, бо sequence-діаграми lab3 описують лише UC-03. Узгодженість із lab3 перевіряється за спільними операціями (AC-8), а решта кроків за Gherkin lab2.

## Out of scope and assumptions

- Повернення коштів, повторна спроба оплати, часткова оплата.
- Знижки: у сценаріях lab2 `paidAmount` дорівнює `price`, але процес приймає будь-яку підтверджену суму (lab1 AC-13).
- Збій створення `Subscription` після підтвердженої оплати.
- Перевірка, що `MembershipPlan` існує.
- Дії `Client` на боці `Payment Gateway` (введення даних картки): `Client` лише обирає й отримує результат.

Вимоги до діаграми:

- Один блок коду @startuml ... @enduml.
- Swimlanes рівно з розділу Roles: |Client|, |System|, |Payment Gateway|, |Email Service|. Дії розкладай по доріжках за ролями.
- Кроки, умови й результати рівно як у розділі Steps: hasActive, getEmail, sendConfirmation, Rejected(ACTIVE_SUBSCRIPTION_EXISTS), Rejected(PAYMENT_DECLINED), Rejected(PAYMENT_UNKNOWN), PurchaseConfirmed(subscriptionId).
- Розгалуження перевірки hasActive: if/else з двома виходами. Розгалуження після відповіді Payment Gateway: три виходи (підтверджено, відхилено, немає відповіді), для цього використай switch/case або вкладені if/elseif, усі виходи підписані умовами.
- Паралельні гілки через fork / fork again / end fork: лист (getEmail, sendConfirmation) і результат (підготувати PurchaseConfirmed). Кожен fork має end fork.
- Кожен шлях має дійти до stop, недосяжних дій немає. Відмови завершуються stop одразу після повернення Rejected(...) клієнту.
- Згідно з AC-11 біля ACTIVE_SUBSCRIPTION_EXISTS і PAYMENT_UNKNOWN додай note: "припущення, немає у вимогах lab2".
- Назви сутностей і полів символ у символ як у lab1 (Subscription, MembershipPlan, startDate, endDate, paidAmount, price, durationDays).
- Не додавай дій, яких немає в Steps (повернення коштів, повторна спроба, збій створення Subscription).
  Віддай лише код діаграми.
