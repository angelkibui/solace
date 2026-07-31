# Solace Firestore Entity-Relationship Diagram

Firestore is document-oriented, so the foreign keys below are logical document
references stored as strings. The names and types match the implemented Dart
models and `firestore.rules`.

```mermaid
erDiagram
    USERS ||--o{ APPOINTMENTS : books
    THERAPISTS ||--o{ APPOINTMENTS : receives
    USERS ||--o{ TRANSACTIONS : owns
    APPOINTMENTS ||--o| TRANSACTIONS : paid_by

    USERS {
        string uid PK "document ID"
        string alias
        string email
        timestamp createdAt
        array_string preferences
        boolean onboardingComplete
    }

    THERAPISTS {
        string id PK "document ID"
        string name
        string title
        array_string specialties
        array_string languages
        integer rate
        string bio
        string photoUrl
        double rating
        integer reviewCount
        string location
        string gender
        string providerUid
        array_timestamp availability
    }

    APPOINTMENTS {
        string id PK "document ID"
        string userId FK
        string therapistId FK
        timestamp dateTime
        string sessionType
        string status
        integer amount
        string notes
        timestamp createdAt
        timestamp updatedAt
    }

    TRANSACTIONS {
        string id PK "document ID"
        string transactionId UK
        string userId FK
        integer amount
        string network
        string status
        timestamp timestamp
        string appointmentId FK
    }
```

## Collections and relationships

| Collection | Document owner | Relationship and purpose |
| --- | --- | --- |
| `users` | `uid` equals Firebase Auth UID | One private alias-based profile per authenticated account. |
| `therapists` | Managed by an administrator | Shared professional directory. `providerUid` optionally links a professional to an Auth account. |
| `appointments` | `userId` | References one `therapists/{therapistId}` document. Users create, reschedule, cancel, and delete their records. |
| `transactions` | `userId` | References one `appointments/{appointmentId}` document and records the selected network and simulated result. |

## Enumerated values

- `appointments.sessionType`: `individual`, `couples`, `group`.
- `appointments.status`: `pending_payment`, `confirmed`, `completed`,
  `cancelled`.
- `transactions.network`: `mtn`, `airtel`.
- `transactions.status`: `pending`, `successful`, `failed`.

The app resolves therapist names from the referenced therapist documents rather
than duplicating them in appointments. This avoids stale duplicated profile
data.
