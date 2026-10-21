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