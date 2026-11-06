import pandas as pd
from pathlib import Path

input_path = Path.home() / "Downloads" / "p3k14c_data.csv"
output_path = Path.home() / "Downloads" / "raw_south_america_radiocarbon.csv"

south_america = [
    "ARGENTINA", "BOLIVIA", "BRAZIL", "CHILE", "COLOMBIA", 
    "ECUADOR", "FRENCH GUIANA", "GUYANA", "PARAGUAY", 
    "PERU", "SURINAME", "URUGUAY", "VENEZUELA"
]

df = pd.read_csv(input_path, encoding="utf-8", on_bad_lines="skip", low_memory=False)

country_col = next((c for c in df.columns if c.lower() == "country"), None)

cols_lower = {c.lower(): c for c in df.columns}
for num_col in ["d13c", "age", "error", "lat", "long"]:
    if num_col in cols_lower:
        actual_col = cols_lower[num_col]
        df[actual_col] = pd.to_numeric(df[actual_col], errors="coerce")

df["_temp_country"] = df[country_col].astype(str).str.strip().str.upper()
sa_df = df[df["_temp_country"].isin(south_america)].copy()
sa_df = sa_df.drop(columns=["_temp_country"])

sa_df.to_csv(output_path, index=False, encoding="utf-8")
print(f"Done! Saved {len(sa_df)} clean rows to {output_path}")