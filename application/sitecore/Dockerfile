FROM scbase:aspnet

RUN Invoke-WebRequest https://aka.ms/vs/16/release/vc_redist.x64.exe -Outfile C:\vc_redist.x64.exe
RUN C:\vc_redist.x64.exe /install /passive /norestart

COPY ./application/sitecore/configuration /configuration
COPY ./resources/sitecore/Website /inetpub/wwwroot
COPY ./resources/license.xml /inetpub/wwwroot/App_Data/license.xml
RUN mkdir C:\inetpub\wwwroot\upload
USER ContainerAdministrator
RUN icacls 'C:\inetpub\wwwroot' /grant 'IIS_IUSRS:(OI)(CI)F' /T

WORKDIR /configuration
# RUN certoc.exe -ImportPFX -p secret root cert.pfx
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/inetpub/wwwroot", "-Expression", "\"C:\\ServiceMonitor.exe w3svc\""]