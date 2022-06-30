# Maintainer: Joel Robert Justiawan <JOELwindows7@proton.me>
pkgname='lastfunkinmoments-git' # '-bzr', '-git', '-hg' or '-svn'
pkgver=2022.07.0
pkgrel=1
# longdesc = "Last Funkin Moments. Enjoy til the last drop of funkin. A fork of Kade Engine by Kade which itself is a fork of Friday Night Funkin' by Cameron Taylor (ninjamuffin)"
pkgdesc="A mod of FNF freshly forked from Kade Engine"
arch=('x86_64')
url="https://github.com/Perkedel/Kaded-fnf-mods"
license=('GPL3')
depends=(
    'vlc'
)
# optdepends=(
#     'vlc'
# )
makedepends=(
    'git'
    'haxe'
)

source=("$pkgname")
noextract=()
md5sums=('SKIP')
# changelog=

pkgver() {
    cd ..

# Comprehensive Git pls
# https://wiki.archlinux.org/title/VCS_package_guidelines#The_pkgver()_function
    (   
        set -o pipefail
        git describe --long 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' ||
        printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
    )
}

prepare() {
    cd ..
    pwd
    ls
    # cd "$pkgname"
    arch-btw/prepare-haxe.sh

    # API placeholder pls
    wget https://gist.github.com/JOELwindows7/ba79db473ab5e4765293fb19c62240cb/raw/d5fc74359ec9ae272003c5d715d04b4dbbd7810d/GJkeys.hx
    mv -n ./GJkeys.hx "source/GJKeys.hx"
}

build() {
    cd ..

    arch-btw/build-now.sh
}

check() {
    cd ..

    arch-btw/btw-check.sh
}

package() {
    cd ..

    install -Dm755 -d ./export/release/linux/bin "$pkgdir/usr/bin/LastFunkinMoments"
    install -Dm644 ./README.md "$pkgdir/usr/share/doc/$pkgname"
    install -Dm644 ./LICENSE "$pkgdir/user/share/licenses/$pkgname/LICENSE"
}
