ARG WIN_VERSION
FROM mcr.microsoft.com/powershell:windowsservercore-${WIN_VERSION}
ARG SC_ARCHIVE
ARG XC_ARCHIVE
ARG SI_ARCHIVE
COPY ./configuration /configuration
COPY ./utilities /utilities
COPY ./packages /packages
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Expand-Archive ./packages/$env:SC_ARCHIVE -DestinationPath /resources/sitecore
RUN Expand-Archive ./packages/$env:XC_ARCHIVE -DestinationPath /resources/xconnect
RUN Expand-Archive ./packages/$env:SI_ARCHIVE -DestinationPath /resources/identity