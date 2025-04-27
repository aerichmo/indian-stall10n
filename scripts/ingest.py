#!/usr/bin/env python
"""Pull feeds for each track & update status.json"""

import json, pathlib, time, requests, sys, os

TRACKS = ["fairmeadows", "remington", "oaklawn"]
RAW_DIR = pathlib.Path("raw")
RAW_DIR.mkdir(exist_ok=True)

auth = (os.environ["API_USER"], os.environ["API_PASS"])
status = {"generated": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
          "tracks": {}}

for track in TRACKS:
    url = f"https://example-racing-api.com/{track}"
    try:
        r = requests.get(url, auth=auth, timeout=30)
        r.raise_for_status()
        data = r.json()
        (RAW_DIR / f"{track}.json").write_text(json.dumps(data, indent=2))
        status["tracks"][track] = {"state": "OK", "size": len(json.dumps(data))}
        print(f"✅ fetched {track}")
    except Exception as e:
        status["tracks"][track] = {"state": "ERROR", "msg": str(e)}
        print(f"❌ {track} failed: {e}", file=sys.stderr)

pathlib.Path("status.json").write_text(json.dumps(status, indent=2))
