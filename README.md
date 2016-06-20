Manifest for Android KitKat / CyanogenMod 11.0
====================================
Project M4|L5 / Project U0|L7

---

Automatic Way:

script to download manifests, sync repo and build:

    curl --create-dirs -L -o build.sh -O -L https://raw.github.com/FloppyTeam/local_manifest/cm-11.0/repo_sync.sh

To use:

    . repo_sync.sh

---

Manual Way:

To initialize CyanogenMod 11.0 Repo:

    repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0 -g all,-notdefault,-darwin

---

To initialize Manifest for L5 and L7 devices:

    curl --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/FloppyTeam/local_manifest/cm-11.0/msm7x27a_manifest.xml

---

Sync the repo:

    repo sync

---

Initialize the environment:

    . build/envsetup.sh

---

Make sure to apply pathces in device/lge/msm7x27a-common/patches
Open terminal in that folder and run
    
    . apply.sh

---

To build for L5:

    brunch e610

---

To build for L7:

    brunch p700
