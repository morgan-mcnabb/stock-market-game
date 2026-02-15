"""
Generate stock_data.csv for the Stock Market Game.

Pulls historical daily price data via yfinance for a diversified set of tickers,
pairs each row with a headline derived from the price move, and writes the result
to assets/data/stock_data.csv.

Requirements:
    pip install yfinance pandas

Usage:
    python scripts/generate_stock_data.py
"""

import csv
import os
import random
from datetime import datetime, timedelta

try:
    import yfinance as yf
    import pandas as pd
    HAS_YFINANCE = True
except ImportError:
    HAS_YFINANCE = False

# --- Configuration ---

TICKERS = {
    # Technology
    "AAPL": "Apple Inc.",
    "MSFT": "Microsoft Corp.",
    "GOOGL": "Alphabet Inc.",
    "AMZN": "Amazon.com Inc.",
    "NVDA": "NVIDIA Corp.",
    "META": "Meta Platforms Inc.",
    "TSLA": "Tesla Inc.",
    "CRM": "Salesforce Inc.",
    "ADBE": "Adobe Inc.",
    "INTC": "Intel Corp.",
    # Finance
    "JPM": "JPMorgan Chase & Co.",
    "BAC": "Bank of America Corp.",
    "GS": "Goldman Sachs Group",
    "V": "Visa Inc.",
    "MA": "Mastercard Inc.",
    # Healthcare
    "JNJ": "Johnson & Johnson",
    "PFE": "Pfizer Inc.",
    "UNH": "UnitedHealth Group",
    "ABBV": "AbbVie Inc.",
    "MRK": "Merck & Co.",
    # Consumer
    "KO": "Coca-Cola Co.",
    "PEP": "PepsiCo Inc.",
    "MCD": "McDonald's Corp.",
    "NKE": "Nike Inc.",
    "SBUX": "Starbucks Corp.",
    "WMT": "Walmart Inc.",
    "DIS": "Walt Disney Co.",
    "NFLX": "Netflix Inc.",
    # Energy
    "XOM": "Exxon Mobil Corp.",
    "CVX": "Chevron Corp.",
    # Industrial / Other
    "BA": "Boeing Co.",
    "CAT": "Caterpillar Inc.",
    "UPS": "United Parcel Service",
    "DE": "Deere & Co.",
    "GE": "GE Aerospace",
}

# Headline templates keyed by direction and magnitude bucket
HEADLINES_UP = {
    "small": [
        "{company} edges higher after steady trading session",
        "{company} posts modest gains amid market optimism",
        "{company} ticks up on light volume",
        "{company} sees slight uptick following analyst commentary",
    ],
    "medium": [
        "{company} rallies on strong quarterly results",
        "{company} jumps after upbeat earnings guidance",
        "{company} surges as revenue beats Wall Street estimates",
        "{company} climbs on news of expanded partnerships",
        "{company} gains ground after positive product reviews",
    ],
    "large": [
        "{company} soars on blockbuster earnings surprise",
        "{company} rockets higher after landmark deal announcement",
        "{company} skyrockets as market reacts to breakthrough news",
        "{company} explodes upward on massive demand surge",
    ],
}

HEADLINES_DOWN = {
    "small": [
        "{company} dips slightly in cautious trading",
        "{company} slips on mixed market signals",
        "{company} edges lower amid sector rotation",
        "{company} sees minor pullback after recent gains",
    ],
    "medium": [
        "{company} drops after disappointing earnings report",
        "{company} falls as analysts downgrade outlook",
        "{company} slides on weaker-than-expected guidance",
        "{company} declines amid supply chain concerns",
        "{company} retreats following regulatory scrutiny",
    ],
    "large": [
        "{company} plunges on shocking earnings miss",
        "{company} tumbles after major product recall announced",
        "{company} crashes as CEO departure rattles investors",
        "{company} nosedives on fraud investigation reports",
    ],
}

OUTPUT_PATH = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "assets", "data", "stock_data.csv",
)

TARGET_ROWS = 160


def _magnitude(pct: float) -> str:
    """Classify percent change into a magnitude bucket."""
    abs_pct = abs(pct)
    if abs_pct < 2:
        return "small"
    elif abs_pct < 5:
        return "medium"
    else:
        return "large"


def _headline(company: str, direction: str, pct: float) -> str:
    bucket = _magnitude(pct)
    templates = HEADLINES_UP[bucket] if direction == "up" else HEADLINES_DOWN[bucket]
    return random.choice(templates).format(company=company)


def generate_with_yfinance() -> list[dict]:
    """Pull real historical data via yfinance."""
    rows = []
    per_ticker = max(4, TARGET_ROWS // len(TICKERS) + 1)

    for ticker, company in TICKERS.items():
        try:
            stock = yf.Ticker(ticker)
            hist = stock.history(period="2y")
            if hist.empty:
                print(f"  Skipping {ticker}: no data")
                continue

            # Sample random trading days
            indices = list(range(len(hist) - 1))
            sampled = random.sample(indices, min(per_ticker, len(indices)))

            for i in sampled:
                price_before = round(hist.iloc[i]["Close"], 2)
                price_after = round(hist.iloc[i + 1]["Close"], 2)
                date_str = hist.index[i + 1].strftime("%Y-%m-%d")
                pct = round(((price_after - price_before) / price_before) * 100, 2)
                direction = "up" if price_after >= price_before else "down"

                rows.append({
                    "ticker": ticker,
                    "company_name": company,
                    "headline": _headline(company, direction, pct),
                    "date": date_str,
                    "price_before": price_before,
                    "price_after": price_after,
                    "direction": direction,
                    "percent_change": pct,
                })
        except Exception as e:
            print(f"  Error fetching {ticker}: {e}")

    return rows


def generate_synthetic() -> list[dict]:
    """Generate plausible synthetic data when yfinance is unavailable."""
    rows = []
    random.seed(42)
    base_prices = {
        "AAPL": 175, "MSFT": 380, "GOOGL": 140, "AMZN": 180, "NVDA": 450,
        "META": 500, "TSLA": 250, "CRM": 270, "ADBE": 550, "INTC": 35,
        "JPM": 195, "BAC": 37, "GS": 430, "V": 280, "MA": 460,
        "JNJ": 155, "PFE": 28, "UNH": 530, "ABBV": 175, "MRK": 125,
        "KO": 60, "PEP": 170, "MCD": 290, "NKE": 95, "SBUX": 95,
        "WMT": 165, "DIS": 110, "NFLX": 620, "XOM": 105, "CVX": 155,
        "BA": 210, "CAT": 320, "UPS": 145, "DE": 390, "GE": 160,
    }
    start_date = datetime(2023, 1, 2)

    per_ticker = max(4, TARGET_ROWS // len(TICKERS) + 1)

    for ticker, company in TICKERS.items():
        base = base_prices.get(ticker, 100)
        for j in range(per_ticker):
            day_offset = random.randint(0, 500)
            date = start_date + timedelta(days=day_offset)
            # Skip weekends
            while date.weekday() >= 5:
                date += timedelta(days=1)

            pct = round(random.gauss(0, 3.5), 2)
            pct = max(-15, min(15, pct))
            price_before = round(base * (1 + random.uniform(-0.15, 0.15)), 2)
            price_after = round(price_before * (1 + pct / 100), 2)
            direction = "up" if pct >= 0 else "down"

            rows.append({
                "ticker": ticker,
                "company_name": company,
                "headline": _headline(company, direction, pct),
                "date": date.strftime("%Y-%m-%d"),
                "price_before": price_before,
                "price_after": price_after,
                "direction": direction,
                "percent_change": pct,
            })

    return rows


def write_csv(rows: list[dict]) -> None:
    random.shuffle(rows)
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "ticker", "company_name", "headline", "date",
            "price_before", "price_after", "direction", "percent_change",
        ])
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} rows to {OUTPUT_PATH}")


def main():
    if HAS_YFINANCE:
        print("Fetching data via yfinance...")
        rows = generate_with_yfinance()
        if len(rows) < TARGET_ROWS:
            print(f"Only got {len(rows)} rows from yfinance, supplementing with synthetic data...")
            rows.extend(generate_synthetic())
    else:
        print("yfinance not installed, generating synthetic data...")
        rows = generate_synthetic()

    # Trim to target if we overshot
    if len(rows) > TARGET_ROWS + 20:
        rows = random.sample(rows, TARGET_ROWS)

    write_csv(rows)


if __name__ == "__main__":
    main()
