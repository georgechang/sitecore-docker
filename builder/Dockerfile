ARG WIN_VERSION
FROM powershell:nanoserver-${WIN_VERSION}
ARG SC_PATH
ARG XC_PATH
ARG SI_PATH
ARG CONFIGURATION_PATH
COPY ./utilities /utilities
COPY ./logmonitor/LogMonitor.exe /logmonitor/LogMonitor.exe
COPY ${CONFIGURATION_PATH} /configuration
COPY ${SC_PATH} /resources/sitecore
COPY ${XC_PATH} /resources/xconnect
COPY ${SI_PATH} /resources/identity