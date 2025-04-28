import pandas as pd

def add_speed_index(df: pd.DataFrame) -> pd.DataFrame:
    """Add speed_index = distance / time (m/s)."""
    df = df.copy()
    df["speed_index"] = df["distance"] / df["time"]
    return df

def add_furlongs(df: pd.DataFrame) -> pd.DataFrame:
    """Convert distance to furlongs (1 furlong = 201.168 m)."""
    df = df.copy()
    df["distance_furlong"] = df["distance"] / 201.168
    return df