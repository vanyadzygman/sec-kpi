Нижче три файли. У рядках з `#` я позначив місця, де довелося щось припустити, чого немає у вимогах.

**`registration-and-booking.feature`**

```gherkin
Feature: Реєстрація клієнта, перегляд розкладу, запис на заняття та скасування запису

  @REQ-01 @UC-01
  Scenario: SC-01 Успішна реєстрація нового клієнта
    Given у системі немає Client з email "ivan@example.com"
    When відвідувач подає fullName "Іван Петренко" та email "ivan@example.com"
    Then система створює Client з fullName "Іван Петренко" та email "ivan@example.com"

  @REQ-02 @UC-01
  Scenario: SC-02 Відхилення реєстрації із зайнятим email
    Given у системі є Client з email "ivan@example.com"
    When відвідувач подає fullName "Петро Іваненко" та email "ivan@example.com"
    Then система відхиляє реєстрацію
    And нового Client не створено

  @REQ-03 @UC-02
  Scenario: SC-03 Перегляд розкладу майбутніх занять
    Given є TrainingSession з title "Йога" і startsAt у майбутньому, capacity 10, 3 Booking
    When Client запитує розклад
    Then система показує TrainingSession з title "Йога", startsAt, durationMin
    And система показує 7 вільних місць

  @REQ-03 @UC-02
  Scenario: SC-04 Минулі заняття не показуються в розкладі
    Given є TrainingSession з title "Пілатес" і startsAt у минулому
    When Client запитує розклад
    Then система не показує TrainingSession з title "Пілатес"

  @REQ-04 @REQ-05 @REQ-06 @UC-03 @UC-04 @UC-05
  Scenario: SC-05 Успішний запис на заняття
    Given Client має активний Subscription
    And є TrainingSession з capacity 10 і 9 Booking, startsAt у майбутньому
    When Client записується на це TrainingSession
    Then система створює Booking з bookedAt, що дорівнює поточному моменту
    And attended у цьому Booking дорівнює false

  @REQ-05 @UC-03 @UC-04
  Scenario: SC-06 Відмова в записі клієнту без Subscription
    Given Client не має жодного Subscription
    And є TrainingSession з вільними місцями
    When Client записується на це TrainingSession
    Then система відхиляє запис
    And Booking не створено

  @REQ-05 @UC-03 @UC-04
  Scenario: SC-07 Відмова в записі клієнту з простроченим Subscription
    Given Client має Subscription, у якого endDate був учора
    And є TrainingSession з вільними місцями
    When Client записується на це TrainingSession
    Then система відхиляє запис
    And Booking не створено

  @REQ-06 @UC-03 @UC-05
  Scenario: SC-08 Відмова в записі на заповнене заняття
    Given Client має активний Subscription
    And є TrainingSession з capacity 10 і 10 Booking
    When Client записується на це TrainingSession
    Then система відхиляє запис
    And кількість Booking на цьому TrainingSession лишається 10

  @REQ-07 @UC-03
  Scenario: SC-09 Відмова в повторному записі на те саме заняття
    Given Client має активний Subscription
    And у Client уже є Booking на це TrainingSession
    When Client записується на це TrainingSession ще раз
    Then система відхиляє запис
    And у Client лишається один Booking на це TrainingSession

  @REQ-08 @UC-06
  Scenario: SC-10 Успішне скасування запису
    Given у Client є Booking на TrainingSession, у якого startsAt у майбутньому
    When Client скасовує цей Booking
    Then система видаляє цей Booking

  # Припущення: REQ-08 описує лише успішний випадок (заняття ще не почалося).
  # Що саме відбувається після початку заняття, вимога прямо не каже, тут прийнято відмову.
  @REQ-08 @UC-06
  Scenario: SC-11 Скасування запису на заняття, що вже почалося
    Given у Client є Booking на TrainingSession, у якого startsAt у минулому
    When Client скасовує цей Booking
    Then система не видаляє цей Booking
```

**`subscription-and-email.feature`**

```gherkin
Feature: Купівля абонемента, оплата, листи-підтвердження та незмінність endDate

  @REQ-09 @UC-07 @UC-08
  Scenario: SC-12 Запит оплати при виборі абонемента
    Given є MembershipPlan з price 800
    When Client обирає цей MembershipPlan
    Then система надсилає Payment Gateway запит на оплату суми 800

  @REQ-10 @UC-07 @UC-08
  Scenario: SC-13 Створення Subscription після підтвердження оплати
    Given Client обрав MembershipPlan з durationDays 30 і price 800
    When Payment Gateway підтверджує оплату суми 800
    Then система створює Subscription з startDate, що дорівнює поточній даті
    And endDate цього Subscription дорівнює startDate плюс 30 днів
    And paidAmount цього Subscription дорівнює 800

  @REQ-11 @UC-07 @UC-08
  Scenario: SC-14 Оплату відхилено
    Given Client обрав MembershipPlan
    When Payment Gateway відхиляє оплату
    Then система не створює Subscription

  @REQ-12 @UC-03 @UC-09
  Scenario: SC-15 Лист після створення Booking
    Given Client з email "ivan@example.com" має активний Subscription
    When Client успішно записується на TrainingSession
    Then система надсилає через Email Service лист-підтвердження на "ivan@example.com"

  @REQ-13 @UC-07 @UC-09
  Scenario: SC-16 Лист після створення Subscription
    Given Client з email "ivan@example.com" обрав MembershipPlan
    When Payment Gateway підтверджує оплату
    Then система надсилає через Email Service лист-підтвердження на "ivan@example.com"

  @REQ-14 @UC-03 @UC-09
  Scenario: SC-17 Збій листа не скасовує Booking
    Given Client має активний Subscription
    And Email Service не може надіслати лист
    When Client успішно записується на TrainingSession
    Then створений Booking лишається чинним

  @REQ-14 @UC-07 @UC-09
  Scenario: SC-18 Збій листа не скасовує Subscription
    Given Client обрав MembershipPlan
    And Email Service не може надіслати лист
    When Payment Gateway підтверджує оплату
    Then створений Subscription лишається чинним

  # Припущення: UC-13 описує створення типу абонемента, а зміну durationDays у існуючого
  # MembershipPlan виконує Administrator. У вимогах це окремо не названо.
  @REQ-19 @UC-13
  Scenario: SC-19 Зміна durationDays не змінює endDate існуючого Subscription
    Given у Client є Subscription з endDate 2026-11-20, куплений за MembershipPlan з durationDays 30
    When Administrator змінює durationDays цього MembershipPlan на 60
    Then endDate цього Subscription лишається 2026-11-20
```

**`staff.feature`**

```gherkin
Feature: Створення заняття, список записаних і відмітка відвідування

  @REQ-15 @UC-10
  Scenario: SC-20 Успішне створення заняття
    Given Administrator обрав щонайменше одного Trainer
    When Administrator створює TrainingSession з title "Йога", startsAt у майбутньому, durationMin 60, capacity 15
    Then система зберігає TrainingSession з title "Йога", durationMin 60 і capacity 15

  @REQ-16 @UC-10
  Scenario: SC-21 Відмова в створенні заняття без Trainer
    Given Administrator не обрав жодного Trainer
    When Administrator створює TrainingSession з title "Йога"
    Then система відхиляє створення
    And TrainingSession не створено

  # Припущення: REQ-15 записує умови durationMin > 0 і capacity > 0 лише для успішного збереження,
  # а окремої вимоги про відмову при capacity 0 немає. Тут прийнято, що система відхиляє таке заняття.
  @REQ-15 @UC-10
  Scenario: SC-22 Відмова в створенні заняття з capacity 0
    Given Administrator обрав Trainer
    When Administrator створює TrainingSession з capacity 0
    Then система відхиляє створення
    And TrainingSession не створено

  @REQ-17 @UC-11
  Scenario: SC-23 Trainer переглядає список записаних
    Given на TrainingSession є Booking від Client "Іван Петренко" і Client "Олена Коваль"
    When Trainer відкриває список записаних на це TrainingSession
    Then система показує fullName "Іван Петренко" і "Олена Коваль"

  @REQ-17 @UC-11
  Scenario: SC-24 Administrator переглядає список записаних
    Given на TrainingSession є Booking від Client "Іван Петренко"
    When Administrator відкриває список записаних на це TrainingSession
    Then система показує fullName "Іван Петренко"

  @REQ-18 @UC-12
  Scenario: SC-25 Успішна відмітка відвідування
    Given Trainer веде TrainingSession, у якого startsAt уже минув
    And на це TrainingSession є Booking з attended false
    When Trainer відмічає цього Client присутнім
    Then attended у цьому Booking дорівнює true

  # Припущення: REQ-18 каже "після startsAt", отже до початку заняття відмітка не можлива.
  @REQ-18 @UC-12
  Scenario: SC-26 Відмітка відвідування до початку заняття
    Given Trainer веде TrainingSession, у якого startsAt у майбутньому
    And на це TrainingSession є Booking з attended false
    When Trainer відмічає цього Client присутнім
    Then attended у цьому Booking лишається false

  # Припущення: REQ-18 каже "Trainer цього TrainingSession", отже чужий Trainer відмітити не може.
  @REQ-18 @UC-12
  Scenario: SC-27 Відмітка відвідування Trainer-ом, який не веде це заняття
    Given Trainer не веде це TrainingSession, у якого startsAt уже минув
    And на це TrainingSession є Booking з attended false
    When Trainer відмічає Client присутнім
    Then attended у цьому Booking лишається false
```

**Зверни увагу перед комітом** (знахідки кандидатів на аудит):

1. SC-05 має теги `@REQ-05 @REQ-06`, хоча перевіряє успішний шлях. Це навмисно: він підтверджує, що обидві перевірки пройдено. Для матриці трасування це дасть зв'язки «багато-до-багатьох».
2. SC-11, SC-22, SC-26 і SC-27 спираються на мої припущення, бо вимоги про ці випадки мовчать. На захисті викладач може спитати «звідки відмова при `capacity` 0», тож відповідь «вимоги цього не вимагають, тому в аудиті додамо вимогу або приберемо сценарій» треба мати напоготові.
3. SC-19 і REQ-19 прив'язані до UC-13, хоча UC-13 лише створює тип абонемента. Це відома прогалина, вона вже є в списку кандидатів.
4. В обох сценаріях запису є клієнти з одним активним `Subscription`, як у новому правилі lab1.
5. У SC-13 стоїть `paidAmount` = 800 при `price` = 800. Різниця (знижка) у вимогах не описана, хоч lab1 AC-13 це допускає. Це також кандидат на аудит.
