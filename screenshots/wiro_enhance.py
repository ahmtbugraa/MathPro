#!/usr/bin/env python3
"""
Wiro AI - Nano Banana Pro Enhancement Script
Sends scaffold images to Nano Banana Pro for professional App Store screenshot enhancement.
"""

import hashlib
import hmac
import json
import os
import sys
import time
import requests

API_KEY = "miah2jgsorqee9nlrissq9j7w11dqp2x"
API_SECRET = "3c82a935ba0041a6606189334303099719f93ec7a0d28a0d44a829041f9e0341"
MODEL_SLUG = "google/nano-banana-pro"
API_BASE = "https://api.wiro.ai/v1"


def get_auth_headers():
    """Generate signature-based auth headers."""
    nonce = str(int(time.time()))
    message = API_SECRET + nonce
    signature = hmac.new(
        API_KEY.encode("utf-8"),
        message.encode("utf-8"),
        hashlib.sha256
    ).hexdigest()
    return {
        "x-api-key": API_KEY,
        "x-nonce": nonce,
        "x-signature": signature,
    }


def submit_job(prompt, image_paths, aspect_ratio="9:16", resolution="4K"):
    """Submit an image generation/editing job to Nano Banana Pro."""
    url = f"{API_BASE}/Run/{MODEL_SLUG}"
    headers = get_auth_headers()

    files = []
    file_handles = []
    for img_path in image_paths:
        fh = open(img_path, "rb")
        file_handles.append(fh)
        files.append(("inputImage", (os.path.basename(img_path), fh, "image/png")))

    data = {
        "prompt": prompt,
        "aspectRatio": aspect_ratio,
        "resolution": resolution,
        "safetySetting": "OFF",
    }

    resp = requests.post(url, headers=headers, data=data, files=files)

    for fh in file_handles:
        fh.close()

    if resp.status_code != 200:
        print(f"Error {resp.status_code}: {resp.text}", file=sys.stderr)
        return None

    result = resp.json()
    return result.get("taskid")


def poll_result(task_id, max_wait=180, interval=5):
    """Poll for task completion and return output URL."""
    url = f"{API_BASE}/Task/Detail"

    start = time.time()
    while time.time() - start < max_wait:
        headers = get_auth_headers()
        resp = requests.post(url, headers=headers, json={"taskid": task_id})

        if resp.status_code != 200:
            time.sleep(interval)
            continue

        data = resp.json()
        tasklist = data.get("tasklist", [])
        if not tasklist:
            time.sleep(interval)
            continue

        task = tasklist[0]
        status = task.get("status", "")
        outputs = task.get("outputs", [])

        # Outputs only appear after task_postprocess_end
        if status == "task_postprocess_end" and outputs:
            return outputs[0].get("url")

        if status in ("failed", "error", "cancelled", "task_failed"):
            print(f"Task {status}", file=sys.stderr)
            return None

        elapsed = int(time.time() - start)
        print(f"  [{task_id}] {elapsed}s... ({status})")
        time.sleep(interval)

    print(f"Timeout after {max_wait}s", file=sys.stderr)
    return None


def download(url, save_path):
    """Download file from URL."""
    resp = requests.get(url)
    if resp.status_code == 200:
        with open(save_path, "wb") as f:
            f.write(resp.content)
        return True
    return False


def enhance(scaffold_path, prompt, output_path, extra_images=None):
    """Full pipeline: submit, poll, download."""
    image_paths = [scaffold_path]
    if extra_images:
        image_paths.extend(extra_images)

    task_id = submit_job(prompt, image_paths)
    if not task_id:
        print(f"Failed to submit", file=sys.stderr)
        return False

    print(f"Task {task_id} submitted -> {output_path}")

    output_url = poll_result(task_id)
    if not output_url:
        print(f"No output for task {task_id}", file=sys.stderr)
        return False

    if download(output_url, output_path):
        size_kb = os.path.getsize(output_path) / 1024
        print(f"✓ {output_path} ({size_kb:.0f} KB)")
        return True
    return False


if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 wiro_enhance.py <scaffold> <output> <prompt> [extra_image1] [extra_image2]")
        sys.exit(1)

    scaffold = sys.argv[1]
    output = sys.argv[2]
    prompt = sys.argv[3]
    extras = sys.argv[4:] if len(sys.argv) > 4 else None

    success = enhance(scaffold, prompt, output, extras)
    sys.exit(0 if success else 1)
