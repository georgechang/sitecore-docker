ARG WINVERSION
ARG SCVERSION
FROM scbase-netframework:${WINVERSION}-${SCVERSION}
COPY ./application/xconnect.processingengine/configuration /configuration
COPY ./resources/xconnect/Website/App_Data/jobs/continuous/ProcessingEngine /app
WORKDIR /configuration
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data", "-Expression", "/app/Sitecore.ProcessingEngine.exe"]