Manifest for Android KitKat / CyanogenMod 11.0
====================================
Project M4|L5 / Project U0|L7

---

Repo Init

script to download manifests:

    curl --create-dirs -L -o download_manifests.sh -O -L https://raw.github.com/FloppyTeam/manifests/cm-11.0/download_manifests.sh

How to use it to use it:

    . download_manifests.sh
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
