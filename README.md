# 🏦 Project P_137: Bank Muscat Intelligent Retail Credit Risk & MLOps Platform

An end-to-end Machine Learning, Explainable AI (XAI), and MLOps production platform designed for **Bank Muscat's retail credit underwriting**. The system automates personal loan default assessment, slashes Non-Performing Assets (NPAs), provides audit-ready explainability for regulators, and continuously monitors macroeconomic data drift.

---

## 🎯 Key Business & Model Performance

| Metric | Target | Achieved (XGBoost Champion) | Business Impact |
| :--- | :--- | :--- | :--- |
| **ROC-AUC** | $\ge 85.0\%$ | **94.83%** | Superior discrimination between good & defaulting applicants |
| **PR-AUC** | — | **90.26%** | High precision at top percentile risk rankings |
| **F1-Score** | — | **0.829** | Precision: 0.928 \| Recall: 0.748 |
| **Baseline Portfolio NPA** | — | **21.81%** | Unfiltered historical default rate |
| **Post-Model Portfolio NPA** | — | **6.67%** | Default rate among approved applicants |
| **Relative NPA Reduction** | $\ge 30.0\%$ | **69.43%** | **Target exceeded by +39.43%** |
| **Defaults Caught** | — | **74.81%** | 3 out of every 4 defaults blocked |
| **Loan Approval Rate** | — | **82.43%** | Preserves core retail lending volumes |

---

## 🏗️ System Architecture

```
P_137_Bank_Muscat_Project/
├── Dockerfile                  # Container definition (Python 3.11-slim)
├── requirements.txt            # Python dependencies (scikit-learn, xgboost, shap, fastapi, etc.)
├── run_pipeline.py             # End-to-end ML & MLOps retraining CLI pipeline
├── mlflow.db                   # SQLite database storing MLflow experiment runs and metrics
│
├── app/                        # Serving & Application Layer
│   ├── main.py                 # FastAPI REST service (/score, /monitoring/drift, /metrics/npa, /health)
│   ├── database.py             # SQLAlchemy ORM (PostgreSQL with SQLite fallback)
│   └── streamlit_app.py        # Streamlit 3-tab executive risk dashboard
│
├── src/                        # ML Pipeline Modules
│   ├── preprocessing.py        # Outlier cleaning, banking ratio engineering, ColumnTransformer
│   ├── train_and_evaluate.py   # Multi-model training (LR, RF, XGBoost) & NPA evaluation
│   └── drift_monitoring.py     # Macroeconomic drift simulation, KS-tests, EvidentlyAI report
│
├── data/                       # Datasets & Database Storage
│   ├── raw_bank_muscat_loans.csv         # Raw loan application records (32,582 rows)
│   ├── reference_train.csv               # Baseline training dataset (26,059 rows)
│   ├── current_test.csv                  # Holdout test dataset (6,516 rows)
│   ├── production_drifted_batch.csv      # Synthetic macroeconomic shock batch (6,516 rows)
│   └── bank_muscat_postgres_fallback.db  # SQLite fallback prediction log database
│
├── models/                     # Model Registry & Artifacts
│   ├── best_model.pkl          # Champion model (XGBoost)
│   ├── xgboost.pkl             # Trained XGBoost estimator
│   ├── random_forest.pkl       # Trained Random Forest estimator
│   ├── logistic_regression.pkl # Trained Logistic Regression estimator
│   ├── preprocessor.pkl        # Fitted ColumnTransformer (scaling & encoding)
│   ├── shap_explainer.pkl      # Fitted SHAP TreeExplainer
│   ├── feature_names.pkl       # Ordered preprocessed feature names
│   └── model_metadata.json     # Performance leaderboard & NPA metrics
│
├── reports/                    # Visualizations & Monitoring Reports
│   ├── roc_comparison.png      # Comparative ROC curves (LR vs RF vs XGB)
│   ├── shap_global_beeswarm.png# Global SHAP feature importance plot
│   ├── shap_local_waterfall.png# Individual loan explainability waterfall
│   ├── drift_summary.json      # Structured drift metrics (KS-stat, p-values, drift flags)
│   └── evidently_drift_report.html # EvidentlyAI interactive HTML report
│
└── deploy/                     # Production Deployment Manifests
    ├── docker-compose.yml      # Orchestrates PostgreSQL, FastAPI, and Streamlit
    └── entrypoint.sh           # Flexible multi-service container entrypoint
```

---

## ⚡ Quickstart Guide

### 1. Local Environment Setup

```bash
# Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Run Full Retraining Pipeline

To reproduce the model artifacts, evaluation metrics, SHAP plots, and drift reports from scratch:

```bash
python run_pipeline.py
```

### 3. Launch FastAPI Serving Backend

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```
Interactive Swagger docs: [http://localhost:8000/docs](http://localhost:8000/docs)

### 4. Launch Streamlit Underwriting Portal

In a new terminal window:
```bash
streamlit run app/streamlit_app.py --server.port 8501
```
Web Dashboard: [http://localhost:8501](http://localhost:8501)

---

## 🐳 Docker Deployment & Quickstart

### 🚀 Pull & Run Directly from Docker Hub (Zero Setup):
Aapka containerized platform Docker Hub par publicly available hai:

```bash
docker run -d -p 8501:8501 -p 8000:8000 raghav989/loan-default-prediction:latest
```

- **Frontend (Streamlit UI):** [http://localhost:8501](http://localhost:8501)
- **Backend (FastAPI Docs):** [http://localhost:8000/docs](http://localhost:8000/docs)

### 🛠️ Re-build or Update Image:
```bash
./docker_push.sh sajal2207
```

### 2. Run Single Docker Container Locally:
```bash
# Build:
docker build -t loan-default-prediction .

# Run both FastAPI (8000) and Streamlit (8501):
docker run -p 8000:8000 -p 8501:8501 loan-default-prediction
```
Web Dashboard: [http://localhost:8501](http://localhost:8501)
API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)

### 3. Run Multi-Container with PostgreSQL via Docker Compose:
```bash
docker compose up --build
```

---

## 📡 API Reference

### `POST /score`
Scores a retail loan applicant, outputs probability, risk tier, underwriting decision, and top SHAP risk factors.

**Request Body (`application/json`):**
```json
{
  "person_age": 30,
  "person_income": 55000.0,
  "person_emp_length": 5.0,
  "loan_amnt": 15000.0,
  "loan_int_rate": 11.5,
  "loan_grade": "B",
  "loan_intent": "PERSONAL",
  "cb_person_default_on_file": "N",
  "cb_person_cred_hist_length": 5.0,
  "person_home_ownership": "RENT"
}
```

**Response (`200 OK`):**
```json
{
  "default_probability": 0.1245,
  "risk_tier": "LOW RISK",
  "decision": "APPROVED",
  "optimal_threshold": 0.35,
  "top_shap_drivers": [
    {
      "feature": "loan_to_income_ratio",
      "shap_impact": 0.3124
    },
    {
      "feature": "loan_int_rate",
      "shap_impact": 0.1856
    },
    {
      "feature": "interest_burden_ratio",
      "shap_impact": 0.1142
    },
    {
      "feature": "loan_percent_income",
      "shap_impact": 0.0891
    }
  ]
}
```

### Other Endpoints:
- `GET /health`: Healthcheck endpoint returning model, preprocessor, and DB status.
- `GET /metrics/npa`: Returns portfolio-level NPA reduction metrics.
- `GET /monitoring/drift`: Returns current Kolmogorov-Smirnov drift test results across monitored features.

---

## 🔍 Explainability & MLOps Features

1. **SHAP (SHapley Additive exPlanations)**:
   - Global beeswarm summary plot saved to [`reports/shap_global_beeswarm.png`](file:/Users/sajalmittal/Desktop/P_137_Bank_Muscat_Project/reports/shap_global_beeswarm.png).
   - Local waterfall plot per decision saved to [`reports/shap_local_waterfall.png`](file:/Users/sajalmittal/Desktop/P_137_Bank_Muscat_Project/reports/shap_local_waterfall.png).
2. **Audit Logging**:
   - Every inference request is persisted into `loan_prediction_logs` table (PostgreSQL / SQLite) with timestamp, inputs, predicted probability, and top SHAP drivers for regulatory compliance.
3. **Data Drift Monitoring (EvidentlyAI & KS-Test)**:
   - Macroeconomic stress scenario tested: rising interest rates ($+2.8\%$), income contraction ($-15\%$), and higher loan demand ($+15\%$).
   - Flags 5 of 8 features drifting with automated alert (`⚠️ DRIFT ALERT: Retraining Recommended`).
   - Detailed interactive report in [`reports/evidently_drift_report.html`](file:/Users/sajalmittal/Desktop/P_137_Bank_Muscat_Project/reports/evidently_drift_report.html).
