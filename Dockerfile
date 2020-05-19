FROM docker.dragonfly.co.nz/dragonverse-18.04:2020-05-18

RUN Rscript -e 'install.packages("bookdown")'
RUN Rscript -e 'install.packages("furrr")'
RUN Rscript -e 'install.packages("here")'
RUN Rscript -e 'install.packages("tidybayes")'
RUN Rscript -e 'remotes::install_github("paul-buerkner/brms")'
