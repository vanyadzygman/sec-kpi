Ось лише змінені шматки.

**1. `ears.md`: оновлені REQ-12 і REQ-13, нові REQ-21 і REQ-22**

```markdown
| REQ-12 | Подія (WHEN) | WHEN створено `Booking`, система SHALL ініціювати надсилання через Email Service листа-підтвердження на `email` відповідного `Client`. |
| REQ-13 | Подія (WHEN) | WHEN створено `Subscription`, система SHALL ініціювати надсилання через Email Service листа-підтвердження на `email` відповідного `Client`. |
| REQ-21 | Подія (WHEN) | WHEN `Administrator` створює `MembershipPlan` з `name`, `durationDays` > 0 та `price`, система SHALL зберегти цей `MembershipPlan`. |
| REQ-22 | Помилка (IF) | IF `durationMin` або `capacity` не більше 0, THEN система SHALL відхилити створення `TrainingSession`. |
```

**2. `user-stories.md`: рядок US-08**

```markdown
| US-08 | Як `Administrator`, я хочу створити тип абонемента з назвою, тривалістю й ціною, щоб клієнти мали що купувати. | REQ-21 |
```

**3. `use-cases.md`: рядок UC-13**

```markdown
| UC-13 | Створити тип абонемента | `Administrator` | US-08 | REQ-21 |
```

**4. Сценарії**

У `staff.feature` заміни SC-22 (його коментар-припущення прибрано, бо правило тепер у spec і REQ-22):

```gherkin
  @REQ-22 @UC-10
  Scenario: SC-22 Відмова в створенні заняття з capacity 0
    Given Administrator обрав Trainer
    When Administrator створює TrainingSession з capacity 0
    Then система відхиляє створення
    And TrainingSession не створено
```

У `subscription-and-email.feature` заміни теги SC-19: було `@REQ-19 @UC-13`, стало `@REQ-19 @UC-07`, а коментар-припущення над ним видали. Причина: UC-13 тепер лише створює тип абонемента, тож зміна `durationDays` належить до життєвого циклу абонемента (UC-07).

Додай у кінець `subscription-and-email.feature`:

```gherkin
  @REQ-21 @UC-13
  Scenario: SC-28 Успішне створення типу абонемента
    When Administrator створює MembershipPlan з name "Місячний", durationDays 30 і price 800
    Then система зберігає MembershipPlan з name "Місячний", durationDays 30 і price 800

  # Припущення: REQ-21 вимагає durationDays > 0 в умові WHEN, окремої вимоги про текст відмови немає.
  @REQ-21 @UC-13
  Scenario: SC-29 Тип абонемента з durationDays 0 не створюється
    When Administrator створює MembershipPlan з name "Нульовий", durationDays 0 і price 800
    Then система не зберігає MembershipPlan з name "Нульовий"
```

**5. `traceability.md`: змінені рядки**

```markdown
| REQ-15 | UC-10 | SC-20 |
| REQ-19 | UC-07 | SC-19 |
| REQ-21 | UC-13 | SC-28, SC-29 |
| REQ-22 | UC-10 | SC-22 |
```

REQ-12 і REQ-13 у матриці не змінюються, бо змінилося лише формулювання.

**Що перевірити.** SC-29 спирається на припущення (позначене коментарем): вимога REQ-21 лише обмежує `durationDays` > 0 в умові, а явної відмови не описує. Якщо викладач спитає, відповідь така: це наслідок умови в WHEN, а розширювати REQ-21 до окремого IF не стали, щоб не плодити вимоги.
