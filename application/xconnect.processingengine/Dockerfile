ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-${WIN_VERSION}
ARG CONFIGURATION
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Enable-LocalUser Administrator; \
	SecEdit.exe /export /cfg secpol.cfg; \
	(Get-Content secpol.cfg).Replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | \
	Out-File secpol.cfg; \
	SecEdit.exe /configure /db C:\Windows\Security\Local.sdb /cfg secpol.cfg /areas SECURITYPOLICY; \
	Remove-Item secpol.cfg; \
	Set-LocalUser Administrator -Password (New-Object SecureString)
COPY --from=builder ./utilities /utilities
COPY --from=builder ./logmonitor /logmonitor
COPY --from=builder ./resources/xconnect/Content/Website/App_Data/jobs/continuous/ProcessingEngine /app
COPY ${CONFIGURATION} /configuration
COPY ./logmonitor/LogMonitorConfig.json /logmonitor/LogMonitorConfig.json
USER ContainerAdministrator
ENTRYPOINT ["C:\\logmonitor\\LogMonitor.exe", "powershell", "./utilities/Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data"]