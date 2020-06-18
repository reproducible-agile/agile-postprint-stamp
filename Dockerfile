# Started from https://github.com/virtualstaticvoid/heroku-docker-r#shiny-applications
#FROM virtualstaticvoid/heroku-docker-r:shiny
# did not work, because the --overlay features needs a newer qpdf, so created own image based on
# - https://github.com/virtualstaticvoid/heroku-docker-r/blob/master/Dockerfile.shiny
# - https://github.com/virtualstaticvoid/heroku-docker-r/blob/master/Dockerfile

ARG HEROKU_VERSION=20
ARG R_VERSION=4.0.1

FROM heroku/heroku:$HEROKU_VERSION

# Set default locale
ENV LANG C.UTF-8

# Set default timezone
ENV TZ UTC

RUN apt-get update -q && apt-get -qy install \
    qpdf \
  && rm -rf /var/lib/apt/lists/*

# install R & set default CRAN repo
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
  && UBUNTU_VERSION=$(lsb_release -c | awk '{print $2}') \
  && echo "deb https://cloud.r-project.org/bin/linux/ubuntu $UBUNTU_VERSION-cran40/" > /etc/apt/sources.list.d/cran.list \
  && apt-get update -q \
  && apt-get install -qy --no-install-recommends \
    apt-transport-https \
    curl \
    fontconfig \
    libbz2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libicu-dev \
    liblzma-dev \
    libpcre2-dev \
    libpcre3-dev \
    locales \
    perl \
    sudo \
    tzdata \
    wget \
    zlib1g-dev \
    r-base-dev=${R_VERSION}* \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && echo 'options(repos = c(CRAN = "https://cloud.r-project.org/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
  && echo '.libPaths(c("/app/R/site-library", .libPaths()))' >> /etc/R/Rprofile.site \
  && mkdir -p /app/R/site-library

WORKDIR /app

COPY renv.lock .
COPY renv/activate.R ./renv/activate.R
COPY .Rprofile .

RUN /usr/bin/R --no-save --quiet --slave -e 'renv::restore()'

COPY app.R app.R
COPY run.R run.R
COPY stamp/* stamp/
COPY www/ www/

LABEL org.label-schema.license="GPL-3.0" \
      org.label-schema.vcs-url="https://github.com/reproducible-agile/agile-postprint-stamp" \
      org.label-schema.vendor="Reproducible AGILE" \
      maintainer="Daniel Nüst <daniel.nuest@uni-muenster.de>"

ENV PORT=8080

CMD ["/usr/bin/R", "--no-save", "--gui-none", "-f /app/run.R"]
