# Project Brief: Barangay San Rafael Document Services & Resident Records System

## 1. The problem
Barangay San Rafael staff and residents currently rely on manual logbooks and repeated entry of resident and fee details, which causes misplaced files, slow document issuance, and data inconsistencies. Residents need faster, clearer requests for barangay certificates, while staff need accurate resident, household, and issuance records.

## 2. Users and what they need to do
| User role | What they need to do in the app |
|-----------|---------------------------------|
| Resident | View available document types and fees, submit a document request, check request status |
| Barangay Official / Staff | Manage resident and household records, process and release document requests, manage document types and zone leaders |
| Guest | Browse public document types and standard fees, log in or register/request access |

## 3. The database behind it
The database is named `barangay_db` and has 6 tables:
- `zone`: Stores barangay zones and optionally assigns a unique zone leader (`leader_id`).
- `household`: Stores unique house numbers, street names, and the zone each household belongs to.
- `resident`: Stores resident personal details, contact numbers, and which household each resident lives in.
- `document_type`: Stores available certificate/document names and their standard fees.
- `official`: Links eligible residents to an official barangay position.
- `document_request`: Tracks each resident's document request, purpose, processing official, request/release timestamps, and amount paid.

## 4. Must-have features (for the final project)
- **List** and search residents, households, and document requests.
- **Create** new resident records, household records, and document requests.
- **Update** resident details, zone leadership, and document request release/payment status.
- **Manage** document types and fees in a central catalog.
- **View** detailed resident and document request records with related zone, household, and official information.

## 5. Nice-to-have features (only if there's time)
- Filter document requests by release status (pending vs. released) and date range.
- Export or print a clean summary view of released document requests.
- Display dashboard summary counts for residents, zones, and requests.

## 6. Similar apps I looked at
- **eGov PH / LGU Citizen Portals:** Borrow the clear separation between public service/fee info and staff processing workflows.
- **Simple Inventory / Ticketing Trackers:** Borrow clean filterable tables, clear status indicators, and straightforward create/edit forms.