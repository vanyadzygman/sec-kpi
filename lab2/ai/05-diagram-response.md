@startuml
left to right direction

actor Client
actor Administrator
actor Trainer
actor Staff
actor "Payment Gateway" as PG <<system>>
actor "Email Service" as ES <<system>>

Trainer --|> Staff
Administrator --|> Staff

rectangle "Gym System" {
usecase "UC-01 Зареєструватися" as UC01
usecase "UC-02 Переглянути розклад" as UC02
usecase "UC-03 Записатися на заняття" as UC03
usecase "UC-04 Перевірити активний абонемент" as UC04
usecase "UC-05 Перевірити вільні місця" as UC05
usecase "UC-06 Скасувати запис" as UC06
usecase "UC-07 Купити абонемент" as UC07
usecase "UC-08 Обробити оплату" as UC08
usecase "UC-09 Надіслати лист-підтвердження" as UC09
usecase "UC-10 Створити заняття" as UC10
usecase "UC-11 Переглянути список записаних" as UC11
usecase "UC-12 Відмітити відвідування" as UC12
usecase "UC-13 Створити тип абонемента" as UC13
}

Client --> UC01
Client --> UC02
Client --> UC03
Client --> UC06
Client --> UC07

Administrator --> UC10
Administrator --> UC13
Trainer --> UC12
Staff --> UC11

UC08 --> PG
UC09 --> ES

UC03 ..> UC04 : <<include>>
UC03 ..> UC05 : <<include>>
UC07 ..> UC08 : <<include>>

UC09 ..> UC03 : <<extend>>
UC09 ..> UC07 : <<extend>>
@enduml
