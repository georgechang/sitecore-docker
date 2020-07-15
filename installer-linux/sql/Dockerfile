FROM mcr.microsoft.com/powershell:latest
ENV ACCEPT_EULA=Y
RUN apt-get update && apt-get install -y wget gnupg2 zip
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
RUN curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | tee /etc/apt/sources.list.d/msprod.list
RUN apt-get update && apt-get install -y mssql-tools unixodbc-dev libunwind8 libicu60
RUN echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc
RUN wget https://download.microsoft.com/download/2/a/e/2aefe4de-8aa8-47dd-aadd-fd94efb9b3ad/sqlpackage-linux-x64-en-US-15.0.4826.1.zip -O ~/sqlpackage.zip
RUN mkdir ~/sqlpackage
RUN unzip ~/sqlpackage.zip -d ~/sqlpackage
RUN echo "export PATH=\"\$PATH:$HOME/sqlpackage\"" >> ~/.bashrc
RUN chmod a+x ~/sqlpackage/sqlpackage
ARG SC_VERSION
COPY ./configuration/${SC_VERSION} ~/configuration
COPY ./scripts ~/scripts
CMD [ "/bin/bash" ]