"""
CEDmate Analytics Plugin
Exports graphs and correlation plots for:
- Mahlzeit
- Stimmung
- Stuhlgang
- Symptome
"""

import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd
import matplotlib.pyplot as plt
from pathlib import Path

OUTPUT = Path("output")
OUTPUT.mkdir(exist_ok=True)

# ---------------------------------------------------------
# 1) Connect to Firestore
# ---------------------------------------------------------
def connect_firestore(service_account_path="serviceAccount.json"):
    cred = credentials.Certificate(service_account_path)
    firebase_admin.initialize_app(cred)
    return firestore.client()

# ---------------------------------------------------------
# 2) Download collections into DataFrames
# ---------------------------------------------------------
def fetch_collection(db, name):
    docs = db.collection(name).get()
    data = []

    for d in docs:
        doc = d.to_dict()
        doc["id"] = d.id

        # Convert Firestore timestamp to Python datetime
        for key, value in doc.items():
            if "Zeit" in key or "zeit" in key.lower():
                try:
                    doc[key] = value.to_datetime()
                except Exception:
                    pass

        data.append(doc)

    return pd.DataFrame(data) if data else pd.DataFrame()

# ---------------------------------------------------------
# 3) Generate basic time-series graphs
# ---------------------------------------------------------
def plot_timeseries(df, time_col, value_col, name):
    if df.empty:
        return

    plt.figure(figsize=(10, 5))
    df = df.sort_values(time_col)
    plt.plot(df[time_col], df[value_col])
    plt.title(f"{name} – Zeitverlauf")
    plt.xlabel("Zeit")
    plt.ylabel(value_col)
    plt.tight_layout()
    plt.savefig(OUTPUT / f"{name}_zeitverlauf.png")
    plt.close()

# ---------------------------------------------------------
# 4) Correlation matrix (Stimmung, Symptome etc.)
# ---------------------------------------------------------
def plot_correlation(df, name):
    if df.empty:
        return

    numeric_df = df.select_dtypes(include="number")
    if numeric_df.empty:
        return

    corr = numeric_df.corr()

    plt.figure(figsize=(8, 6))
    plt.imshow(corr, interpolation='nearest')
    plt.title(f"Korrelationsmatrix – {name}")
    plt.xticks(range(len(corr)), corr.columns, rotation=45)
    plt.yticks(range(len(corr)), corr.columns)
    plt.colorbar()
    plt.tight_layout()
    plt.savefig(OUTPUT / f"{name}_correlation.png")
    plt.close()

# ---------------------------------------------------------
# 5) Main Runner
# ---------------------------------------------------------
def run():
    db = connect_firestore()

    mahlzeit = fetch_collection(db, "mahlzeit")
    stimmung = fetch_collection(db, "stimmung")
    stuhlgang = fetch_collection(db, "stuhlgang")
    symptome = fetch_collection(db, "symptome")

    # Example: Gefühlsskala over time
    if "wert" in stimmung.columns:
        plot_timeseries(stimmung, "stimmungsZeitpunkt", "wert", "stimmung")

    # Example: symptom severity correlation
    plot_correlation(symptome, "symptome")

    print("✅ Export complete. Graphs saved in /output.")

if __name__ == "__main__":
    run()
