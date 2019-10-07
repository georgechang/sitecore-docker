ARG WINVERSION
ARG SCVERSION
FROM scbase-netcore:${WINVERSION}-${SCVERSION}
COPY ./application/identity/configuration /configuration
COPY ./resources/identity/Website /app
COPY ./resources/license.xml /app/sitecoreruntime/license.xml
WORKDIR /configuration
ENTRYPOINT ["pwsh", "Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-Expression", "dotnet /app/Sitecore.IdentityServer.Host.dll"]