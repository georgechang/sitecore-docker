ARG WIN_VERSION
FROM common:${WIN_VERSION}
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
RUN Install-Module SqlServer
RUN Install-Module mashups
ENTRYPOINT [ "pwsh" ]