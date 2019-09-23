FROM scbase:aspnet
COPY ./application/sitecore/configuration /configuration
COPY ./resources/sitecore/Website /inetpub/wwwroot
# COPY ./resources/license.xml /inetpub/wwwroot/App_Data/license.xml
#RUN mkdir C:\inetpub\wwwroot\upload


WORKDIR /configuration
# RUN certoc.exe -ImportPFX -p secret root cert.pfx
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/inetpub/wwwroot", "-LicensePath", "/inetpub/wwwroot/App_Data", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]