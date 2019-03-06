#!/bin/bash
# Pre install
dpkg --add-architecture i386
apt update
apt install -y aptitude wget file bzip2

# Get Wine
wget -nv -c https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-staging_4.3~bionic_i386.deb
wget -nv -c https://dl.winehq.org/wine-builds/ubuntu/dists/bionic/main/binary-i386/wine-staging-i386_4.3~bionic_i386.deb

dpkg -x wine-staging_4.3~bionic_i386.deb wineversion/
dpkg -x wine-staging-i386_4.3~bionic_i386.deb wineversion/

cp -r "wineversion/opt/"* "wineversion"
rm -r "wineversion/opt"
rm -rf "wineversion/usr"

wineworkdir=(wineversion/*)
cd $wineworkdir

# Add a dependency library, such as freetype font library
mkdir bin
wget -nv -c https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/libhookexecv.so -O bin/libhookexecv.so
wget -nv -c https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/wine-preloader_hook -O bin/wine-preloader_hook

chmod +x bin/wine-preloader_hook

pkgcachedir='/tmp/.winedeploycache'
mkdir -p $pkgcachedir

aptitude -y -d -o dir::cache::archives="$pkgcachedir" install libwine:i386 winetricks

find $pkgcachedir -name '*deb' ! -name 'libwine*' -exec dpkg -x {} . \;

rm -rf $pkgcachedir

# appimage
cd -

wget -nv -c "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage" -O  appimagetool.AppImage
chmod +x appimagetool.AppImage

chmod +x AppRun

cp AppRun $wineworkdir
cp resource/* $wineworkdir

./appimagetool.AppImage --appimage-extract

export ARCH=x86_64; squashfs-root/AppRun $wineworkdir