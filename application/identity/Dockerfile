FROM scbase:netcore
COPY ./application/identity/configuration /configuration
COPY ./resources/identity/Website /app
COPY ./resources/license.xml /app/sitecoreruntime/license.xml
USER ContainerAdministrator
WORKDIR /configuration
ENTRYPOINT ["pwsh", "Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-Expression", "dotnet /app/Sitecore.IdentityServer.Host.dll"]