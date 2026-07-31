# Alain Pacifique Uwenayo — Contribution Evidence

Use the entries below in the group contribution tracker and final report. The
wording matches the repository history and avoids claiming work assigned to
other members.

| Contribution | Status | Review evidence |
| --- | --- | --- |
| Therapist directory, profile browsing, search, filters, refresh, and responsive states | Completed | [PR #2](https://github.com/angelkibui/solace/pull/2) |
| Appointment booking, upcoming/history views, rescheduling, cancellation, deletion, and Firestore lifecycle | Completed | [PR #3](https://github.com/angelkibui/solace/pull/3) |
| MTN/Airtel checkout presentation, validation, status feedback, transaction history, and appointment confirmation | Completed | [PR #4](https://github.com/angelkibui/solace/pull/4) |
| Appointment and transaction security rules, matching ERD, deterministic therapist seed data, feature navigation, and documentation | Completed | [PR #5](https://github.com/angelkibui/solace/pull/5) |
| Unit, repository, widget, portrait, and landscape verification for owned features | Completed | 41 passing project tests; 70.32% project coverage and 73.71% owned-feature coverage |

## Suggested tracker rows

| Task allocated | Assigned member | Completion status | Reviewed by team? | Comments |
| --- | --- | --- | --- | --- |
| Therapist search and directory | Alain Pacifique Uwenayo | Completed | Yes | Search, multi-filter directory, professional profiles, responsive states, and Firestore CRUD repository. |
| Appointment booking | Alain Pacifique Uwenayo | Completed | Yes | Guided booking plus create, read, reschedule, cancel, and delete flows. |
| Mobile money checkout | Alain Pacifique Uwenayo | Completed | Yes | MTN/Airtel academic simulation with validation, status feedback, transaction CRUD, and history. |
| Firebase architecture and security | Alain Pacifique Uwenayo | Completed | Yes | ERD, owner-scoped appointment/transaction rules, indexes, and reproducible therapist seed data. |
| Feature testing | Alain Pacifique Uwenayo | Completed | Yes | BLoC, repository, widget, small-phone, and landscape tests. |

## Demo segment

Recommended duration: 2–3 minutes within the continuous group recording.

1. Open **Licensed Professionals**, search for “Aline,” and apply a specialty or
   language filter.
2. Open the professional profile and start **Book Consultation**.
3. Select a date, time, and session type, then review and reserve the slot.
4. Select MTN MoMo or Airtel Money, enter valid checkout details, and confirm.
5. Show the successful result, then open **My Appointments** and **Wallet
   Activity**.
6. In Firebase Console, show the matching `appointments` and `transactions`
   documents and their shared appointment ID.
7. Reschedule or cancel the appointment and show the Firestore document update.

The checkout is an academic provider simulation and does not move real funds.
The video should demonstrate the visible flow and Firestore state change without
claiming a live MTN or Airtel API integration.
