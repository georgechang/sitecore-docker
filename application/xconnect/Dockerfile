ARG WINVERSION
ARG SCVERSION
FROM scbase-aspnet:${WINVERSION}
COPY ./application/xconnect/init /init
COPY ./application/xconnect/configuration /configuration
COPY ./resources/xconnect/Website /inetpub/wwwroot
WORKDIR /utilities
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "/configuration/configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]
