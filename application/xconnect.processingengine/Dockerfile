FROM scbase:netframework
COPY ./application/xconnect.processingengine/configuration /configuration
COPY ./resources/xconnect/Website/App_Data/jobs/continuous/ProcessingEngine /app
#COPY ./resources/license.xml /app/App_Data/license.xml
#USER ContainerAdministrator
WORKDIR /configuration
#RUN certoc.exe -ImportPFX -p secret root cert.pfx
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data", "-Expression", "/app/Sitecore.ProcessingEngine.exe"]