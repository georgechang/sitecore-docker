ARG WINVERSION
ARG SCVERSION
FROM scbase-aspnet:${WINVERSION}-${SCVERSION}
COPY ./application/xconnect/configuration /configuration
COPY ./resources/xconnect/Website /inetpub/wwwroot
WORKDIR /configuration
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]
