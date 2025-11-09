
### CLI USAGE
# python cedmate_analytics_plugin.py --user Larissa



### IMPORT AS MODULE
#from cedmate_analytics_plugin import generate_analytics_for_user

#files = generate_analytics_for_user("Larissa")
#print(files)



### INTEGRATE INTO FLUTTER
#Process.run('python', ['cedmate_analytics_plugin.py', '--user', userId]);



"""
CEDmate Analytics Plugin
=======================

A modular analytics generator for Firestore-based CEDmate data.

Features:
 - User-specific analytics (username is a parameter)
 - Generates PNGs for:
    * Stuhlgang (color-coded scatter)
    * Stimmung (line curve)
    * Symptome (color-coded scatter)
 - Mahlzeit intentionally ignored (pass)
 - Can be used as CLI or imported as module
 - No hard-coded values
"""

import argparse
from pathlib import Path
import matplotlib.pyplot as plt
import pandas as pd
import firebase_admin
from firebase_admin import credentials, firestore

# -------------------------------------------------------------------
# INITIALIZATION
# -------------------------------------------------------------------

OUTPUT_DIR = Path("output")
OUTPUT_DIR.mkdir(exist_ok=True)


def connect_firestore(service_account_path="lib\\analytics\\serviceAccount.json"):
    """Initialize Firestore connection lazily and safely."""
    cred = credentials.Certificate(service_account_path)

    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app(cred)

    return firestore.client()


# -------------------------------------------------------------------
# FIRESTORE FETCH HELPERS
# -------------------------------------------------------------------

def fetch_for_user(db, collection_name, user_id):
    """
    Fetches all documents from a top-level collection where userId == user_id.
    This matches CEDmate's actual Firestore design.
    """
    docs = (
        db.collection(collection_name)
        .where("userId", "==", user_id)
        .get()
    )

    rows = []
    for d in docs:
        entry = d.to_dict()
        entry["id"] = d.id

        # convert Firestore Timestamp → datetime
        for key, val in entry.items():
            if hasattr(val, "to_datetime"):
                entry[key] = val.to_datetime()

        rows.append(entry)

    return pd.DataFrame(rows) if rows else pd.DataFrame()


# -------------------------------------------------------------------
# GRAPH GENERATION
# -------------------------------------------------------------------

def plot_stuhlgang(df, user_id):
    if df.empty:
        print(f"No stuhlgang entries for '{user_id}'.")
        return None

    time_col = [c for c in df.columns if "zeit" in c.lower()][0]
    numeric_cols = df.select_dtypes(include="number").columns

    if len(numeric_cols) == 0:
        print("No numeric stuhlgang fields found.")
        return None

    value_col = numeric_cols[0]
    out_path = OUTPUT_DIR / f"stuhlgang_scatter_{user_id}.png"

    plt.figure(figsize=(10, 5))
    plt.scatter(df[time_col], df[value_col], c=df[value_col])
    plt.xlabel("Zeit")
    plt.ylabel(value_col)
    plt.title(f"Stuhlgang – {user_id}")
    plt.tight_layout()
    plt.savefig(out_path)
    plt.close()

    return out_path


def plot_stimmung(df, user_id):
    if df.empty:
        print(f"No stimmung entries for '{user_id}'.")
        return None

    time_col = [c for c in df.columns if "zeit" in c.lower()][0]

    if "wert" not in df.columns:
        print("Stimmung entries missing 'wert' field.")
        return None

    df = df.sort_values(time_col)
    out_path = OUTPUT_DIR / f"stimmung_line_{user_id}.png"

    plt.figure(figsize=(10, 5))
    plt.plot(df[time_col], df["wert"])
    plt.xlabel("Zeit")
    plt.ylabel("Stimmungswert")
    plt.title(f"Stimmung – {user_id}")
    plt.tight_layout()
    plt.savefig(out_path)
    plt.close()

    return out_path


def plot_symptome(df, user_id):
    if df.empty:
        print(f"No symptome entries for '{user_id}'.")
        return None

    time_col = [c for c in df.columns if "zeit" in c.lower()][0]
    numeric_cols = df.select_dtypes(include="number").columns

    if len(numeric_cols) == 0:
        print("No numeric symptom fields found.")
        return None

    value_col = numeric_cols[0]
    out_path = OUTPUT_DIR / f"symptome_scatter_{user_id}.png"

    plt.figure(figsize=(10, 5))
    plt.scatter(df[time_col], df[value_col], c=df[value_col])
    plt.xlabel("Zeit")
    plt.ylabel("Symptomstärke")
    plt.title(f"Symptome – {user_id}")
    plt.tight_layout()
    plt.savefig(out_path)
    plt.close()

    return out_path


# -------------------------------------------------------------------
# MAHLZEIT (ignored)
# -------------------------------------------------------------------

def plot_mahlzeit(_df, user_id):
    print(f"Mahlzeit ignored for now (pass for user '{user_id}').")
    return None


# -------------------------------------------------------------------
# MAIN ENTRY POINT: GENERATE ANALYTICS FOR ANY USER
# -------------------------------------------------------------------

def generate_analytics_for_user(user_id, service_account="serviceAccount.json"):
    """
    Unified function for plugin-like use.
    Returns dict: {graph_type: file_path or None}
    """

    db = connect_firestore(service_account)

    collections = {
        "stuhlgang": fetch_for_user(db, "stuhlgang", user_id),
        "stimmung": fetch_for_user(db, "stimmung", user_id),
        "symptome": fetch_for_user(db, "symptome", user_id),
        "mahlzeit": fetch_for_user(db, "mahlzeit", user_id),
    }

    output = {
        "stuhlgang": plot_stuhlgang(collections["stuhlgang"], user_id),
        "stimmung": plot_stimmung(collections["stimmung"], user_id),
        "symptome": plot_symptome(collections["symptome"], user_id),
        "mahlzeit": plot_mahlzeit(collections["mahlzeit"], user_id),
    }

    return output


# -------------------------------------------------------------------
# CLI WRAPPER
# -------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Generate CEDmate analytics for a specific user.")
    parser.add_argument("--user", required=True, help="UserId to analyze (from Firestore documents)")
    parser.add_argument("--creds", default="serviceAccount.json", help="Path to Firebase service account")

    args = parser.parse_args()

    results = generate_analytics_for_user(args.user, args.creds)

    print("\n✓ Analytics complete.")
    for k, v in results.items():
        if v:
            print(f"  {k}: {v}")
        else:
            print(f"  {k}: no output")


if __name__ == "__main__":
    main()
