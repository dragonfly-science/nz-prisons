FROM docker.dragonfly.co.nz/dragonverse-18.04:2020-05-18

RUN apt update
RUN apt install -y libv8-dev

RUN Rscript -e 'install.packages("tidybayes")'
RUN Rscript -e 'install.packages("bookdown")'
RUN Rscript -e 'install.packages("furrr")'
RUN Rscript -e 'install.packages("here")'
RUN Rscript -e 'install.packages("Rlab")'
RUN Rscript -e 'install.packages(c("coda","mvtnorm","devtools","loo","dagitty"))'
RUN Rscript -e 'devtools::install_github("rmcelreath/rethinking")'
RUN Rscript -e 'remotes::install_github("paul-buerkner/brms")'
RUN Rscript -e 'install.packages("gt")'
