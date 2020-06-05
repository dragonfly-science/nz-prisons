FROM docker.dragonfly.co.nz/dragonverse-18.04:2020-05-18

RUN apt update
RUN apt install -y libv8-dev tree

RUN Rscript -e 'install.packages("Rlab")'
RUN Rscript -e 'install.packages("bookdown")'
RUN Rscript -e 'install.packages("coda")'
RUN Rscript -e 'install.packages("dagitty")'
RUN Rscript -e 'install.packages("devtools")'
RUN Rscript -e 'install.packages("furrr")'
RUN Rscript -e 'install.packages("gt")'
RUN Rscript -e 'install.packages("here")'
RUN Rscript -e 'install.packages("loo")'
RUN Rscript -e 'install.packages("mvtnorm")'
RUN Rscript -e 'install.packages("tidybayes")'
RUN Rscript -e 'devtools::install_github("rmcelreath/rethinking")'
