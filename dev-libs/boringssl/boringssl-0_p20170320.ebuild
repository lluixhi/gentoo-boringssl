# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-multilib multilib

DESCRIPTION="A fork of OpenSSL designed for Google's needs."
HOMEPAGE="https://boringssl.googlesource.com/boringssl/"

COMMIT_ID="73812e06b0921b5c81d4a6c2bb21ff705afa414f"
SRC_URI="https://github.com/google/boringssl/archive/${COMMIT_ID}.tar.gz -> ${P}.tar.gz"

LICENSE="ISC openssl"
SLOT="0/${PV}"
KEYWORDS="~amd64"
IUSE="+asm static-libs"

RDEPEND="
	!dev-libs/openssl
	!dev-libs/libressl
	dev-lang/go
	dev-lang/perl"
DEPEND="${RDEPEND}"
PDEPEND="app-misc/ca-certificates"

S="${WORKDIR}/${PN}-${COMMIT_ID}"
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
	cmake-multilib_src_configure
}

multilib_src_compile() {
	cmake-utils_src_compile
	sed \
		-e 's/@VERSION@/'"${PV}"'/' \
		-e 's/@LIBDIR@/'"$(get_abi_LIBDIR)"'/' \
		"${FILESDIR}"/libcrypto.pc > libcrypto.pc || die
	sed \
		-e 's/@VERSION@/'"${PV}"'/' \
		-e 's/@LIBDIR@/'"$(get_abi_LIBDIR)"'/' \
		"${FILESDIR}"/libssl.pc > libssl.pc || die
	sed \
		-e 's/@VERSION@/'"${PV}"'/' \
		-e 's/@LIBDIR@/'"$(get_abi_LIBDIR)"'/' \
		"${FILESDIR}"/libdecrepit.pc > libdecrepit.pc || die
}

multilib_src_install() {
	# No official install phase, so let's hack one in.
	dolib.so "${BUILD_DIR}"/crypto/libcrypto.so
	dolib.so "${BUILD_DIR}"/decrepit/libdecrepit.so
	dolib.so "${BUILD_DIR}"/ssl/libssl.so
	$([ "${ABI}" = "${DEFAULT_ABI}" ]) && dobin "${BUILD_DIR}"/tool/bssl

	insinto /usr/$(get_abi_LIBDIR)/pkgconfig
	doins libssl.pc
	doins libcrypto.pc
	doins libdecrepit.pc
}

multilib_src_install_all() {
	doheader -r include/openssl
	dodoc *.md
}
