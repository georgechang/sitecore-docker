ARG WIN_VERSION
FROM mcr.microsoft.com/windows/nanoserver:${WIN_VERSION}
ARG PS_PATH
COPY ${PS_PATH} /PowerShell
USER ContainerAdministrator
RUN setx /m PATH "%PATH%C:\PowerShell;"
USER ContainerUser
CMD ["/PowerShell/pwsh.exe"]