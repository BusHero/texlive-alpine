FROM alpine as alpine-latex

# NOTE: to maintainers, please keep this listing alphabetical.
RUN apk --no-cache add \
  freetype \
  fontconfig \
  gnupg \
  gzip \
  perl \
  tar \
  wget \
  xz

# TeXLive binaries location
ARG texlive_bin="/opt/texlive/texdir/bin"

# The architecture suffix may vary based on different distributions,
# particularly for musl libc based distrubions, like Alpine linux,
# where the suffix is linuxmusl
RUN TEXLIVE_ARCH="$(uname -m)-linuxmusl" && \
  mkdir -p ${texlive_bin} && \
  ln -sf "${texlive_bin}/${TEXLIVE_ARCH}" "${texlive_bin}/default"

# Modify PATH environment variable, prepending TexLive bin directory
ENV PATH="${texlive_bin}/default:${PATH}"

WORKDIR /root

# Installer scripts and config
COPY common/texlive.profile /root/texlive.profile
COPY common/install-texlive.sh /root/install-texlive.sh
COPY common/packages.txt /root/packages.txt

# TeXLive version to install (leave empty to use the latest version).
ARG texlive_version=

RUN echo "binary_x86_64-linuxmusl 1" >> /root/texlive.profile \
  && /root/install-texlive.sh $texlive_version \
  && sed -e 's/ *#.*$//' -e '/^ *$/d' /root/packages.txt | \
  xargs tlmgr install \
  && rm -f /root/texlive.profile \
  /root/install-texlive.sh \
  /root/packages.txt \
  && TERM=dumb luaotfload-tool --update \
  && chmod -R o+w /opt/texlive/texdir/texmf-var

WORKDIR /data
