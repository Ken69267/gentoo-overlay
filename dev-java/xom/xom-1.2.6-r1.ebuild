# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-java/xom/xom-1.0-r7.ebuild,v 1.6 2010/04/24 16:56:04 grobian Exp $

EAPI="2"
JAVA_PKG_IUSE="doc examples source"

inherit java-pkg-2 java-ant-2

DESCRIPTION="A new XML object model."
HOMEPAGE="http://cafeconleche.org/XOM/index.html"
SRC_URI="http://cafeconleche.org/XOM/${P}.tar.gz 
	http://dist.codehaus.org/jaxen/distributions/jaxen-1.1.1-src.tar.gz"
# Bundled jaxen as its moved under XOM's namespace

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ia64 ~ppc ~ppc64 ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris ~x86-solaris"
IUSE=""

COMMON_DEPEND="dev-java/xerces:2
		dev-java/xml-commons-external:1.3
		examples? ( dev-java/servletapi:2.4 )"
RDEPEND=">=virtual/jre-1.4
		${COMMON_DEPEND}"
DEPEND=">=virtual/jdk-1.4
		dev-java/jarjar:1
		${COMMON_DEPEND}"

S="${WORKDIR}/XOM"

# Test require network access to pass
# They need a redirected http document on public web
RESTRICT="test"

java_prepare() {
	epatch "${FILESDIR}/${P}.patch"

	# Delete test files as they aren't installed
	rm -vr src/nu/xom/tests || die

	# Delete bundled jars
	rm -v lib/*.jar || die

	# Move bundled jaxen to where the build.xml expects it
	mv "${WORKDIR}"/jaxen-1.1.1/ lib/ || die

	java-pkg_jar-from --into lib/ xml-commons-external-1.3
	java-pkg_jar-from --into lib/ xerces-2
	java-pkg_jar-from --build-only --into lib/ jarjar-1
	# tagsoup is only needed to run betterdoc but we use the pregenerated ones
}

src_compile() {
	local ant_flags="-Ddebug=off"
	use examples && ant_flags="${ant_flags} -Dservlet.jar=$(java-pkg_getjar servletapi-2.4 servlet-api.jar)"

	ANT_TASKS="jarjar-1" eant jar ${ant_flags}\
		$(use examples && echo samples)
}

src_install() {
	java-pkg_newjar build/${P}.jar ${PN}.jar
	use examples && java-pkg_dojar build/xom-samples.jar
	dodoc Todo.txt || die

	use doc && java-pkg_dojavadoc apidocs/
	use source && java-pkg_dosrc src/*
	use examples && java-pkg_doexamples --subdir nu/xom/samples src/nu/xom/samples
}
