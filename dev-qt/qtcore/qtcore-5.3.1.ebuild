# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

QT5_MODULE="qtbase"

inherit qt5-build

DESCRIPTION="Cross-platform application development framework"

if [[ ${QT5_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~x86"
fi

IUSE="+glib icu"

DEPEND="
	>=dev-libs/libpcre-8.30[pcre16]
	sys-libs/zlib
	virtual/libiconv
	glib? ( dev-libs/glib:2 )
	icu? ( dev-libs/icu:= )
"
RDEPEND="${DEPEND}"

QT5_TARGET_SUBDIRS=(
	src/tools/bootstrap
	src/tools/moc
	src/tools/rcc
	src/corelib
)

QT5_GENTOO_CONFIG=(
	::ZLIB
)

src_configure() {
	local myconf=(
		$(qt_use glib)
		$(qt_use icu)
	)
	qt5-build_src_configure
}