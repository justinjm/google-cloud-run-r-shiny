# get shiny server plus tidyverse packages image
FROM rocker/shiny-verse:latest

# system libraries of general use
RUN apt-get update && apt-get install -y \
    curl \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev\
    ## clean up
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/ \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# install required R packages
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboardPlus', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinythemes', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DT', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')"

# clean up
RUN rm -rf /tmp/downloaded_packages/ /tmp/*.rds

# Copy configuration files into the Docker image
COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf

# Copy shiny app into the Docker image
COPY app /srv/shiny-server/

RUN rm /srv/shiny-server/index.html

# Make the ShinyApp available at port 5000
EXPOSE 5000

# Copy shiny app execution file into the Docker image
COPY shiny-server.sh /usr/bin/shiny-server.sh

USER shiny

CMD ["/usr/bin/shiny-server"]