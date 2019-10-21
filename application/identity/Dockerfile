ARG WIN_VERSION
FROM common:${WIN_VERSION} as common
FROM mcr.microsoft.com/windows/nanoserver:sac2016 as tool
FROM mcr.microsoft.com/powershell:nanoserver-${WIN_VERSION} as powershell
FROM mcr.microsoft.com/dotnet/core/runtime:2.2-nanoserver-${WIN_VERSION}
COPY --from=powershell ["/Program Files/PowerShell", "/Program Files/PowerShell"]
COPY --from=tool /Windows/System32/certoc.exe /configuration/certoc.exe
COPY --from=common /utilities /utilities
COPY --from=common ./resources/identity/Content/Website /app
COPY --from=common ./resources/license.xml /app/sitecoreruntime/license.xml
COPY ./configuration /configuration
USER ContainerAdministrator
RUN setx /m PATH "%PATH%;C:\Program Files\PowerShell"
ENTRYPOINT ["pwsh", "./utilities/Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/app", "-Expression", "dotnet /app/Sitecore.IdentityServer.Host.dll"]