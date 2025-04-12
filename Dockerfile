FROM rocker/r-ver:4.2.0

RUN R -e "install.packages(c('plumber', 'httr', 'googlesheets4'), repos='https://cloud.r-project.org')"

COPY . /app
WORKDIR /app

EXPOSE 8000

CMD ["Rscript", "start.sh"]
