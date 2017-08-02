FROM rocker/r-ver:3.3.3

RUN R -e "install.packages(c("BH", "MASS", "Matrix", "NMF", "R6", "RColorBrewer", "Rcpp", "TTR", "XML", "assertthat", "backports", "base64enc", "bindr", "bindrcpp", "bitops", "broom", "caTools", "cluster", "codetools", "colorspace", "crayon", "curl", "data.table", "deSolve", "debugme", "dichromat", "digest", "doParallel", "dplyr", "evaluate", "foreach", "foreign", "ggplot2", "ggthemes", "glue", "gridBase", "gtable", "highcharter", "highr", "htmltools", "htmlwidgets", "httpuv", "httr", "igraph", "irlba", "iterators", "jsonlite", "knitr", "labeling", "lattice", "lazyeval", "lubridate", "magrittr", "markdown", "mime", "miniUI", "mnormt", "munsell", "nlme", "openssl", "packrat", "parsedate", "pingr", "pkgconfig", "pkgmaker", "plogr", "plyr", "png", "praise", "processx", "psych", "purrr", "quantmod", "registry", "rematch", "reshape2", "rlang", "rlist", "rmarkdown", "rngtools", "rprojroot", "rstudioapi", "scales", "shiny", "shinyBS",  "showimage", "sourcetools", "stringi", "stringr", "testthat", "tibble", "tidyr", "xtable", "xts", "yaml", "zoo"), repos = 'https://cloud.r-project.org/')

RUN apt-get install -y wget gdebi-core libcurl4-gnutls-dev libcairo2-dev/unstable libxt-dev

RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb


EXPOSE 3838

COPY /docker_app /srv/shiny-server/sir

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
