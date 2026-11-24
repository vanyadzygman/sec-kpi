**D1 (SC-05): Запис створено**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription
    participant B as Booking
    participant TS as TrainingSession

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Sub-->>-BS: true
    BS->>+B: exists(clientId, sessionId)
    B-->>-BS: false
    BS->>+TS: freeSeats(sessionId)
    TS-->>-BS: 1
    opt усі перевірки пройдено
        BS->>+B: create(clientId, sessionId)
        B-->>-BS: bookingId
        BS-->>C: BookingConfirmed(bookingId)
    end
    deactivate BS
```

**D2 (SC-15): Запис створено, лист надіслано**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription
    participant B as Booking
    participant TS as TrainingSession
    participant CE as Client (сутність)
    participant ES as Email Service

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Sub-->>-BS: true
    BS->>+B: exists(clientId, sessionId)
    B-->>-BS: false
    BS->>+TS: freeSeats(sessionId)
    TS-->>-BS: 1
    opt усі перевірки пройдено
        BS->>+B: create(clientId, sessionId)
        B-->>-BS: bookingId
        BS->>+CE: getEmail(clientId)
        CE-->>-BS: email
        BS->>+ES: sendConfirmation(email)
        alt лист надіслано
            ES-->>BS: SENT
            Note over BS,ES: SC-15, виконується ця гілка
        else лист не вдалося
            ES-->>BS: FAILED
            Note over BS,ES: інший сценарій, див. D3
        end
        deactivate ES
        BS-->>C: BookingConfirmed(bookingId)
    end
    deactivate BS
```

**D3 (SC-17): Запис створено, лист не вдався, Booking лишається**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription
    participant B as Booking
    participant TS as TrainingSession
    participant CE as Client (сутність)
    participant ES as Email Service

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Sub-->>-BS: true
    BS->>+B: exists(clientId, sessionId)
    B-->>-BS: false
    BS->>+TS: freeSeats(sessionId)
    TS-->>-BS: 1
    opt усі перевірки пройдено
        BS->>+B: create(clientId, sessionId)
        B-->>-BS: bookingId
        BS->>+CE: getEmail(clientId)
        CE-->>-BS: email
        BS->>+ES: sendConfirmation(email)
        alt лист надіслано
            ES-->>BS: SENT
            Note over BS,ES: інший сценарій, див. D2
        else лист не вдалося
            ES-->>BS: FAILED
            Note over BS,B: SC-17, Booking лишається чинним (REQ-14)
        end
        deactivate ES
        BS-->>C: BookingConfirmed(bookingId)
    end
    deactivate BS
```

**D4 (SC-06): Відмова, у клієнта немає жодного Subscription**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Note right of Sub: SC-06, у клієнта немає жодного Subscription
    Sub-->>-BS: false
    opt hasActive = false
        BS-->>C: Rejected(NO_ACTIVE_SUBSCRIPTION)
    end
    deactivate BS
```

**D5 (SC-07): Відмова, Subscription прострочений**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Note right of Sub: SC-07, Subscription існує, але endDate минув
    Sub-->>-BS: false
    opt hasActive = false
        BS-->>C: Rejected(NO_ACTIVE_SUBSCRIPTION)
    end
    deactivate BS
```

**D6 (SC-09): Відмова, повторний запис**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription
    participant B as Booking

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Sub-->>-BS: true
    BS->>+B: exists(clientId, sessionId)
    B-->>-BS: true
    opt exists = true
        BS-->>C: Rejected(ALREADY_BOOKED)
    end
    deactivate BS
```

**D7 (SC-08): Відмова, немає вільних місць**

```mermaid
sequenceDiagram
    actor C as Client (actor)
    participant BS as BookingService
    participant Sub as Subscription
    participant B as Booking
    participant TS as TrainingSession

    C->>BS: bookSession(clientId, sessionId)
    activate BS
    BS->>+Sub: hasActive(clientId)
    Sub-->>-BS: true
    BS->>+B: exists(clientId, sessionId)
    B-->>-BS: false
    BS->>+TS: freeSeats(sessionId)
    TS-->>-BS: 0
    opt freeSeats = 0
        BS-->>C: Rejected(NO_FREE_SEATS)
    end
    deactivate BS
```
