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