ARG WINVERSION
ARG SCVERSION
FROM scbase-netframework:${WINVERSION}
COPY ./application/xconnect.maengine/configuration /configuration
COPY ./resources/xconnect/Website/App_Data/jobs/continuous/AutomationEngine /app
WORKDIR /configuration
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data", "-Expression", "/app/maengine.exe"]