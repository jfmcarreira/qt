# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit qt4-build-multilib

DESCRIPTION="The WebKit module for the Qt toolkit"

if [[ ${QT4_BUILD_TYPE} == live ]]; then
	KEYWORDS=""
else
	KEYWORDS="~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
fi

IUSE="+gstreamer icu +jit"

# libxml2[!icu?] is needed for bugs 407315 and 411091
DEPEND="
	dev-db/sqlite:3[${MULTILIB_USEDEP}]
	~dev-qt/qtcore-${PV}[aqua=,debug=,ssl,${MULTILIB_USEDEP}]
	~dev-qt/qtgui-${PV}[aqua=,debug=,${MULTILIB_USEDEP}]
	~dev-qt/qtxmlpatterns-${PV}[aqua=,debug=,${MULTILIB_USEDEP}]
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	gstreamer? (
		dev-libs/glib:2[${MULTILIB_USEDEP}]
		dev-libs/libxml2:2[!icu?,${MULTILIB_USEDEP}]
		>=media-libs/gstreamer-0.10.36:0.10[${MULTILIB_USEDEP}]
		>=media-libs/gst-plugins-base-0.10.36:0.10[${MULTILIB_USEDEP}]
	)
	icu? ( dev-libs/icu:=[${MULTILIB_USEDEP}] )
"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}/${PN}-4.8.1-no-use-ld-gold.patch"
	"${FILESDIR}/4.8.2-javascriptcore-x32.patch"
)

QT4_TARGET_DIRECTORIES="
	src/3rdparty/webkit/Source/JavaScriptCore
	src/3rdparty/webkit/Source/WebCore
	src/3rdparty/webkit/Source/WebKit/qt"

QCONFIG_ADD="webkit"
QCONFIG_DEFINE="QT_WEBKIT"

src_prepare() {
	# Fix version number in generated pkgconfig file, bug 406443
	sed -i -e 's/^isEmpty(QT_BUILD_TREE)://' \
		src/3rdparty/webkit/Source/WebKit/qt/QtWebKit.pro || die

	# Remove -Werror from CXXFLAGS
	sed -i -e '/QMAKE_CXXFLAGS\s*+=/ s:-Werror::g' \
		src/3rdparty/webkit/Source/WebKit.pri || die

	if use icu; then
		sed -i -e '/CONFIG\s*+=\s*text_breaking_with_icu/ s:^#\s*::' \
			src/3rdparty/webkit/Source/JavaScriptCore/JavaScriptCore.pri || die
	fi

	qt4-build-multilib_src_prepare
}

src_configure() {
	myconf+="
		-webkit
		-system-sqlite
		$(qt_use icu)
		$(qt_use jit javascript-jit)
		$(use gstreamer || echo -DENABLE_VIDEO=0)"

	qt4-build-multilib_src_configure
}
