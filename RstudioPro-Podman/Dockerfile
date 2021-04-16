ARG R_VERSION=3.6
FROM rstudio/r-base:${R_VERSION}-bionic
#'' ARG RVERSION=4.0.2
# FROM ubuntu:focal
# ARG R_VERSION=4.0.4
# ARG CRAN_CHECKPOINT=https://packagemanager.rstudio.com/all/766976


ENV DEBIAN_FRONTEND=noninteractive

# Install Python  -------------------------------------------------------------#
# ARG PYTHON_VERSION=3.6.5
#RUN curl -o /tmp/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-4.5.4-Linux-x86_64.sh && \
#    /bin/bash /tmp/miniconda.sh -b -p /opt/python/${PYTHON_VERSION} && \
#    rm /tmp/miniconda.sh && \
#    /opt/python/${PYTHON_VERSION}/bin/conda clean -tipsy && \
#    /opt/python/${PYTHON_VERSION}/bin/conda clean -a && \
#    /opt/python/${PYTHON_VERSION}/bin/pip install virtualenv

# Install other Python PyPi packages
#RUN /opt/python/${PYTHON_VERSION}/bin/pip install --no-cache-dir \
#                pip==20.0.2 \
#                jupyter==1.0.0 \
#                'jupyterlab<3.0.0' \
#                rsp_jupyter \
#                rsconnect_jupyter

# Install Jupyter extensions
#RUN /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsp_jupyter && \
#    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsp_jupyter && \
#    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension install --sys-prefix --py rsconnect_jupyter && \
#    /opt/python/${PYTHON_VERSION}/bin/jupyter-nbextension enable --sys-prefix --py rsconnect_jupyter && \
#    /opt/python/${PYTHON_VERSION}/bin/jupyter-serverextension enable --sys-prefix --py rsconnect_jupyter

# update
RUN apt-get clean
RUN apt-get update -y

## Kerberos for SQL server auth and mssql drivers
RUN apt-get install --yes apt-transport-https curl gnupg
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
  && curl https://packages.microsoft.com/config/ubuntu/19.10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
  && apt-get update \
  && ACCEPT_EULA=Y apt-get install --yes --no-install-recommends msodbcsql17
  ##&& ACCEPT_EULA=Y apt-get install -y mssql-tools
  ##&& echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
  ##&& source ~/.bashrc
  #&& DEBIAN_FRONTEND=noninteractive apt-get -yqq install krb5-user libpam-krb5

# mysql
#RUN apt-get install -y unixodbc unixodbc-dev libmyodbc
#RUN mkdir -p /usr/lib/x86_64-linux-gnu/odbc/
#COPY mysql-connector-odbc-setup_8.0.20-1ubuntu20.04_amd64.deb /tmp/
#RUN dpkg -i /tmp/mysql-connector-odbc-setup_8.0.20-1ubuntu20.04_amd64.deb sudo apt-get install -f.
#RUN cd /tmp; tar -xvf /tmp/mysql-connector-odbc-setup_8.0.20-1ubuntu20.04_amd64.tar.gz
#RUN cd /tmp; sudo cp mysql-connector-odbc-setup_8.0.20-1ubuntu20.04_amd64/lib/libmyodbc8* /usr/lib/x86_64-linux-gnu/odbc/
#RUN sudo /tmp/mysql-connector-odbc-setup_8.0.20-1ubuntu20.04_amd64/bin/myodbc-installer -d -a -n "MySQL" -t "DRIVER=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8w.so;Setup=/usr/lib/x86_64-linux-gnu/odbc/libmyodbc8S.so;"

# bcp for copying data directly to MSSQL
RUN ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install --yes mssql-tools

# bcp
RUN echo PATH="$PATH:/opt/mssql-tools/bin" >> /etc/profile
RUN echo export PATH >> /etc/profile
#RUN echo Sys.setenv\(PATH=\"$PATH:/opt/mssql-tools/bin\"\) >> /usr/local/lib/R/etc/Rprofile.site


# no idea why there's no bash...????
RUN apt-get update -y
#RUN apt-get -y install bash

# Runtime settings ------------------------------------------------------------#
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

RUN curl -L -o /usr/local/bin/wait-for-it.sh https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && \
    chmod +x /usr/local/bin/wait-for-it.sh

# Set default env values
ENV RSP_LICENSE ""
ENV RSP_LICENSE_SERVER ""
ENV RSP_TESTUSER rstudio
ENV RSP_TESTUSER_PASSWD rstudio
ENV RSP_TESTUSER_UID 10000
ENV RSP_LAUNCHER true
ENV RSP_LAUNCHER_TIMEOUT 10


# COPY conf/* /etc/rstudio/

# User home volume-------------------------------------------------------------#
# the user's home volume needs to be setup using:
# sudo podman volume create vol_rstudio_user_home
# this is then mapped at runtime by adding:
# --mount 'type=volume,src=vol_rstudio_user_home,dst=/home' \
# then after first login, user setup needs to proceed including ssh keys, setup of git replication etc.

# Install RStudio Server Pro --------------------------------------------------#
ARG RSP_VERSION=1.4.1106-5
ARG RSP_DOWNLOAD_URL=https://download2.rstudio.org/server/bionic/amd64
RUN apt-get update --fix-missing
RUN apt-get install -y gdebi-core
RUN curl -O ${RSP_DOWNLOAD_URL}/rstudio-server-pro-${RSP_VERSION}-amd64.deb \
    && ls -la \
    && gdebi --non-interactive rstudio-server-pro-${RSP_VERSION}-amd64.deb

# server config
COPY conf/rserver.conf /etc/rstudio/rserver.conf
COPY conf/rsession.conf /etc/rstudio/rsession.conf

# RUN sudo useradd --system rstudio-server

# Create log dir
RUN mkdir -p /var/lib/rstudio-server/monitor/log && \
    chown -R rstudio-server:rstudio-server /var/lib/rstudio-server/monitor


# Set logging config
COPY logging.conf /etc/rstudio/logging.conf

##------------------------------------------------------------------------------#
#---------PAM Integration--------------------------
#-------------------------------------------------------------------------------#

# solves error "chfn: PAM: System error"
# note this was not required for the rocker/verse based images!
RUN ln -s -f /bin/true /usr/bin/chfn

# install sssd
# this also chanegs the /etc/nsswitch.conf to include sss
RUN apt install --yes sssd sssd-tools
# how about libnss-sss libpam-sss auth-client-config??

# ------krb5-------
# install
RUN apt install --yes krb5-user sssd-krb5
# copy config
COPY krb5.conf /etc/krb5.conf

# -------nss-------
# nss is installed by default, and this config file is changed to correct values by
# installation of sssd. but lets just make sure and copy in the known config
COPY nsswitch.conf /etc/nsswitch.conf

#-------sssd finalize-------
# SSSD config file
COPY sssd.conf /etc/sssd/sssd.conf
RUN chmod 600 /etc/sssd/sssd.conf
RUN chown root:root /etc/sssd/sssd.conf

#-------PAM-------
COPY rstudio /etc/pam.d/rstudio

#----copy common-session as a test----
COPY common-session /etc/pam.d/common-session


#-------rsyslog-------
RUN apt install --yes rsyslog


##------------------------------------------------------------------------------#
#---------SQL Kerberos--------------------------
#-------------------------------------------------------------------------------#

COPY odbc.ini /etc/odbc.ini

##------------------------------------------------------------------------------#
#---------Final Stuff--------------------------
#-------------------------------------------------------------------------------#

EXPOSE 8787/tcp
EXPOSE 5559/tcp

# Copy config and startup
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

ENTRYPOINT ["tini", "--"]
CMD ["/usr/local/bin/startup.sh"]
