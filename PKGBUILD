# Maintainer: Joel Robert Justiawan <JOELwindows7@proton.me>
pkgname='lastfunkinmoments-git' # '-bzr', '-git', '-hg' or '-svn'
pkgver=r3085.ac81879
pkgrel=1
# longdesc = "Last Funkin Moments. Enjoy til the last drop of funkin. A fork of Kade Engine by Kade which itself is a fork of Friday Night Funkin' by Cameron Taylor (ninjamuffin)"
pkgdesc="A mod of FNF freshly forked from Kade Engine"
arch=('x86_64')
url="https://github.com/Perkedel/Kaded-fnf-mods"
license=('GPL3')
# groups=()
depends=(
    'vlc'
)
makedepends=(
    'git'
    'haxe'
) # 'bzr', 'git', 'mercurial' or 'subversion'
# provides=("${pkgname%-VCS}")
# conflicts=("${pkgname%-VCS}")
# replaces=()
# backup=()
# options=()
# install=
source=("$pkgname")
noextract=()
md5sums=('SKIP')

# Please refer to the 'USING VCS SOURCES' section of the PKGBUILD man page for
# a description of each element in the source array.

pkgver() {
	# cd "$srcdir/${pkgname%-VCS}"
    # cd "$pgkname"

# The examples below are not absolute and need to be adapted to each repo. The
# primary goal is to generate version numbers that will increase according to
# pacman's version comparisons with later commits to the repo. The format
# VERSION='VER_NUM.rREV_NUM.HASH', or a relevant subset in case VER_NUM or HASH
# are not available, is recommended.

# Bazaar
	# printf "r%s" "$(bzr revno)"

# Git, tags available
	# printf "%s" "$(git describe --long | sed 's/\([^-]*-\)g/r\1/;s/-/./g')"

# Git, no tags available
	# printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"

# Comprehensive Git pls
# https://wiki.archlinux.org/title/VCS_package_guidelines#The_pkgver()_function
    (   
        set -o pipefail
        git describe --long 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' ||
        printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
    )

# Mercurial
	# printf "r%s.%s" "$(hg identify -n)" "$(hg identify -i)"

# Subversion
	# printf "r%s" "$(svnversion | tr -d 'A-z')"
}

prepare() {
    cd ..
    pwd
    ls
    # cd "$pkgname"
    arch-btw/prepare-haxe.sh

	# cd "$srcdir/${pkgname%-VCS}"
	# patch -p1 -i "$srcdir/${pkgname%-VCS}.patch"

    # API placeholder pls
    wget https://gist.github.com/JOELwindows7/ba79db473ab5e4765293fb19c62240cb/raw/d5fc74359ec9ae272003c5d715d04b4dbbd7810d/GJkeys.hx
    mv -n ./GJkeys.hx "source/GJkeys.hx"
}

build() {
    cd ..
	# cd "$srcdir/${pkgname%-VCS}"
    # cd "$pkgname"
	# ./autogen.sh
	# ./configure --prefix=/usr
	# make
    arch-btw/build-now.sh
}

check() {
    cd ..
    # cd "$pkgname"
	# cd "$srcdir/${pkgname%-VCS}"
	# make -k check
    arch-btw/btw-check.sh
}

package() {
    cd ..
    # cd "$pkgname"
	# cd "$srcdir/${pkgname%-VCS}"
	# make DESTDIR="$pkgdir/" install
    install -Dm755 -d ./export/release/linux/bin "$pkgdir/usr/bin/LastFunkinMoments"
    install -Dm644 ./README.md "$pkgdir/usr/share/doc/$pkgname"
    install -Dm644 ./LICENSE "$pkgdir/user/share/licenses/$pkgname/LICENSE"
}
