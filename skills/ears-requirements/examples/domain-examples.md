# Domain Examples (local addenda)

Provenance: the checkout and automatic-emergency-braking examples from the
original "Practical Guide to SKILLS" draft, reformatted to the canonical clause
order and corrected where the draft broke an EARS rule.

Upstream `references/patterns.md` documents the patterns abstractly. These two
worked cases show a full requirement set for one feature, and one maximal
combination clause.

## Checkout & payment module

| ID | Pattern | Requirement |
|----|---------|-------------|
| CO-001 | Ubiquitous | The Checkout System shall encrypt all payment card data with AES-256 before it stores or transmits the data. |
| CO-002 | Event-driven | When the user selects "Confirm Order", the Payment Gateway shall process the card charge within 3 seconds. |
| CO-003 | State-driven | While the user session is in the "Checkout" state, the Inventory Manager shall hold the selected items in the cart for 15 minutes. |
| CO-004 | Optional feature | Where biometric authentication is enabled, the Mobile App shall request fingerprint or facial verification before it authorizes a transaction over $500. |
| CO-005 | Unwanted behavior | If the card issuer rejects the charge, then the Payment Gateway shall show a declined notification and return the cart to the review step. |

`CO-002` shows a measurable response (`within 3 seconds`) replacing the draft's
implied "promptly". `CO-005` carries two responses in one requirement — split it
if each response needs independent verification.

## Autonomous emergency braking

**Complex clause (state + event + unwanted):**

> While the vehicle operates in Autonomous Driving Mode, when the system detects
> lane drift, if the side-blindspot radar signal is lost, then the Vehicle
> Controller shall issue an audible warning.

The draft joined two responses with `and`:

> ... shall issue an audible warning and reduce speed by 20 km/h.

That is a compound requirement — the anti-pattern this skill forbids. Split it,
because a test can pass the warning and fail the braking without either clause
telling you which:

| ID | Requirement |
|----|-------------|
| AEB-001 | While the vehicle operates in Autonomous Driving Mode, when the system detects lane drift, if the side-blindspot radar signal is lost, then the Vehicle Controller shall issue an audible warning. |
| AEB-002 | While the vehicle operates in Autonomous Driving Mode, when the system detects lane drift, if the side-blindspot radar signal is lost, then the Vehicle Controller shall reduce vehicle speed by 20 km/h. |
