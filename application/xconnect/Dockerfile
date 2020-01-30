ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-${WIN_VERSION}
ARG CONFIGURATION
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator
RUN Invoke-WebRequest https://aka.ms/vs/16/release/vc_redist.x64.exe -Outfile C:\vc_redist.x64.exe; \
	C:\vc_redist.x64.exe /install /passive /norestart ; \
	Enable-LocalUser Administrator; \
	SecEdit.exe /export /cfg secpol.cfg; \
	(Get-Content secpol.cfg).Replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | \
	Out-File secpol.cfg; \
	SecEdit.exe /configure /db C:\Windows\Security\Local.sdb /cfg secpol.cfg /areas SECURITYPOLICY; \
	Remove-Item secpol.cfg; \
	Set-LocalUser Administrator -Password (New-Object SecureString); \
	Add-LocalGroupMember -Group 'Performance Monitor Users' -Member 'User Manager\ContainerAdministrator', 'IIS APPPOOL\DefaultAppPool' -ErrorAction SilentlyContinue; \
	Add-LocalGroupMember -Group 'Performance Log Users' -Member 'User Manager\ContainerAdministrator', 'IIS APPPOOL\DefaultAppPool' -ErrorAction SilentlyContinue; \
	icacls 'C:\inetpub\wwwroot' /grant 'IIS_IUSRS:(OI)(CI)F' /T; \
	Set-Service -Name w3svc -StartupType 'Manual'
COPY --from=builder ./utilities /utilities
COPY --from=builder ./resources/xconnect/Content/Website /inetpub/wwwroot
COPY ${CONFIGURATION} /configuration
RUN Rename-Item /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSL.xml -NewName sc.XConnect.Security.EnforceSSL.xml.disabled ; \
	Rename-Item /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSLWithCertificateValidation.xml -NewName sc.XConnect.Security.EnforceSSLWithCertificateValidation.xml.disabled
EXPOSE 80
ENTRYPOINT ["powershell", "./utilities/Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data"]
