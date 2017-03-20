# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils

DESCRIPTION="A fork of OpenSSL designed for Google's needs."

HOMEPAGE="https://boringssl.googlesource.com/boringssl/"
KEYWORDS="~amd64 ~x86"
IUSE="+asm static-libs"
COMMIT_ID="73812e06b0921b5c81d4a6c2bb21ff705afa414f"
SRC_URI="https://boringssl.googlesource.com/boringssl/+archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC openssl"
SLOT="0/20170320"

RDEPEND="
	!dev-libs/openssl
	!dev-libs/libressl
	dev-lang/go
	dev-lang/perl"

DEPEND="${RDEPEND}"
PDEPEND="app-misc/ca-certificates"

src_unpack() {
	mkdir "${WORKDIR}/${P}" || die
	cd "${WORKDIR}/${P}" || die
	unpack "${A}"
}

src_prepare() {
	sed -i \
		-e 's/-Werror //' \
		-e 's/-ggdb //' CMakeLists.txt || die
	cmake-utils_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=1
		-DOPENSSL_NO_ASM=$(usex asm 0 1)
		)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile
	sed -e 's/@VERSION@/'"${PV}"'/' "${FILESDIR}"/libssl.pc > libssl.pc || die
	sed -e 's/@VERSION@/'"${PV}"'/' "${FILESDIR}"/libcrypto.pc > libcrypto.pc || die
	sed -e 's/@VERSION@/'"${PV}"'/' "${FILESDIR}"/libdecrepit.pc > libdecrepit.pc || die
}

src_install() {
	# No official install phase, so let's hack one in.
	dolib.so "${CMAKE_BUILD_DIR}"/crypto/libcrypto.so
	dolib.so "${CMAKE_BUILD_DIR}"/decrepit/libdecrepit.so
	dolib.so "${CMAKE_BUILD_DIR}"/ssl/libssl.so
	dobin "${CMAKE_BUILD_DIR}"/tool/bssl

	insinto /usr/$(get_libdir)/pkgconfig
	doins libssl.pc
	doins libcrypto.pc
	doins libdecrepit.pc

	doheader -r include/openssl

	dodoc -r *.md
}
