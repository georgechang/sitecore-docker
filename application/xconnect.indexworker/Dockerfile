FROM scbase:netframework
COPY ./application/xconnect.indexworker/configuration /configuration
COPY ./resources/xconnect/Website/App_Data/jobs/continuous/IndexWorker /app
#COPY ./resources/license.xml /app/App_Data/license.xml
WORKDIR /configuration
#ENTRYPOINT ["XConnectSearchIndexer.exe"]
ENTRYPOINT ["powershell", "./Bootstrapper.ps1", "-Path", "configuration.json", "-AppPath", "/app", "-LicensePath", "/app/App_Data", "-Expression", "/app/XConnectSearchIndexer.exe"]