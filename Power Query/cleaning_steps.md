# 🧹 Power Query Cleaning Steps
## Healthcare Dataset — Full Transformation Documentation

---

## Dataset Overview

| Property | Detail |
|---|---|
| **Source** | Raw Healthcare Appointments Dataset |
| **Initial Row Count** | 1,528 records (after combining both halves) |
| **Final Row Count** | 1,528 records |
| **Columns** | 30+ across patient, appointment, doctor and hospital data |
| **Tool Used** | Microsoft Excel — Power Query Editor |
| **Date Cleaned** | 2026 |

---

## ⚠️ Issues Found in Raw Data

Before cleaning began, the following issues were identified across the dataset:

- Duplicate appointment records
- Date columns with multiple inconsistent formats
- Erroneous date entries including years like "1814"
- Appointment time not formatted as proper time values
- Categorical columns with multiple spellings of same value
- Blank Patient IDs across 10 records
- Hidden spaces and formatting inconsistencies in text columns
- Negative billing amounts requiring investigation
- Missing blood group values
- Missing gender values (34 records)
- Missing appointment date values
- Invalid placeholder entries — N/A, NA, ???, ?
- Inconsistent appointment status values

---

## 📋 Cleaning Steps — Applied in Order

---

### Step 1 — Removed Duplicates

**Problem:**
Dataset contained duplicate appointment records that would inflate counts and distort analysis.

**Action:**
- Used **Appointment_ID** as the unique identifier
- Home tab → Remove Rows → Remove Duplicates
- Selected Appointment_ID column specifically to ensure each appointment appeared exactly once

**Result:** All duplicate records removed. Appointment_ID confirmed as unique key.

**Business Reasoning:**
Appointment_ID is system-generated and should be unique per appointment. Any duplicate represents a data entry or system error not a real repeat appointment.

---

### Step 2 — Standardized Date Columns

**Problem:**
Date columns contained multiple inconsistent formats across the dataset including:
- DD/MM/YYYY
- MM/DD/YYYY
- YYYY-MM-DD
- Text strings
- Erroneous entries like "1814" which are clearly data entry errors

**Action:**
- Changed column type to Date for all date columns
- Created a **Conditional Column** to identify and flag erroneous date entries
- Applied rule: if year component is less than 1900 → replace with null
- Standardized all remaining dates to consistent YYYY-MM-DD format

**Result:** All dates in consistent format. Erroneous entries replaced with null.

**Business Reasoning:**
Cannot assume what the correct date should be for erroneous entries — replacing with null is more honest than imputing a wrong date which would corrupt trend analysis.

---

### Step 3 — Fixed Appointment Time Column

**Problem:**
Appointment_Time column was stored as a text string rather than a proper time data type — preventing any time-based analysis.

**Action:**
- Selected Appointment_Time column
- Changed column type to **Time**
- Handled any values that failed conversion by replacing with null

**Result:** Appointment_Time converted to proper time format enabling hour-of-day analysis.

---

### Step 4 — Built Mapping Tables for Inconsistent Categories

**Problem:**
Multiple categorical columns had inconsistent spellings representing the same value:
- "Schedueld", "Scheduled", "Schedualed" → should all be "Scheduled"
- "Canceld", "Cancelled", "Canceled" → should all be "Cancelled"
- Similar issues in appointment type and other categorical columns

**Action:**
- Created **Mapping Tables** as separate queries for affected columns
- Each mapping table contained two columns: Original Value and Standardized Value
- Merged mapping tables back to main dataset using Merge Queries
- Replaced original column with standardized values

**Result:** All categorical columns standardized to consistent values with no spelling variations.

**Business Reasoning:**
Mapping tables are preferable to manual find-and-replace because they are auditable, reusable and automatically handle new variations if data is refreshed.

---

### Step 5 — Handled NULL Patient IDs

**Problem:**
10 records had blank/missing Patient_ID values.

**Investigation:**
Before deciding how to handle these records, the associated columns were reviewed. These 10 records contained:
- Valid Appointment_IDs
- Valid Doctor_IDs
- Valid billing amounts
- Valid appointment dates

**Decision:**
Retained all 10 records with Patient_ID left as **NULL.**

**Action:**
- No action taken on Patient_ID column for these records
- Added note in documentation flagging for data team review

**Business Reasoning:**
Deleting these records would destroy real appointment, doctor and billing data. In healthcare, fabricating a Patient_ID is dangerous and unethical. NULL is the honest and correct approach — the data team should investigate and recover the correct IDs from source systems.

**Flag:**
*10 Patient_ID records retained as NULL — flagged for data quality team review and investigation.*

---

### Step 6 — Cleaned and Trimmed Text Columns

**Problem:**
Text columns contained hidden leading spaces, trailing spaces and inconsistent casing that would cause matching failures and inconsistent grouping in analysis.

**Action Applied to All Text Columns:**
- **Transform → Trim** — removed leading and trailing spaces
- **Transform → Clean** — removed non-printable characters
- **Transform → Capitalize Each Word** — standardized name casing where appropriate

**Columns Affected:**
- Vendor_Name / Patient_Name
- Doctor_Name
- Hospital_Name
- City, State columns
- All categorical text columns

**Result:** All text columns clean with no hidden spaces or formatting inconsistencies.

---

### Step 7 — Investigated and Retained Negative Billing Amounts

**Problem:**
Billing_Amount column contained negative values that initially appeared to be data entry errors.

**Investigation:**
Cross-referenced negative billing records with Payment_Status column:
- Several negative amounts were attached to **Insurance Claim** status
- Several had **Paid** status
- Several had **Pending** status
- All negative amounts were large specific numbers — not round numbers typical of errors

**Decision:**
Retained all negative billing amounts as-is.

**Business Reasoning:**
Large specific negative amounts attached to legitimate payment statuses are consistent with insurance adjustments, refunds and credit notes — all normal in healthcare billing. Removing them would distort total billing figures and hide real financial transactions. Flagged for finance team investigation.

**Flag:**
*Negative billing amounts retained — consistent with potential refunds or insurance adjustments. Finance team to investigate and confirm.*

---

### Step 8 — Handled Blank Blood Group Values

**Problem:**
Blood_Group column contained blank/null values.

**Decision:**
Replaced blanks with **"Unknown"**

**Action:**
- Transform → Replace Values
- Find: null → Replace with: Unknown
- Also replaced empty strings

**Business Reasoning:**
Unlike Patient_ID, blood group is not a unique identifier and "Unknown" is a standard acceptable value in healthcare records. The small volume of blank blood groups would not materially affect analysis. Unknown is more informative than null for reporting purposes.

---

### Step 9 — Left Date Blanks as NULL

**Problem:**
Several records had missing appointment date values.

**Decision:**
Left all blank date values as **NULL** — no imputation applied.

**Business Reasoning:**
A date is a specific fact — it cannot be estimated or approximated. Imputing a date that may be wrong would:
- Create false entries in trend analysis
- Corrupt monthly and quarterly reporting
- Misrepresent when appointments actually occurred

NULL dates were excluded from time-based charts in Power BI using visual-level filters while the records themselves were retained in the dataset.

---

### Step 10 — Replaced Small Volume Blanks with Unspecified

**Problem:**
Several columns had a very small number of blank values — 4 rows or fewer — that were not critical identifiers.

**Decision:**
Replaced blanks with **"Unspecified"** where the volume was small and the column was not a critical identifier.

**Action:**
- Transform → Replace Values
- Find: null → Replace with: Unspecified
- Applied only to low-volume non-critical columns

**Business Reasoning:**
For non-critical columns with very few blanks, Unspecified is more useful than null for filtering and grouping in reports. The small volume (under 0.5% of records) means this does not materially affect analysis integrity.

---

### Step 11 — Replaced Invalid Placeholder Entries

**Problem:**
Multiple columns contained invalid placeholder values used during data entry:
- N/A
- NA
- ???
- ?
- Blank strings

**Action:**
- Transform → Replace Values applied systematically across all affected columns
- All invalid placeholders replaced with **"Unspecified"**

**Result:** No invalid placeholder values remain in the dataset.

---

### Step 12 — Created Age Column

**Problem:**
No age column existed in the raw data — only Patient_DOB (Date of Birth).

**Action:**
Added a Custom Column with formula:
```
= Date.Year(DateTime.LocalNow()) - Date.Year([Patient_DOB])
```

**Result:** Age column created for every patient record.

---

### Step 13 — Created Age Range Column

**Problem:**
Individual age values are difficult to analyze at scale — grouping into ranges enables demographic segmentation.

**Action:**
Added a Conditional Column with the following logic:

| Age Range | Condition |
|---|---|
| Young Adult | Age >= 18 AND Age <= 30 |
| Adult | Age >= 31 AND Age <= 45 |
| Middle Aged | Age >= 46 AND Age <= 60 |
| Senior | Age >= 61 AND Age <= 75 |
| Elderly | Age > 75 |

**Business Reasoning:**
Age ranges enable the healthcare provider to identify which demographic groups have the highest no-show rates and billing issues — enabling targeted intervention strategies.

---

## 🔄 Automation Test — Second Half Validation

**Purpose:**
To validate that the cleaning pipeline was robust and repeatable before loading to Azure SQL.

**Method:**
1. Dataset was intentionally divided into two equal halves before cleaning
2. First half was cleaned through all 13 steps above
3. Second half was appended to the source sheet in Power Query
4. Refresh was triggered in Power Query

**Result:**
Every single cleaning step applied automatically to the second half of the data:
- ✅ Date standardization applied
- ✅ Mapping tables matched and standardized categories
- ✅ Text trimming applied
- ✅ Age and Age Range columns calculated
- ✅ Invalid placeholders replaced
- ✅ Null handling applied correctly

**Conclusion:**
Pipeline confirmed as robust and repeatable. Ready for Azure SQL load.

---

## 📊 Before and After Summary

| Issue | Before Cleaning | After Cleaning |
|---|---|---|
| Duplicates | Present | ✅ Removed |
| Date formats | Inconsistent | ✅ Standardized |
| Erroneous dates | Present (e.g. 1814) | ✅ Replaced with NULL |
| Appointment time | Text format | ✅ Proper time type |
| Category spelling | Inconsistent | ✅ Standardized via mapping |
| Patient ID blanks | 10 records | ✅ Retained as NULL — flagged |
| Hidden spaces | Present | ✅ Trimmed and cleaned |
| Negative billing | Present | ✅ Retained — flagged for finance |
| Blood group blanks | Present | ✅ Replaced with Unknown |
| Date blanks | Present | ✅ Retained as NULL |
| Invalid entries (N/A, ???) | Present | ✅ Replaced with Unspecified |
| Age column | Missing | ✅ Created from DOB |
| Age Range column | Missing | ✅ Created with 5 groups |

---

## 💡 Key Data Quality Decisions

| Decision | Approach | Reason |
|---|---|---|
| NULL Patient IDs | Retained as NULL | Cannot fabricate medical identifiers |
| Negative billing | Retained | Consistent with refunds and insurance adjustments |
| Missing dates | Retained as NULL | Cannot impute unknown dates |
| Blood group blanks | Unknown | Acceptable placeholder — not critical identifier |
| Small volume blanks | Unspecified | Volume too small to affect analysis |
| Erroneous dates | NULL | Cannot assume correct date |

---

## ⚠️ Outstanding Data Quality Flags

The following issues were identified during cleaning and flagged for the data team:

**Flag 1 — 10 NULL Patient IDs**
Records retained but Patient_IDs are missing. Data team should cross-reference source systems to recover correct Patient_IDs.

**Flag 2 — Negative Billing Amounts**
Retained for finance team investigation. Finance to confirm whether these represent legitimate refunds, insurance adjustments or data errors.

**Flag 3 — 34 Missing Gender Records**
Gender was not captured for 34 patient records. Reception team should update at next patient visit.

**Flag 4 — 29.27% Missing Age Data in No-Show Records**
A significant proportion of no-show records have no age data limiting demographic analysis. Mandatory age capture policy recommended at registration.

**Flag 5 — Unknown and Unspecified Categories**
Multiple columns contain Unknown or Unspecified values. A data governance policy should enforce complete data capture at point of entry.

---

*Documentation prepared by: Vivian Obinwa Ijeoma*
*Contact: Eceline493@gmail.com*
*Project: HealthFlow Analytics — Healthcare Data Pipeline 2026*
