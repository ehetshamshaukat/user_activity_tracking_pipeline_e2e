# 🚀 User Activity Analytics: The Bitmasking Approach

## 📌 Project Overview
This project implements an optimized data pipeline to track user activity and calculate:

- **Daily Active Users (DAU)**
- **Weekly Active Users (WAU)**
- **Monthly Active Users (MAU)**

Instead of performing expensive `DISTINCT` counts over massive rolling windows, this project leverages **Bitmasking**.

By representing user activity as a **32-bit integer**, we can determine retention status across any time grain using simple **bitwise arithmetic**, significantly reducing **compute cost** and **query time**.

---

# 🛠 Tech Stack

- **dbt (Data Build Tool)** – Transformation orchestration
- **Snowflake** – Data warehouse
- **SQL** – Advanced window functions and bitwise operations
- **Snowflake Functions**
  - `ARRAY_CONSTRUCT`
  - `BITAND`
  - `GENERATOR`

---

# 📐 Data Pipeline Architecture

The transformation logic is divided into **four stages**.

---

## 1️⃣ Cumulative Activity (`user_cum`)

**Type:** Incremental Model

This model constructs a **state table** of user activity.

### Key Logic
- Uses a **FULL OUTER JOIN**
- Combines:
  - Yesterday's cumulative state
  - Today's raw event logs
- Aggregates active dates into a **Snowflake ARRAY**

This creates a historical activity record per user.

<img width="1323" height="851" alt="Screenshot 2026-03-13 at 5 47 58 AM" src="https://github.com/user-attachments/assets/c5b0078d-50ea-42a7-a9e8-25560649b286" />
---

## 2️⃣ Bitmask Transformation (`date_to_integer`)

This stage converts the **array of active dates** into a **32-bit integer**.

Each bit represents a **specific day in a 31-day rolling window**.

### Bitmask Formula

Example:

| Day Offset | Bit Value |
|-------------|-----------|
| Today | 2^31 |
| Yesterday | 2^30 |
| 2 days ago | 2^29 |

This encoding allows activity history to be stored efficiently.

<img width="1318" height="856" alt="Screenshot 2026-03-13 at 5 49 47 AM" src="https://github.com/user-attachments/assets/e210ee21-ab09-4a24-9aac-fc0b48e6400a" />




---

## 3️⃣ Activity Flagging (`dau_wau_mau`)

This layer determines if a user is active in different time windows using **bitwise operations**.

| Metric | Logic |
|------|------|
| DAU | Check most recent bit |
| WAU | Check last 7 bits |
| MAU | Check last 31 bits |

<img width="1316" height="856" alt="Screenshot 2026-03-13 at 5 50 33 AM" src="https://github.com/user-attachments/assets/4deed3ff-9928-467f-9a35-0bbd275ff72a" />

---

## 4️⃣ Final Metrics Aggregation

The final model aggregates user flags into daily metrics:

- **DAU**
- **WAU**
- **MAU**

The output provides a clean **time-series dataset** ready for analytics dashboards.

<img width="1304" height="852" alt="Screenshot 2026-03-13 at 5 51 45 AM" src="https://github.com/user-attachments/assets/fe7055a9-61a5-4f00-bf64-bba5233f958e" />

---

# 💻 Logic Deep Dive: Bitwise Magic

Using bitwise operators allows retention calculations in **O(1) time complexity**.

| Metric | Logic | Bitwise Check |
|------|------|------|
| **DAU** | Active in last 24 hours | `BITAND(sum_val, 2147483648) > 0` |
| **WAU** | Active in last 7 days | `BITAND(sum_val, 4261412864) > 0` |
| **MAU** | Active in last 31 days | `SUM(bit_value) > 0` |

This approach avoids expensive rolling window scans.

![dau-wau-mau-2026-03-13T16-56-11 818Z](https://github.com/user-attachments/assets/0efd401e-5666-46be-88fb-a6db3707e645)

---

# 🚀 Getting Started

## Prerequisites

- Snowflake Account
- dbt Core or dbt Cloud
- Raw event data loaded into
