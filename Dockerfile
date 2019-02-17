ARG CURL_VER=7.63.0
ARG LIBRE_VER=2.8.2
ARG GIT_VER=2.20.1
ARG JDK_VER=8
ARG JDK_UPD=201
ARG JDK_BLD=26
ARG OUTDIR=/output

FROM spritsail/debian-builder as java

ARG JDK_VER
ARG JDK_UPD
ARG JDK_BLD
ARG JDK_FULLVER=jdk${JDK_VER}u${JDK_UPD}-b${JDK_BLD}
ARG OUTDIR

# Hacky fix for installing openjdk
RUN mkdir -p /usr/share/man/man1 && \
    apt-get -qy update && \
    apt-get -qy install \
        openjdk-8-jdk \
        cpio \
        unzip \
        zip \
        libcups2-dev \
        libx11-dev \
        libxext-dev \
        libxrender-dev \
        libxtst-dev \
        libxt-dev \
        libasound2-dev \
        libfreetype6-dev \
        libgif-dev


WORKDIR /tmp/${JDK_FULLVER}

# Much of this is adapted from the Linux From Scratch guide
# http://www.linuxfromscratch.org/blfs/view/svn/general/openjdk.html

# Fetch and decompress sources
RUN curl -sSL http://hg.openjdk.java.net/jdk${JDK_VER}u/jdk${JDK_VER}u/archive/${JDK_FULLVER}.tar.bz2 \
        | tar xj --strip-components=1 && \
    \
    for proj in corba hotspot jaxp jaxws langtools jdk nashorn; do \
        mkdir -p ${proj}; \
        curl -sSL http://hg.openjdk.java.net/jdk${JDK_VER}u/jdk${JDK_VER}u/${proj}/archive/${JDK_FULLVER}.tar.bz2 \
            | tar xj --strip-components=1 -C ${proj}; \
    done

ENV CFLAGS_EXTRA="-Wno-error=deprecated-declarations -fno-lifetime-dse -fno-delete-null-pointer-checks"

# Configure OpenJDK
RUN sh configure \
        --prefix=/usr/lib/jvm \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --with-update-version="${JDK_UPD}" \
        --with-build-number="${JDK_BLD}" \
        --with-jvm-variants=server \
        --with-debug-level=release \
        --disable-debug-symbols \
        --disable-zip-debug-info \
        --enable-unlimited-crypto \
        --with-zlib=system \
        --with-giflib=system \
        --with-jobs="$(nproc)" \
        --with-boot-jdk=/usr/lib/jvm/java-8-openjdk-amd64/ \
        --with-extra-cflags="${CFLAGS} ${CFLAGS_EXTRA}" \
        --with-extra-cxxflags="${CXXFLAGS} ${CFLAGS_EXTRA}" \
        --disable-freetype-bundling \
        --disable-headful && \
	\
	# Compile OpenJDK
    make images COMPRESS_JARS=true

# Move and cleanup
RUN mkdir -p ${OUTDIR} && \
    cp -r build/*/images/j2re-image ${OUTDIR}/jvm && \
    cd ${OUTDIR}/jvm && \
    # Strip libraries because space
    find . -iname '*.so' -exec strip -s {} + && \
    find . -iname "*.diz" -delete && \
    find . -iname "*.debuginfo" -delete && \
    find . -name "*.jar" -o -name "*.sym" \! -perm /006 \
        | xargs chmod go+r && \
    rm -rf \
        man \
        release \
        plugin \
        bin/javaws \
        lib/missioncontrol \
        lib/visualvm \
        lib/*jfx* \
        lib/*javafx* \
        lib/plugin.jar \
        lib/ext/jfxrt.jar \
        lib/ext/nashorn.jar \
        lib/javaws.jar \
        lib/images \
        lib/desktop \
        lib/management \
        lib/deploy* \
        lib/amd64/libdecora_sse.so \
        lib/amd64/libprism_*.so \
        lib/amd64/libfxplugins.so \
        lib/amd64/libglass.so \
        lib/amd64/libgstreamer-lite.so \
        lib/amd64/libjavafx*.so \
        lib/amd64/libjfx*.so

# Generate java/cacerts keystore
RUN apt-get -qy install p11-kit && \
    mkdir -p ${OUTDIR}/certs/java && \
    # Copy cacerts from the debian builder
    # TODO: Move this into a separate package with update scripts
    cp /etc/ssl/certs/ca-certificates.crt ${OUTDIR}/certs && \
    trust extract \
        --format=java-cacerts \
        --filter=ca-anchors \
        --purpose=server-auth \
        ${OUTDIR}/certs/java/cacerts && \
    # Make Java cacerts keystore available to the JVM
    rm -f ${OUTDIR}/jvm/lib/security/cacerts && \
    ln -s /etc/ssl/certs/java/cacerts ${OUTDIR}/jvm/lib/security

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# This entire stage is because Spigot. Thanks Spigot. Thpigot.

FROM spritsail/debian-builder as git
ARG CURL_VER
ARG LIBRE_VER
ARG GIT_VER
ARG OUTDIR

WORKDIR /tmp/libressl

RUN apt-get install -qy gettext wget

# Build and install LibreSSL
RUN curl -sSL https://ftp.openbsd.org/pub/OpenBSD/LibreSSL/libressl-${LIBRE_VER}.tar.gz \
        | tar xz --strip-components=1 \
 && ./configure --prefix=/usr \
 && make -j "$(nproc)" install

WORKDIR /tmp/curl

RUN curl -fL https://curl.haxx.se/download/curl-${CURL_VER}.tar.gz | tar xz --strip-components=1 \
 && autoreconf -sif \
 && ./configure \
        --prefix=/usr \
        --enable-ipv6 \
        --enable-optimize \
        --enable-symbol-hiding \
        --enable-versioned-symbols \
        --enable-threaded-resolver \
        --with-ssl \
        --disable-crypto-auth \
        --disable-curldebug \
        --disable-dependency-tracking \
        --disable-dict \
        --disable-gopher \
        --disable-imap \
        --disable-libcurl-option \
        --disable-ldap \
        --disable-ldaps \
        --disable-manual \
        --disable-ntlm-wb \
        --disable-pop3 \
        --disable-rtsp \
        --disable-smb \
        --disable-smtp \
        --disable-sspi \
        --disable-telnet \
        --disable-tftp \
        --disable-ftp \
        --disable-tls-srp \
        --disable-verbose \
        --without-axtls \
        --without-zlib \
        --without-libmetalink \
        --without-libpsl \
        --without-librtmp \
        --without-winidn \
 && make -j$(nproc)

RUN mkdir -p /output/usr/lib output \
 && make -j$(nproc) DESTDIR=$PWD/output install \
 && make install \
 && cp /tmp/curl/output/usr/lib/libcurl.so* ${OUTDIR}/usr/lib

WORKDIR /tmp/git

RUN wget -O- https://www.kernel.org/pub/software/scm/git/git-${GIT_VER}.tar.xz | tar xJ --strip-components=1 \
 && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
 && make -j "$(nproc)" DESTDIR=${OUTDIR} install \
 && rm -r ${OUTDIR}/usr/share/git-gui ${OUTDIR}/usr/share/gitk ${OUTDIR}/usr/share/gitweb ${OUTDIR}/usr/share/locale \
          ${OUTDIR}/usr/bin/git-* ${OUTDIR}/usr/bin/gitk \
          ${OUTDIR}/usr/libexec/git-core/{mergetools,git-sh-*,git-imap-send,git-shell,git-remote-testsvn,git-credential-store,git-credential-cache--daemon,git-credential-cache,git-cvsserver,git-daemon,git-p4,git-citool,git-svn,git-archimport,git-cvsimport,git-send-email,git-http-backend}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FROM spritsail/amp

ARG JDK_VER
ARG JDK_UPD
ARG JDK_BLD
ARG OUTDIR

LABEL maintainer="Spritsail <minecraft@spritsail.io>" \
      org.label-schema.name="AMP with Minecraft module" \
      io.spritsail.version.openjdk=${JDK_VER}u${JDK_UPD}-b${JDK_BLD} \
      io.spritsail.version.curl=${CURL_VER} \
      io.spritsail.version.libressl=${LIBRE_VER} \
      io.spritsail.version.git=${GIT_VER}

USER root

COPY --from=java ${OUTDIR}/jvm /usr/lib/jvm
COPY --from=java ${OUTDIR}/certs /etc/ssl/certs
COPY --from=java /lib/x86_64-linux-gnu/libz.so.1 /usr/lib
COPY --from=git ${OUTDIR} /
COPY mc-* /usr/bin/

RUN ldconfig && \
    ln -sv /usr/lib/jvm/bin/* /usr/bin && \
    chmod +rx /usr/bin/mc-*

USER amp

ENV MODULE=Minecraft \
    EXTRAS="+MinecraftModule.Minecraft.PortNumber 25565 +MinecraftModule.Java.MaxHeapSizeMB 3072"

EXPOSE 25565
