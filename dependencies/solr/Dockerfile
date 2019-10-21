ARG WIN_VERSION
FROM mcr.microsoft.com/powershell:nanoserver-${WIN_VERSION} as stage
ARG JAVA_VERSION=8u232
ARG JAVA_BASE_URL=https://github.com/AdoptOpenJDK/openjdk8-upstream-binaries/releases/download/jdk8u232-b09/OpenJDK8U-jre_
ARG JAVA_URL_VERSION=8u232b09
ARG SOLR_VERSION=7.5.0
ARG SOLR_BASE_URL=https://archive.apache.org/dist/lucene/solr
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN New-Item -ItemType Directory -Path C:\temp | Out-Null; \
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
RUN Write-Host ('Installing JRE {0}...' -f $env:JAVA_VERSION); \
  $url = ('{0}x64_windows_{1}.zip' -f $env:JAVA_BASE_URL, $env:JAVA_URL_VERSION); \
  Write-Host ('Downloading {0} ...' -f $url); \
  Invoke-WebRequest -Uri $url -OutFile 'openjdk.zip'; \
  Write-Host 'Expanding ...'; \
  Expand-Archive openjdk.zip -DestinationPath C:\temp; \
  Move-Item -Path C:\temp\* -Destination C:\openjdk;
RUN Write-Host ('Installing Solr {0}...' -f $env:SOLR_VERSION); \
  $url = ('{0}/{1}/solr-{1}.zip' -f $env:SOLR_BASE_URL, $env:SOLR_VERSION); \
  Write-Host ('Downloading {0} ...' -f $url); \
  Invoke-WebRequest -Uri $url -OutFile 'solr.zip'; \
  Write-Host 'Expanding ...'; \
  Expand-Archive solr.zip -DestinationPath C:\temp; \
  Move-Item -Path C:\temp\* -Destination C:\solr;

FROM mcr.microsoft.com/windows/nanoserver:${WIN_VERSION}
COPY --from=stage ./openjdk /openjdk
COPY --from=stage ./solr /solr
ENV JAVA_HOME C:\\openjdk
USER ContainerAdministrator
RUN setx /M PATH "%PATH%C:\openjdk\bin"
USER ContainerUser
EXPOSE 8983
ENTRYPOINT [ "/solr/bin/solr.cmd", "start", "-f", "-t", "./mydata", "-p", "8983" ]