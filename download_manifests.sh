if ! [ -d .repo/local_manifests/ ]; then
      curl --create-dirs -L -o .repo/local_manifests/msm7x27a_manifest.xml -O -L https://raw.github.com/FloppyTeam/manifests/cm-11.0/msm7x27a_manifest.xml
fi

if ! [ -d .repo/manifests/ ]; then
      repo init -u git://github.com/CyanogenMod/android.git -b cm-11.0 -g all,-notdefault,-darwin
fi
