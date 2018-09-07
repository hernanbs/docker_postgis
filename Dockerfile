FROM ubuntu:16.04
LABEL maintainer="Hernan Santos"
LABEL version="1.0"

WORKDIR /home/
USER root
#Mudando data e hora
RUN apt -y update && apt install -y tzdata
ENV TZ=America/Sao_Paulo
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata  && date
#
# Download postgis e postgresql10
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main' >> /etc/apt/sources.list.d/pgdg.list
ADD https://www.postgresql.org/media/keys/ACCC4CF8.asc tempkey
RUN apt-key add tempkey
RUN apt -y update && apt install -y postgresql-10 postgresql-10-postgis-2.4 postgresql-contrib
#

#Variaveis de ambiente
ENV ETCDATA /etc/postgresql/10/main
ENV PGDATA /var/lib/postgresql/10/main
#

#Criando arquivo de configuracao postgresql.conf
RUN echo "\
    listen_addresses = '*'\n\
    log_timezone = 'localtime'\n\
    stats_temp_directory = '/var/lib/postgresql/10/main/pg_stat_tmp'\n\
    timezone = 'localtime'\n\
    "  >  ${ETCDATA}/postgresql.conf
#

#Configurando pg_hba.conf
#TODO retirar linha 'host  all  all 0.0.0.0/0 trust' ,pois só é usada para teste
RUN echo "\
    host  all  all 0.0.0.0/0 trust\n\
    " >  ${ETCDATA}/pg_hba.conf

RUN ln -s /etc/postgresql/10/main/* /var/lib/postgresql/10/main/
USER postgres
EXPOSE 5432
VOLUME  ["/etc/postgresql", "/var/log/postgresql","/var/lib/postgresql/10/main"]
CMD ["/usr/lib/postgresql/10/bin/postgres", "-D", "/var/lib/postgresql/10/main", "-c", "config_file=/etc/postgresql/10/main/postgresql.conf"]
