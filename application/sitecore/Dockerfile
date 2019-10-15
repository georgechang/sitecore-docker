ARG WINVERSION
ARG SCVERSION
FROM scbase-aspnet:${WINVERSION}
COPY ./application/sitecore/configuration /configuration
COPY ./resources/sitecore/Website /inetpub/wwwroot
WORKDIR /configuration
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]