ARG WIN_VERSION
FROM mcr.microsoft.com/windows/servercore:${WIN_VERSION}
ARG MSSQL_PATH

COPY ${MSSQL_PATH} /resources/mssql
COPY ./configuration /configuration
ENV SA_PASSWORD="_"
ENV ATTACH_DBS="[]"
ENV ACCEPT_EULA="_"
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
ARG MSSQL_BUILD
RUN /resources/mssql/setup.exe /Q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLUSERDBDIR='C:\Data' /SQLUSERDBLOGDIR='C:\Data' /SQLBACKUPDIR='C:\Backup' /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS; \
  Stop-Service MSSQLSERVER ; \
  Set-ItemProperty -Path ('HKLM:\software\microsoft\microsoft sql server\mssql{0}.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -f $env:MSSQL_BUILD) -name tcpdynamicports -value '' ; \
  Set-ItemProperty -Path ('HKLM:\software\microsoft\microsoft sql server\mssql{0}.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -f $env:MSSQL_BUILD) -name tcpport -value 1433 ; \
  Set-ItemProperty -Path ('HKLM:\software\microsoft\microsoft sql server\mssql{0}.MSSQLSERVER\mssqlserver' -f $env:MSSQL_BUILD) -name LoginMode -value 2 ;

HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
CMD .\configuration\Startup.ps1 -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose