FROM mcr.microsoft.com/windows/nanoserver:sac2016 as tool
FROM mcr.microsoft.com/powershell:nanoserver-1903 as powershell
FROM mcr.microsoft.com/dotnet/core/runtime
COPY --from=powershell ["/Program Files/PowerShell", "/Program Files/PowerShell"]
COPY /base/common/configuration /configuration
# COPY ./Website /app
# COPY ./license.xml /app/sitecoreruntime/license.xml
COPY --from=tool /Windows/System32/certoc.exe /configuration/certoc.exe
USER ContainerAdministrator
# WORKDIR /configuration
# RUN certoc.exe -ImportPFX -p secret root cert.pfx
# SHELL ["cmd.exe", "/s" , "/c"]
RUN setx /m PATH "%PATH%;C:\Program Files\PowerShell"
ENTRYPOINT ["pwsh", "Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-Expression", "cmd"]