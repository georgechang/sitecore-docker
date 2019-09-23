FROM scbase:aspnet
COPY ./application/xconnect/configuration /configuration
COPY ./resources/xconnect/Website /inetpub/wwwroot
#COPY ./resources/license.xml /inetpub/wwwroot/App_Data/license.xml
WORKDIR /configuration
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]
