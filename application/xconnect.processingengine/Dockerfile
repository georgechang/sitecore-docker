ARG WIN_VERSION
ARG SC_VERSION
FROM common:${WIN_VERSION} as common
FROM mcr.microsoft.com/dotnet/framework/runtime:4.8-windowsservercore-${WIN_VERSION}
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Enable-LocalUser Administrator; \
	SecEdit.exe /export /cfg secpol.cfg; \
	(Get-Content secpol.cfg).Replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | \
	Out-File secpol.cfg; \
	SecEdit.exe /configure /db C:\Windows\Security\Local.sdb /cfg secpol.cfg /areas SECURITYPOLICY; \
	Remove-Item secpol.cfg; \
	Set-LocalUser Administrator -Password (New-Object SecureString)
COPY --from=common ./utilities /utilities
COPY --from=common ./resources/xconnect/Content/Website/App_Data/jobs/continuous/ProcessingEngine /app
COPY ./configuration/${SC_VERSION} /configuration
ENTRYPOINT ["powershell", "./utilities/Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data", "-Expression", "/app/Sitecore.ProcessingEngine.exe"]