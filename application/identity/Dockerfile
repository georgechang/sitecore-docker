ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
FROM mcr.microsoft.com/windows/nanoserver:sac2016 as tool
FROM powershell:${WIN_VERSION} as powershell
FROM mcr.microsoft.com/dotnet/core/runtime:2.2-nanoserver-${WIN_VERSION}
ARG CONFIGURATION
COPY --from=powershell ["/PowerShell", "/PowerShell"]
# COPY --from=tool /Windows/System32/certoc.exe /configuration/certoc.exe
COPY --from=builder /utilities /utilities
COPY --from=builder ./resources/identity/Content/Website /app
COPY ${CONFIGURATION} /configuration
USER ContainerAdministrator
RUN setx /m PATH "%PATH%;C:\PowerShell"
ENTRYPOINT ["pwsh", "./utilities/Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/app", "-LicensePath", "/app/sitecoreruntime", "-Expression", "dotnet /app/Sitecore.IdentityServer.Host.dll"]