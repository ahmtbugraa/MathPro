#!/usr/bin/env python3
"""
Upload titled screenshots to App Store Connect for all 50 locales.
Uses ASC API to upload iPhone 6.7" screenshots (1290×2796).
"""

import os
import sys
import json
import time
import hashlib
import requests
import jwt
from datetime import datetime, timedelta

# ── ASC Credentials ───────────────────────────────────────────
KEY_ID = "F45A64X9CT"
ISSUER_ID = "aa8b074b-c562-463d-86e6-30dd31eb8ef8"
P8_PATH = "/Users/abk/Downloads/AuthKey_F45A64X9CT.p8"
APP_ID = "6760795201"
VERSION_ID = "e84f3318-f19e-4a5a-a86b-461498ac168c"

BASE_URL = "https://api.appstoreconnect.apple.com/v1"
DISPLAY_TYPE = "APP_IPHONE_67"

# ── Screenshot paths ──────────────────────────────────────────
SCREENSHOTS_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "titled")
SCREENSHOT_FILES = [
    "01-solve-math.jpg",
    "02-learn-step-by-step.jpg",
    "03-master-any-level.jpg",
    "04-snap-crop-solve.jpg",
    "05-review-solutions.jpg",
]

# ASC locale mapping (folder name -> ASC locale code)
ASC_LOCALES = {
    "en-US": "en-US", "en-GB": "en-GB", "en-AU": "en-AU", "en-CA": "en-CA",
    "fr-FR": "fr-FR", "fr-CA": "fr-CA", "de-DE": "de-DE", "es-ES": "es-ES",
    "es-MX": "es-MX", "pt-BR": "pt-BR", "pt-PT": "pt-PT", "it": "it",
    "nl-NL": "nl-NL", "tr": "tr", "hr": "hr", "cs": "cs",
    "da": "da", "fi": "fi", "hu": "hu", "id": "id",
    "ms": "ms", "no": "no", "pl": "pl", "ro": "ro",
    "sk": "sk", "sv": "sv", "vi": "vi", "ca": "ca",
    "sl-SI": "sl", "ja": "ja", "ko": "ko",
    "zh-Hans": "zh-Hans", "zh-Hant": "zh-Hant",
    "ar-SA": "ar-SA", "he": "he", "ur-PK": "ur-PK",
    "ru": "ru", "uk": "uk", "el": "el", "th": "th",
    "hi": "hi", "mr-IN": "mr-IN",
    "bn-BD": "bn-BD", "gu-IN": "gu-IN", "kn-IN": "kn-IN",
    "ml-IN": "ml-IN", "or-IN": "or-IN", "pa-IN": "pa-IN",
    "ta-IN": "ta-IN", "te-IN": "te-IN",
}


def generate_token():
    with open(P8_PATH, "r") as f:
        private_key = f.read()
    now = datetime.utcnow()
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + timedelta(minutes=20),
        "aud": "appstoreconnect-v1",
    }
    return jwt.encode(payload, private_key, algorithm="ES256", headers={"kid": KEY_ID})


def headers():
    return {
        "Authorization": f"Bearer {generate_token()}",
        "Content-Type": "application/json",
    }


def get_version_localizations():
    """Get all existing version localizations for our version."""
    url = f"{BASE_URL}/appStoreVersions/{VERSION_ID}/appStoreVersionLocalizations"
    localizations = {}
    params = {"limit": 200}

    while url:
        resp = requests.get(url, headers=headers(), params=params)
        resp.raise_for_status()
        data = resp.json()
        for item in data["data"]:
            locale = item["attributes"]["locale"]
            localizations[locale] = item["id"]
        url = data.get("links", {}).get("next")
        params = {}  # Only use params for first request

    return localizations


def get_screenshot_sets(localization_id):
    """Get existing screenshot sets for a localization."""
    url = f"{BASE_URL}/appStoreVersionLocalizations/{localization_id}/appScreenshotSets"
    resp = requests.get(url, headers=headers())
    resp.raise_for_status()
    data = resp.json()

    sets = {}
    for item in data["data"]:
        display_type = item["attributes"]["screenshotDisplayType"]
        sets[display_type] = item["id"]
    return sets


def create_screenshot_set(localization_id, display_type):
    """Create a new screenshot set."""
    url = f"{BASE_URL}/appScreenshotSets"
    payload = {
        "data": {
            "type": "appScreenshotSets",
            "attributes": {
                "screenshotDisplayType": display_type,
            },
            "relationships": {
                "appStoreVersionLocalization": {
                    "data": {
                        "type": "appStoreVersionLocalizations",
                        "id": localization_id,
                    }
                }
            },
        }
    }
    resp = requests.post(url, headers=headers(), json=payload)
    resp.raise_for_status()
    return resp.json()["data"]["id"]


def delete_existing_screenshots(screenshot_set_id):
    """Delete all existing screenshots in a set."""
    url = f"{BASE_URL}/appScreenshotSets/{screenshot_set_id}/appScreenshots"
    resp = requests.get(url, headers=headers())
    resp.raise_for_status()

    screenshots = resp.json()["data"]
    for ss in screenshots:
        del_url = f"{BASE_URL}/appScreenshots/{ss['id']}"
        del_resp = requests.delete(del_url, headers=headers())
        if del_resp.status_code in (200, 204):
            pass  # success
        else:
            print(f"    Warning: Could not delete screenshot {ss['id']}: {del_resp.status_code}")

    return len(screenshots)


def reserve_screenshot(screenshot_set_id, file_name, file_size):
    """Reserve a screenshot upload slot."""
    url = f"{BASE_URL}/appScreenshots"
    payload = {
        "data": {
            "type": "appScreenshots",
            "attributes": {
                "fileName": file_name,
                "fileSize": file_size,
            },
            "relationships": {
                "appScreenshotSet": {
                    "data": {
                        "type": "appScreenshotSets",
                        "id": screenshot_set_id,
                    }
                }
            },
        }
    }
    resp = requests.post(url, headers=headers(), json=payload)
    resp.raise_for_status()
    return resp.json()["data"]


def upload_screenshot_part(upload_op, file_data):
    """Upload a single part of a screenshot."""
    upload_url = upload_op["url"]
    offset = upload_op["offset"]
    length = upload_op["length"]
    method = upload_op["method"]
    request_headers = {h["name"]: h["value"] for h in upload_op["requestHeaders"]}

    chunk = file_data[offset:offset + length]

    resp = requests.put(upload_url, headers=request_headers, data=chunk)
    resp.raise_for_status()


def commit_screenshot(screenshot_id, checksum):
    """Commit the uploaded screenshot."""
    url = f"{BASE_URL}/appScreenshots/{screenshot_id}"
    payload = {
        "data": {
            "type": "appScreenshots",
            "id": screenshot_id,
            "attributes": {
                "uploaded": True,
                "sourceFileChecksum": checksum,
            },
        }
    }
    resp = requests.patch(url, headers=headers(), json=payload)
    resp.raise_for_status()
    return resp.json()


def upload_single_screenshot(screenshot_set_id, file_path):
    """Upload a single screenshot file to a screenshot set."""
    file_name = os.path.basename(file_path)
    file_size = os.path.getsize(file_path)

    with open(file_path, "rb") as f:
        file_data = f.read()

    # Calculate MD5 checksum
    checksum = hashlib.md5(file_data).hexdigest()

    # 1. Reserve
    reservation = reserve_screenshot(screenshot_set_id, file_name, file_size)
    screenshot_id = reservation["id"]
    upload_operations = reservation["attributes"]["uploadOperations"]

    # 2. Upload parts
    for op in upload_operations:
        upload_screenshot_part(op, file_data)

    # 3. Commit
    commit_screenshot(screenshot_id, checksum)

    return screenshot_id


def main():
    print("=" * 60)
    print("MathPro - Screenshot Uploader to App Store Connect")
    print(f"  Locales: {len(ASC_LOCALES)}")
    print(f"  Screenshots per locale: {len(SCREENSHOT_FILES)}")
    print(f"  Display type: {DISPLAY_TYPE}")
    print("=" * 60)

    # Step 1: Get all version localizations
    print("\n📋 Fetching version localizations...")
    localizations = get_version_localizations()
    print(f"   Found {len(localizations)} localizations")

    success_count = 0
    error_count = 0
    skip_count = 0

    for folder_name, asc_locale in sorted(ASC_LOCALES.items()):
        loc_id = localizations.get(asc_locale)
        if not loc_id:
            print(f"\n  [{asc_locale}] ⚠️  No localization found, skipping")
            skip_count += 1
            continue

        locale_dir = os.path.join(SCREENSHOTS_DIR, folder_name)
        if not os.path.isdir(locale_dir):
            print(f"\n  [{asc_locale}] ⚠️  No screenshots folder: {folder_name}")
            skip_count += 1
            continue

        print(f"\n  [{asc_locale}]", end="", flush=True)

        try:
            # Get or create screenshot set
            sets = get_screenshot_sets(loc_id)
            if DISPLAY_TYPE in sets:
                set_id = sets[DISPLAY_TYPE]
                # Delete existing screenshots
                deleted = delete_existing_screenshots(set_id)
                if deleted > 0:
                    print(f" (cleared {deleted})", end="", flush=True)
                    time.sleep(1)  # Brief pause after deletion
            else:
                set_id = create_screenshot_set(loc_id, DISPLAY_TYPE)
                print(f" (new set)", end="", flush=True)

            # Upload each screenshot
            for idx, ss_file in enumerate(SCREENSHOT_FILES):
                file_path = os.path.join(locale_dir, ss_file)
                if not os.path.exists(file_path):
                    print(f" ✗{idx+1}", end="", flush=True)
                    error_count += 1
                    continue

                try:
                    upload_single_screenshot(set_id, file_path)
                    success_count += 1
                    print(f" ✓{idx+1}", end="", flush=True)
                except Exception as e:
                    print(f" ✗{idx+1}({str(e)[:50]})", end="", flush=True)
                    error_count += 1

                time.sleep(0.5)  # Rate limiting

        except Exception as e:
            print(f" ERROR: {str(e)[:80]}", end="", flush=True)
            error_count += 5

    print(f"\n\n{'=' * 60}")
    print(f"DONE! ✓ {success_count} uploaded, ✗ {error_count} errors, ⚠️  {skip_count} skipped")
    print(f"{'=' * 60}")


if __name__ == "__main__":
    main()
