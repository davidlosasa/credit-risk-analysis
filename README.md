# 📊 Credit Risk Analysis Project

This project focuses on **credit risk analysis** through a structured, end-to-end data workflow designed to handle **large datasets efficiently** and produce **actionable insights for credit decision-making**.

The project follows a clear separation of concerns:

* **SQL Server** for heavy data preparation and processing
* **Excel** for exploratory analysis and KPI calculation
* **Tableau** for final visualization and dashboarding

---

## 📁 Data Sources

The data comes from the *Credit Card Approval Prediction* dataset available on Kaggle:

* **`application_record.csv`**
  Customer demographic and socio-economic information
  Source: [https://www.kaggle.com/datasets/rikdifos/credit-card-approval-prediction](https://www.kaggle.com/datasets/rikdifos/credit-card-approval-prediction)

* **`credit_record.csv`**
  Credit payment behavior and loan status over time
  Source: [https://www.kaggle.com/datasets/rikdifos/credit-card-approval-prediction](https://www.kaggle.com/datasets/rikdifos/credit-card-approval-prediction)

---

## 🧱 Technical Workflow

### 1) Data Ingestion (SQL Server)

* Imported large CSV files into **SQL Server** to efficiently manage data volume
* Created relational tables for structured processing

### 2) Data Preparation (SQL Server)

* Renamed and standardized column names
* Converted data types (dates, numeric fields, categorical values)
* Removed duplicate records
* Cleaned inconsistent categorical values
* Created derived features (e.g. age, employment duration, loan status labels)

### 3) Data Processing & Modeling (SQL Server)

* Joined application and credit records
* Identified and handled missing values
* Filtered irrelevant fields
* Built a **final analytical dataset** ready for business analysis

### 4) Export for Analysis

* Exported the cleaned and processed dataset from SQL Server to **CSV format**
* Ensured compatibility for downstream analysis tools

### 5) Exploratory Analysis (Excel)

* Pivot tables to analyze:

  * Loan status distribution
  * Overdue and bad debt patterns
  * Client segmentation by income, occupation, family status, housing type
* KPI calculation:

  * Percentage of overdue clients
  * Percentage of bad debt
  * Average income by loan status

### 6) Data Visualization (Tableau)

* Built an interactive dashboard to:

  * Monitor loan status distribution
  * Compare risk across income and occupation types
  * Support credit approval insights through KPIs and filters

---

## 🎯 Main Objectives

* Analyze credit risk based on customer demographic and financial characteristics
* Identify behavioral patterns associated with overdue payments and bad debt
* Provide structured insights to support **credit approval and risk assessment decisions**

---

## 📦 Deliverables

* **SQL scripts**

  * Data ingestion
  * Data preparation
  * Data processing and feature engineering

* **Excel analysis file**

  * Pivot tables
  * KPI calculations

* **Tableau dashboard**

  * Interactive visualizations
  * Credit risk monitoring KPIs

---

## 🧠 Key Insights (High-Level)

* A significant portion of clients experience payment delays
* Higher income does not fully eliminate default risk
* Certain occupation types contribute disproportionately to bad debt
* Credit risk is better explained through **combined variables** rather than isolated attributes

---

## 👤 Author

**David Losasa**
Data Analyst
SQL • Excel • Tableau • Credit Risk Analysis

---
