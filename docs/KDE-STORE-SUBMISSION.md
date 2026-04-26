# KDE Store Submission Guide

Step-by-step guide for submitting and updating K-Ollama on the KDE Store (store.kde.org). See [kde-store-upload-materials.md](kde-store-upload-materials.md) for ready-to-paste text content (description, changelog, etc.).

## Table of Contents

- [Prerequisites](#prerequisites)
- [First-Time Submission](#first-time-submission)
  - [1. Create an Account](#1-create-an-account)
  - [2. Prepare Assets](#2-prepare-assets)
  - [3. Create the Product](#3-create-the-product)
  - [4. Fill In Product Details](#4-fill-in-product-details)
  - [5. Upload the Package File](#5-upload-the-package-file)
  - [6. Publish](#6-publish)
- [Verifying the Submission](#verifying-the-submission)
- [Updating an Existing Product](#updating-an-existing-product)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

Before starting, confirm these are ready:

- [ ] **Account** at store.kde.org (see step 1)
- [ ] **Package built** — run `./scripts/package-up.sh` from the project root; the output file is `K-Ollama-1.1.0.plasmoid` in the **parent** directory of the project
- [ ] **Package verified** — confirm it installs locally:
  ```bash
  kpackagetool6 --type Plasma/Applet --install ../K-Ollama-1.1.0.plasmoid
  ```
  Then add the widget to your panel to confirm it loads correctly. Uninstall after:
  ```bash
  kpackagetool6 --type Plasma/Applet --remove io.github.chevybowtie.k-ollama
  ```
- [ ] **Screenshots** — at least one PNG/JPG showing the widget in use. See [Prepare Assets](#2-prepare-assets) for what works well.

---

## First-Time Submission

### 1. Create an Account

Go to **https://store.kde.org** and click **Sign In / Register**. The KDE Store uses the OpenDesktop / pling.com platform. Your account works across store.kde.org, opendesktop.org, and pling.com — they share the same login.

After registering, confirm your email address before trying to submit.

### 2. Prepare Assets

**Screenshots** are the most important asset for discoverability. The store shows them as thumbnails in search results.

Recommended set:
1. **Main chat view** — widget open with a real conversation, model selected, showing the chat bubbles
2. **Markdown rendering** — a response with code blocks, so the code copy buttons and formatting are visible
3. **Settings dialog** — the three-tab config (Server, Appearance, Behavior)
4. **Panel/compact view** — the widget icon in the panel, showing how it looks when collapsed

Tips:
- **Minimum 1024 px wide** — smaller images look blurry in the store grid
- Use a neutral or slightly dark desktop theme so the widget stands out
- PNG preferred; JPG is fine for photo-like screenshots
- Avoid superimposing text labels — the store lets you add captions separately

Existing assets: `docs/screen-shots/ready.png`, `docs/screen-shots/demo.mp4`. The store accepts video (mp4) for the preview slot, which is useful for showing streaming responses.

**Description text** — copy from [kde-store-upload-materials.md](kde-store-upload-materials.md). Update the long description for v1.1 to include the new features (per-code-block copy, response timeout, error banners, 11 languages).

### 3. Create the Product

1. Log in at **https://store.kde.org**
2. Click your username (top right) → **My Products**
3. Click **Add Product**

You will see a product creation form. Work through each section below.

### 4. Fill In Product Details

#### Identity

| Field | Value |
|---|---|
| **Name** | `K-Ollama` |
| **Version** | `1.1.0` — must match `metadata.json` exactly |
| **License** | `LGPL-2.1-or-later` |
| **Homepage** | `https://github.com/chevybowtie/K-Ollama-Plasmoid` |

#### Category

This is the field that determines whether the widget appears in Plasma's **Get New Widgets** dialog. Getting it wrong means users can find it on the website but cannot install it from within Plasma.

Select:
- **Category**: `Plasma Addons`
- **Sub-category**: `Applets` (sometimes listed as `Plasma 6 Applets` or `Plasma Widgets`)

> **Why this matters:** The "Get New Widgets → Download New Plasma Widgets" feature in Plasma queries the store for products in the Plasma Applets category using the OCS (Open Collaboration Services) API. Products in the wrong category are not returned by this query even if they appear on the website.

If you are unsure which sub-category to pick, search the store for a well-known Plasma widget (e.g. "Event Calendar") and note which category it is listed under — use the same one.

#### Tags

Add tags to improve discoverability:
```
ollama, ai, chat, llm, plasma6, plasmoid, local-ai, chatbot, machine-learning
```

#### Short Description

```
Chat with local or remote Ollama AI models from your KDE panel
```

#### Long Description

Use the text from [kde-store-upload-materials.md](kde-store-upload-materials.md). Update it with v1.1 features. The description field accepts basic HTML on the store — `<b>`, `<ul>`, `<li>` etc. are rendered.

#### Changelog

Add a changelog entry for the version being uploaded. This is shown on the product page and in Plasma's update notifications.

```
v1.1.0
- Per-code-block copy buttons with visual feedback
- Configurable response timeout (Settings → Behavior)
- Separate Appearance and Behavior config tabs
- Inline error banners for network/timeout failures
- 10 new translations: German, French, Italian, Portuguese (BR), Russian, Chinese (Simplified), Japanese, Korean, Arabic, and updated Spanish
- Fixed history trim sync between UI list and prompt array
- Fixed message delete index alignment after trim
- Reduced UI jank when toggling markdown rendering
```

### 5. Upload the Package File

After saving the product details, navigate to the **Files** tab of your product.

1. Click **Add File**
2. Upload `K-Ollama-1.1.0.plasmoid` (from the parent directory of the project)
3. Set the **Version** field to `1.1.0`
4. Set the **Install Type** to **OCS-Install** (sometimes labelled "Plasma Widget", "KPackage", or simply "Install")

> **The Install Type field is critical.** If it is left as "Download" or "Link", users can download the file but the one-click install from "Get New Widgets" will not work. It must be set to a type that triggers `kpackagetool6` on install.

5. Save the file entry.

### 6. Publish

On the product overview page, confirm the status is set to **Active** (not Draft). Some store versions have a separate "Publish" button; others go live immediately on save.

Once published, the product page is immediately visible at `https://store.kde.org/p/{your-product-id}/`.

---

## Verifying the Submission

### On the website

Open the product URL in a browser (not logged in) and confirm:
- The name, description, and screenshots look correct
- A "Download" or "Install" button is visible
- The category is correct

### From within Plasma

1. Right-click your KDE panel → **Add Widgets**
2. Click **Get New Widgets** → **Download New Plasma Widgets**
3. Search for `K-Ollama`
4. Click **Install**

If the widget does not appear in the search after ~30 minutes, check:
- The product category (most common cause)
- The file's Install Type setting
- That the product status is Active, not Draft

### Manual OCS install test

You can test the OCS install link without waiting for search indexing:

```bash
# From the product page, copy the OCS install URL (shown near the Download button)
# It looks like: ocs://install?url=https://...&type=plasma_plasmoid
# Pass it directly to plasma-discover:
plasma-discover --install-plasma-widget 'ocs://install?url=...'
```

---

## Updating an Existing Product

When releasing a new version (e.g. bumping from 1.1.0 to 1.2.0):

1. **Bump the version** in `metadata.json`
2. **Rebuild the package**: `./scripts/package-up.sh`
3. **Test the package locally** (install → verify → uninstall as in Prerequisites)
4. **Log in** to store.kde.org → My Products → click the K-Ollama product
5. **Files tab** → Add File → upload the new `.plasmoid`
   - Set the Version field to the new version number
   - Use the same Install Type as before
6. **Do not delete the old file** — users on older Plasma versions may still use it
7. **Update the product description** if features changed
8. **Add a changelog entry** for the new version
9. Save — the new version is live immediately

> **Keep the same product ID.** The product's numeric ID on the store is what Plasma uses to track installed widgets and notify users of updates. Never create a new product for a version bump — always update the existing one.

---

## Troubleshooting

### Widget doesn't appear in "Get New Widgets" search

- **Wait 30–60 minutes** — the OCS search index is cached and not updated instantly
- **Check the category** — it must be in a Plasma Applets sub-category, not a generic "Other" or "Utilities" category
- **Check the file's Install Type** — must be OCS-Install/plasma_plasmoid, not plain Download

### One-click install fails with "unsupported type" or does nothing

The file's Install Type was saved as Download instead of OCS-Install. Edit the file entry on the store, change the type, and re-save.

### Install fails with "already installed" error

A version from a previous `./install.sh dev` run is still registered. Remove it first:
```bash
kpackagetool6 --type Plasma/Applet --remove io.github.chevybowtie.k-ollama
```

### Install succeeds but widget doesn't appear in Add Widgets

The plasmoid ID in `metadata.json` (`io.github.chevybowtie.k-ollama`) is what Plasma uses to index it. If the package installed but the widget isn't visible:
```bash
# Restart Plasma
plasmashell --replace &
```

### Package is rejected or flagged

Common reasons:
- **Missing LICENSE file** — the package must include `LICENSE` at the root
- **Wrong KPackageStructure** — `metadata.json` must declare `"KPackageStructure": "Plasma/Applet"`
- **No `X-Plasma-API-Minimum-Version`** — required for Plasma 6 widgets

Verify the package structure:
```bash
unzip -l ../K-Ollama-1.1.0.plasmoid
```

The `metadata.json` must be at the root of the zip (not inside a subdirectory).

### Version in "Get New Widgets" is stale after an update

Plasma caches the OCS data locally. Force a refresh:
```bash
# Clear the OCS cache
rm -rf ~/.cache/knewstuff3/
```

Then re-open "Get New Widgets".
