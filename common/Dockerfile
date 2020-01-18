ARG WIN_VERSION
FROM mcr.microsoft.com/powershell:nanoserver-${WIN_VERSION}
ARG SC_ARCHIVE
ARG XC_ARCHIVE
ARG SI_ARCHIVE
COPY ./utilities /utilities
COPY ${SC_ARCHIVE} /packages/sitecore.zip
COPY ${XC_ARCHIVE} /packages/xconnect.zip
COPY ${SI_ARCHIVE} /packages/identity.zip
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Expand-Archive /packages/sitecore.zip -DestinationPath /resources/sitecore
RUN Expand-Archive /packages/xconnect.zip -DestinationPath /resources/xconnect
RUN Expand-Archive /packages/identity.zip -DestinationPath /resources/identity