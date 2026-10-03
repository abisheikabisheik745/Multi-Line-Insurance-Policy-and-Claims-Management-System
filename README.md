# Multi-Line Insurance Policy and Claims Management System

A centralized **Salesforce-based** solution for managing **Vehicle (Auto), Property, and Life** insurance policies and claims. The system uses Record Types, Field Sets, guided Screen Flows, Apex automation, Approval Processes, and a Lightning Web Component (LWC) dashboard to replace manual, fragmented insurance workflows.

---

## Table of Contents

1. [Overview](#overview)
2. [Problem Statement](#problem-statement)
3. [Key Features](#key-features)
4. [Architecture & Tech Stack](#architecture--tech-stack)
5. [Data Model](#data-model)
6. [Data Flow](#data-flow)
7. [Implementation Milestones](#implementation-milestones)
8. [Apex & LWC Components](#apex--lwc-components)
9. [Security & Access Control](#security--access-control)
10. [Testing](#testing)
11. [Project Planning](#project-planning)
12. [Advantages & Limitations](#advantages--limitations)
13. [Future Scope](#future-scope)
14. [Getting Started](#getting-started)
15. [Team & License](#team--license)

---

## Overview

Insurance agents can create and manage policies through a flexible data model with policy-specific Record Types and Field Sets. A guided **Auto Quoting Screen Flow** captures quote details, and **Apex** calculates premiums. Claims are **automatically routed** to the right queue by policy type, and **high-value claims** go through a two-step approval process (Senior Adjuster → Claims Manager). Adjusters get an **LWC Claims Dashboard** showing their assigned claims at a glance.

**Goals:** faster policy processing, efficient claim handling, better data accuracy, operational visibility, and improved customer service, with a 360-degree view of Customer, Policy, and Claim data.

## Problem Statement

| Persona | Problem |
|---|---|
| Insurance Operations Manager | Policy quoting and issuance are manual, slow, and inconsistent |
| Insurance Agent | Different insurance lines need different data; quoting needs many manual steps |
| Claims Manager | Claim review and routing are manual and not centralized |
| Claims Adjuster | No focused view of assigned claims |
| Senior Adjuster | High-value claims need structured approval and escalation |
| Customer | Manual processing causes delays |

## Key Features

- **Multi-line policy management**: Policy records with `Auto`, `Property`, and `Life` Record Types
- **Product-specific fields via Field Sets**
  - Vehicle: VIN, Model Year
  - Property: Square Footage, Year Built
  - Life: Beneficiary Name, Policy Term Months
- **Auto Quoting Screen Flow** (`AutoQuotingFlow`): captures policy holder, start date, state, VIN, and model year, then creates a draft policy
- **VIN validation**: validation rule enforces exactly 17 characters for Auto policies
- **Apex premium calculation** (`PremiumCalculator`): invocable from the quoting flow
- **Claim management** with `Accident`, `Property`, and `Life` Record Types
- **Automatic claim routing** to Auto / Property / Life queues via a Record-Triggered Flow
- **High-value claim approval** (claim amount > $50,000): two sequential steps (Senior Adjuster, then Manager)
- **Approve/Reject Screen Flow** with approver comments, exposed as a Quick Action on the Claim record
- **LWC Claims Dashboard**: claim number, policy type, policy holder, claim amount, status, days open, with filtering by All / Auto / Property / Life
- **Security**: state-based sharing rules and role-specific Permission Sets

## Architecture & Tech Stack

| Layer | Technology |
|---|---|
| UI | Salesforce Lightning, Lightning Web Components (LWC), Screen Flows |
| Logic | Salesforce Flows, Apex |
| Database | Custom Objects (`Policy__c`, `Claim__c`), Contact, User |
| Automation | Record-Triggered Flows, Validation Rules, Approval Processes |
| Processing | Apex `PremiumCalculator`, Apex `ClaimsAdjusterController` |
| Data Configuration | Record Types, Field Sets, Custom Fields |
| Security | Permission Sets, State-Based Sharing Rules |
| Reporting | Salesforce Reports & Dashboards |
| Testing | Apex Test Classes |

## Data Model

### `Policy__c` (Auto-number: `P-{0000}`)

| Field | Type |
|---|---|
| Customer | Lookup (Contact) |
| Policy Start Date | Date |
| Premium | Currency (16,2) |
| Policy State | Picklist |
| VIN | Text (20) |
| Model Year | Text (5) |
| Square Footage | Number (18,0) |
| Year Built | Text (5) |
| Beneficiary Name | Text (50) |
| Policy Term Months | Number (18,0) |

**Record Types:** Auto, Property, Life

### `Claim__c` (Auto-number: `C-{0000}`)

| Field | Type |
|---|---|
| Policy | Lookup (Policy) |
| Adjuster | Lookup (User) |
| Claim Amount | Currency (16,2) |
| Date of Loss | Date/Time |
| Description | Long Text Area |
| Approval Status | Picklist (New, Submitted for Approval, Approved, Rejected) |

**Record Types:** Accident, Property, Life

## Data Flow

```
Customer / Agent → Screen Flow → Policy Validation → Policy__c → PremiumCalculator
→ Claim__c → Claim Routing Flow → Claims Queue → Claims Adjuster
→ Approval Process → Claim Update → LWC Dashboard / Reports
```

1. The agent provides customer and policy information.
2. `AutoQuotingFlow` captures holder, start date, state, VIN, and model year.
3. Validation checks the data (including the 17-character VIN rule).
4. A draft `Policy__c` is created with the right Record Type.
5. `PremiumCalculator` computes the premium and the policy is updated.
6. A `Claim__c` is created and linked to a policy.
7. A Record-Triggered Flow routes the claim to the Auto, Property, or Life queue.
8. The adjuster reviews assigned claims in the dashboard.
9. Claims over $50,000 are submitted for approval (Senior Adjuster → Manager).
10. The approver approves or rejects with comments, and the claim status updates.
11. Results show in the LWC dashboard and reports.

## Implementation Milestones

### Milestone 1: Core Data Model & Policy Configuration
- Create `Policy` and `Claim` custom objects
- Configure Record Types and Field Sets
- Create custom fields
- Build the `AutoQuotingFlow` Screen Flow
- Add the `VIN_Must_Be_17_Characters` validation rule

  ```
  AND( RecordType.DeveloperName = "Auto", LEN( VIN__c ) <> 17 )
  ```

### Milestone 2: Policy Issuance & Claim Routing Automation
- Build the `PremiumCalculator` Apex class (invocable)
- Integrate it into `AutoQuotingFlow` (Calculate Premium Action → Update Policy With Premium)
- Build a Record-Triggered Flow on Claim (on create) that looks up the Policy Record Type and assigns the claim owner to the Auto, Property, or Life queue

### Milestone 3: Claims Adjuster LWC Dashboard
- `ClaimsAdjusterController` Apex class returning a `ClaimWrapper` list
- `claimsDashboardLwc`: uses `@wire` with client-side filtering
- `claimTileLwc`: reusable claim tile

### Milestone 4: Advanced Claim Processing, Security & Testing
- Approval Status field on Claim
- `High Value Claim Approval` process (entry criteria: Claim Amount > 50000)
  - Step 1: Senior Adjuster
  - Step 2: Manager Review
  - Field updates for Submitted / Approved / Rejected
- `Submission Automation Flow`: auto-submits qualifying claims for approval
- `Claim Approver Screen Flow` plus **Approve/Reject Claim** Quick Action
- `ClaimsAdjusterControllerTest` Apex test class
- `Claim Policy Holder State Update` flow and state-based Sharing Rules (CA, TX)
- Permission Sets for Agents, Adjusters, and Managers

## Apex & LWC Components

### Apex

| Class | Purpose |
|---|---|
| `PremiumCalculator` | Invocable method that calculates premium from policy state and model year |
| `ClaimsAdjusterController` | `@AuraEnabled(cacheable=true) getAssignedClaims()`: returns the logged-in user's claims with policy and customer data |
| `ClaimsAdjusterControllerTest` | Test class for the controller |

**Premium logic (current):**
- Base premium: `1000.00`
- State `CA`: × 1.15
- State `TX`: × 1.05
- Model year before 2018: + 100

### Lightning Web Components

| Component | Purpose |
|---|---|
| `claimsDashboardLwc` | Dashboard with a policy-type filter (All / Auto / Property / Life) and total count |
| `claimTileLwc` | Displays claim number, policy type, holder, amount, status, and days open |

### Flows

| Flow | Type |
|---|---|
| `AutoQuotingFlow` | Screen Flow |
| Claim routing flow | Record-Triggered (After Save) |
| `Submission Automation Flow` | Record-Triggered (After Save) |
| `Claim Approver Screen Flow` | Screen Flow |
| `Claim Policy Holder State Update` | Record-Triggered |

## Security & Access Control

| Permission Set | Policy | Claim | Contact | Other |
|---|---|---|---|---|
| **Insurance Agent Access** | Create, Read | Read | Read, Edit | Flow User enabled; `PremiumCalculator` access |
| **Claims Adjuster Access** | Read | Read, Edit | n/a | `ClaimsAdjusterController` access |
| **Claims Manager Access** | Read | Read, Edit, Delete | Read, Edit | Run Reports; Manage Approvals |

**Sharing Rules:** Claim records are shared (Read/Write) based on the Policy holder state (CA and TX).

## Testing

Features were verified with screenshots captured from Salesforce for:
policy creation, auto quoting, premium calculation, claim routing, high-value claim approval, Claims Dashboard display, and access control.

Apex tests: run `ClaimsAdjusterControllerTest` from the Developer Console (Test → Run) and check coverage for `ClaimsAdjusterController`.

## Project Planning

Agile methodology with four sprints (20 story points each):

| Sprint | Focus | Stories |
|---|---|---|
| Sprint 1 | Data modeling and quoting flow | US-01 to US-04 |
| Sprint 2 | Validation, premium Apex, flow integration, claim routing | US-05 to US-08 |
| Sprint 3 | Controller and LWC dashboard | US-09, US-10 |
| Sprint 4 | Approvals, security, and testing | US-11, US-12 |

## Advantages & Limitations

**Advantages**
- One platform for Vehicle, Property, and Life insurance
- Guided, standardized quoting
- Consistent automated premium calculation and claim routing
- Faster claim processing through structured approvals
- Focused adjuster dashboard
- Validated data, with role- and state-based security
- Flexible, scalable data model

**Limitations**
- Different policy types need different fields, which adds data-model complexity
- Approval logic needs careful design (amount, type, adjuster level)
- Requires Apex test coverage for deployment and maintenance
- Depends on Salesforce configuration and platform capabilities
- Many Flows, Apex classes, LWCs, and rules to maintain

## Future Scope

- Integration with external vehicle and property databases for real-time quote verification
- Additional insurance products beyond Vehicle, Property, and Life
- More advanced claims automation and escalation
- Richer analytics dashboards and reports
- Customer-facing policy and claim status tracking
- Mobile access for agents and claims users
- AI-assisted support for agents and adjusters
- Expanded API-based integration architecture

## Getting Started

> This project is built primarily with declarative Salesforce configuration plus Apex and LWC. Follow the milestones above in order.

**Prerequisites**
- A Salesforce Developer Edition org (or sandbox)
- Admin access to Setup, Object Manager, Flow Builder, and the Developer Console

**Setup outline**
1. Create the `Policy` and `Claim` objects, Record Types, Field Sets, and fields (Milestone 1).
2. Create the validation rule and `AutoQuotingFlow`.
3. Deploy the `PremiumCalculator` Apex class and add it to the flow (Milestone 2).
4. Create the Auto, Property, and Life claim queues, then build the routing flow.
5. Deploy `ClaimsAdjusterController`, `claimsDashboardLwc`, and `claimTileLwc` (Milestone 3).
6. Create the approval process, approval flows, and Quick Action (Milestone 4).
7. Configure sharing rules and Permission Sets, then assign them to users.
8. Add the dashboard to a Lightning App Page or Home Page.

**Configuration notes**
- The claim routing flow uses the queue IDs of your org. Replace them with your own 18-character queue IDs.
- Select the actual Senior Adjuster and Department Manager users in the approval steps.

## Team & License

- **Team Members:** _add names here_
- **License:** _add license (e.g., MIT)_

---

*Multi-Line Insurance Policy and Claims Management System, a Salesforce project.*
