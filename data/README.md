# Data

The full dataset (`Tima_CRM - raw.csv`, `Tima_clean.csv`) is **not** included: it contains customer PII
(names, phone numbers, national ID numbers, home and work addresses).

`sample/tima_sample_anonymized.csv` — 100 random rows (seed 42), 26 columns, with identifier and free-text
columns removed (`FullName`, `CardNumber`, phone, `Birthday`, `Street`, `Ward*`, `NameCompany`, `AddressCompany`,
`FullNameFamily`, `CreditInfo`, ...). It is for schema illustration only; do not use it to reproduce the results.

## Key columns

| Column | Meaning |
|---|---|
| `LoanID` | Loan identifier |
| `Số tiền đăng ký vay ban đầu` | Requested amount (VND) |
| `Tiền giải ngân` | Disbursed amount (VND) |
| `Tiền gốc còn lại` | Remaining principal (VND) |
| `Trạng thái` | Loan status: Kết thúc (closed), Đang Vay (active), Nợ Xấu (bad debt) |
| `TS_CREDIT_SCORE_V2` | Internal credit score (CRS) |
| `LongestOverdue` | Longest overdue period (days) |
| `HasBadDebt` / `HasLatePayment` | CIC credit-bureau flags (1/0) |
| `NumberOfLoans` | Number of loans at other credit institutions |
| `ProductCreditName` | Loan product (phone/motorbike/car/SIM pawn, ...) |
| `Salary`, `JobName` | Declared income and occupation |
