#!/usr/bin/env python3
"""
App Store Connect API - Bulk Metadata Uploader
Uploads title, subtitle, and keywords for all localizations.
"""

import json
import os
import sys
import time
import jwt
import requests

# ── Configuration ──────────────────────────────────────────────────
KEY_ID = "F45A64X9CT"
ISSUER_ID = "aa8b074b-c562-463d-86e6-30dd31eb8ef8"
P8_PATH = "/Users/abk/Downloads/AuthKey_F45A64X9CT.p8"
BUNDLE_ID = "com.ahmetbugrakacdi.MathPro"
BASE_URL = "https://api.appstoreconnect.apple.com/v1"

METADATA_DIR = os.path.join(os.path.dirname(__file__), "metadata")

# Fastlane locale → App Store Connect locale mapping
LOCALE_MAP = {
    "en-US": "en-US",
    "en-GB": "en-GB",
    "en-AU": "en-AU",
    "en-CA": "en-CA",
    "fr-FR": "fr-FR",
    "fr-CA": "fr-CA",
    "de-DE": "de-DE",
    "es-ES": "es-ES",
    "es-MX": "es-MX",
    "pt-BR": "pt-BR",
    "pt-PT": "pt-PT",
    "it": "it",
    "nl-NL": "nl-NL",
    "ja": "ja",
    "ko": "ko",
    "zh-Hans": "zh-Hans",
    "zh-Hant": "zh-Hant",
    "ar-SA": "ar-SA",
    "tr": "tr",
    "ru": "ru",
    "hi": "hi",
    "he": "he",
    "hr": "hr",
    "cs": "cs",
    "da": "da",
    "fi": "fi",
    "el": "el",
    "hu": "hu",
    "id": "id",
    "ms": "ms",
    "no": "no",
    "pl": "pl",
    "ro": "ro",
    "sk": "sk",
    "sv": "sv",
    "th": "th",
    "uk": "uk",
    "vi": "vi",
    "ca": "ca",
}


def generate_token():
    """Generate JWT token for App Store Connect API."""
    with open(P8_PATH, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": ISSUER_ID,
        "iat": now,
        "exp": now + 1200,  # 20 min
        "aud": "appstoreconnect-v1",
    }
    headers = {
        "alg": "ES256",
        "kid": KEY_ID,
        "typ": "JWT",
    }
    token = jwt.encode(payload, private_key, algorithm="ES256", headers=headers)
    return token


def api_get(path, token, params=None):
    """GET request to App Store Connect API."""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    resp = requests.get(f"{BASE_URL}{path}", headers=headers, params=params)
    if resp.status_code != 200:
        print(f"  GET {path} → {resp.status_code}: {resp.text[:200]}")
        return None
    return resp.json()


def api_post(path, token, data):
    """POST request to App Store Connect API."""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    resp = requests.post(f"{BASE_URL}{path}", headers=headers, json=data)
    if resp.status_code not in (200, 201):
        print(f"  POST {path} → {resp.status_code}: {resp.text[:300]}")
        return None
    return resp.json()


def api_patch(path, token, data):
    """PATCH request to App Store Connect API."""
    headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    resp = requests.patch(f"{BASE_URL}{path}", headers=headers, json=data)
    if resp.status_code != 200:
        print(f"  PATCH {path} → {resp.status_code}: {resp.text[:300]}")
        return None
    return resp.json()


def read_file(path):
    """Read a text file, strip whitespace."""
    if not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        return f.read().strip()


def main():
    print("=" * 60)
    print("MathPro - App Store Connect Metadata Uploader")
    print("=" * 60)

    # ── 1. Generate token ──────────────────────────────────────
    print("\n[1/6] Generating API token...")
    token = generate_token()
    print("  ✓ Token generated")

    # ── 2. Find the app ────────────────────────────────────────
    print("\n[2/6] Finding app by bundle ID...")
    data = api_get("/apps", token, {"filter[bundleId]": BUNDLE_ID})
    if not data or not data.get("data"):
        print(f"  ✗ App not found: {BUNDLE_ID}")
        sys.exit(1)

    app_id = data["data"][0]["id"]
    app_name = data["data"][0]["attributes"]["name"]
    print(f"  ✓ Found: {app_name} (ID: {app_id})")

    # ── 3. Get App Info (for title + subtitle) ─────────────────
    print("\n[3/6] Getting App Info...")
    data = api_get(f"/apps/{app_id}/appInfos", token)
    if not data or not data.get("data"):
        print("  ✗ No app infos found")
        sys.exit(1)

    app_info_id = data["data"][0]["id"]
    print(f"  ✓ App Info ID: {app_info_id}")

    # ── 4. Get existing App Info Localizations ─────────────────
    print("\n[4/6] Getting existing localizations...")
    data = api_get(f"/appInfos/{app_info_id}/appInfoLocalizations", token, {"limit": 50})
    existing_info_locales = {}
    if data and data.get("data"):
        for loc in data["data"]:
            locale = loc["attributes"]["locale"]
            existing_info_locales[locale] = loc["id"]
    print(f"  ✓ Found {len(existing_info_locales)} existing: {', '.join(sorted(existing_info_locales.keys()))}")

    # ── 5. Get App Store Version (for keywords) ────────────────
    print("\n[5/6] Getting latest App Store Version...")
    data = api_get(f"/apps/{app_id}/appStoreVersions", token, {
        "filter[platform]": "IOS",
        "limit": 1,
    })
    if not data or not data.get("data"):
        print("  ✗ No app store versions found. Make sure you have a version in App Store Connect.")
        sys.exit(1)

    version_id = data["data"][0]["id"]
    version_string = data["data"][0]["attributes"]["versionString"]
    print(f"  ✓ Version: {version_string} (ID: {version_id})")

    # Get existing version localizations
    data = api_get(f"/appStoreVersions/{version_id}/appStoreVersionLocalizations", token, {"limit": 50})
    existing_version_locales = {}
    if data and data.get("data"):
        for loc in data["data"]:
            locale = loc["attributes"]["locale"]
            existing_version_locales[locale] = loc["id"]
    print(f"  ✓ Found {len(existing_version_locales)} version localizations")

    # ── 6. Upload metadata for each locale ─────────────────────
    print("\n[6/6] Uploading metadata...")
    print("-" * 60)

    success = 0
    failed = 0

    for fastlane_locale, asc_locale in sorted(LOCALE_MAP.items()):
        locale_dir = os.path.join(METADATA_DIR, fastlane_locale)
        if not os.path.isdir(locale_dir):
            print(f"  ⚠ {asc_locale}: directory not found, skipping")
            failed += 1
            continue

        name = read_file(os.path.join(locale_dir, "name.txt"))
        subtitle = read_file(os.path.join(locale_dir, "subtitle.txt"))
        keywords = read_file(os.path.join(locale_dir, "keywords.txt"))

        print(f"\n  [{asc_locale}]")
        print(f"    Title: {name}")
        print(f"    Subtitle: {subtitle}")
        print(f"    Keywords: {keywords[:50]}...")

        locale_ok = True

        # ── Update/Create App Info Localization (title + subtitle) ──
        if asc_locale in existing_info_locales:
            loc_id = existing_info_locales[asc_locale]
            result = api_patch(f"/appInfoLocalizations/{loc_id}", token, {
                "data": {
                    "type": "appInfoLocalizations",
                    "id": loc_id,
                    "attributes": {
                        "name": name,
                        "subtitle": subtitle,
                    }
                }
            })
            if result:
                print(f"    ✓ Title/Subtitle updated")
            else:
                print(f"    ✗ Title/Subtitle update failed")
                locale_ok = False
        else:
            result = api_post("/appInfoLocalizations", token, {
                "data": {
                    "type": "appInfoLocalizations",
                    "attributes": {
                        "locale": asc_locale,
                        "name": name,
                        "subtitle": subtitle,
                    },
                    "relationships": {
                        "appInfo": {
                            "data": {
                                "type": "appInfos",
                                "id": app_info_id,
                            }
                        }
                    }
                }
            })
            if result:
                print(f"    ✓ Title/Subtitle created")
            else:
                print(f"    ✗ Title/Subtitle creation failed")
                locale_ok = False

        # ── Update/Create Version Localization (keywords) ──
        if asc_locale in existing_version_locales:
            loc_id = existing_version_locales[asc_locale]
            result = api_patch(f"/appStoreVersionLocalizations/{loc_id}", token, {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "id": loc_id,
                    "attributes": {
                        "keywords": keywords,
                    }
                }
            })
            if result:
                print(f"    ✓ Keywords updated")
            else:
                print(f"    ✗ Keywords update failed")
                locale_ok = False
        else:
            result = api_post("/appStoreVersionLocalizations", token, {
                "data": {
                    "type": "appStoreVersionLocalizations",
                    "attributes": {
                        "locale": asc_locale,
                        "keywords": keywords,
                    },
                    "relationships": {
                        "appStoreVersion": {
                            "data": {
                                "type": "appStoreVersions",
                                "id": version_id,
                            }
                        }
                    }
                }
            })
            if result:
                print(f"    ✓ Keywords created")
            else:
                print(f"    ✗ Keywords creation failed")
                locale_ok = False

        if locale_ok:
            success += 1
        else:
            failed += 1

        # Small delay to avoid rate limiting
        time.sleep(0.3)

    # ── Summary ────────────────────────────────────────────────
    print("\n" + "=" * 60)
    print(f"DONE! ✓ {success} succeeded, ✗ {failed} failed (out of {len(LOCALE_MAP)} locales)")
    print("=" * 60)


if __name__ == "__main__":
    main()
