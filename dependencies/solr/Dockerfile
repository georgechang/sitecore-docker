ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
ARG JAVA_BASE_URL
ARG SOLR_VERSION
ARG SOLR_BASE_URL
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN New-Item -ItemType Directory -Path C:\temp | Out-Null; \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
RUN Write-Host ('Installing JRE...'); \
	Write-Host ('Downloading {0} ...' -f $url); \
	Invoke-WebRequest -Uri $env:JAVA_BASE_URL -OutFile 'openjdk.zip'; \
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

FROM powershell:nanoserver-${WIN_VERSION}
ARG CONFIGURATION
COPY --from=builder ./openjdk /openjdk
COPY --from=builder ./solr /solr
COPY ${CONFIGURATION} /configuration
ENV JAVA_HOME C:\\openjdk
USER ContainerAdministrator
RUN setx /M PATH "%PATH%C:\openjdk\bin;"
EXPOSE 8983
ENTRYPOINT ["pwsh", "/configuration/Startup.ps1"]