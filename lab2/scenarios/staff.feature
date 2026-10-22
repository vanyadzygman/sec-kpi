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
  @REQ-22 @UC-10
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