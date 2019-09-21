FROM scbase:netframework
COPY ./application/xconnect.maengine/configuration /configuration
COPY ./resources/xconnect/Website/App_Data/jobs/continuous/AutomationEngine /app
COPY ./resources/license.xml /app/App_Data/license.xml
WORKDIR /configuration
USER ContainerAdministrator
RUN certoc.exe -ImportPFX -p secret root cert.pfx
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-Expression", "/app/maengine.exe"]