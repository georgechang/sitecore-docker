ARG WIN_VERSION

FROM mcr.microsoft.com/powershell:windowsservercore-${WIN_VERSION} AS stage

# Download Links:
ARG EXE=https://go.microsoft.com/fwlink/?linkid=840945
ARG BOX=https://go.microsoft.com/fwlink/?linkid=840944
ARG CU

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -Uri $env:box -OutFile SQL.box ; \
  Invoke-WebRequest -Uri $env:exe -OutFile SQL.exe ; \
  #Invoke-WebRequest -Uri $env:cu -OutFile CU.exe ; \
  Start-Process -Wait -FilePath .\SQL.exe -ArgumentList /q, /x:setup ;
#Start-Process -Wait -FilePath .\CU.exe -ArgumentList /q, /X:cu;

FROM mcr.microsoft.com/powershell:windowsservercore-${WIN_VERSION}
COPY --from=stage ./setup /setup
#COPY --from=stage ./cu /cu

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN     .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=MSSQLSERVER /FEATURES=SQLEngine /UPDATEENABLED=0 /SQLUSERDBDIR='C:\Data' /SQLUSERDBLOGDIR='C:\Data' /SQLBACKUPDIR='C:\Backup' /SQLSVCACCOUNT='NT AUTHORITY\NETWORK SERVICE' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
  #.\cu\setup.exe /q /IAcceptSQLServerLicenseTerms /Action=Patch /InstanceName=MSSQLSERVER; \
  Stop-Service MSSQLSERVER ; \
  Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
  Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
  Set-ItemProperty -Path 'HKLM:\software\microsoft\microsoft sql server\mssql14.MSSQLSERVER\mssqlserver\' -name LoginMode -value 2 ;

COPY ./Start.ps1 /

ENV SA_PASSWORD="_"
ENV ATTACH_DBS="[]"
ENV ACCEPT_EULA="_"

HEALTHCHECK CMD [ "sqlcmd", "-Q", "select 1" ]
CMD .\Start.ps1 -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose