ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
FROM mcr.microsoft.com/windows/servercore:${WIN_VERSION}
COPY --from=builder ./resources /resources
COPY ./configuration/${SC_VERSION} /configuration
COPY ./scripts /scripts
ENV SC_VERSION=${SC_VERSION}
RUN setx /m PATH "%PATH%;C:\Program Files\Microsoft SQL Server\Client SDK\ODBC\170\Tools\Binn;C:\utilities\sqlpackage;"
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN New-Item /utilities -ItemType Directory | Out-Null
# Visual C++ 2017
RUN Invoke-WebRequest https://aka.ms/vs/16/release/vc_redist.x64.exe -OutFile /utilities/vc2017redist_x64.exe; \
	Start-Process -FilePath C:\utilities\vc2017redist_x64.exe -ArgumentList '/q' -NoNewWindow -Wait; \
	Remove-Item -Path /utilities/vc2017redist_x64.exe;
# ODBC driver
RUN Invoke-WebRequest https://download.microsoft.com/download/E/6/B/E6BFDC7A-5BCD-4C51-9912-635646DA801E/en-US/17.5.2.1/x64/msodbcsql.msi -OutFile /utilities/odbc.msi; \
	Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\utilities\odbc.msi /quiet IACCEPTMSODBCSQLLICENSETERMS=YES' -NoNewWindow -Wait; \
	Remove-Item -Path /utilities/odbc.msi;
# sqlcmd
RUN Invoke-WebRequest https://go.microsoft.com/fwlink/?linkid=2082790 -OutFile /utilities/sqlcmd.msi; \
	Start-Process -FilePath msiexec.exe -ArgumentList '/i C:\utilities\sqlcmd.msi /quiet IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES' -NoNewWindow -Wait; \
	Remove-Item -Path /utilities/sqlcmd.msi;
# sqlpackage
RUN Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2128143 -OutFile /utilities/sqlpackage.zip; \
	Expand-Archive -Path /utilities/sqlpackage.zip -DestinationPath /utilities/sqlpackage; \
	Remove-Item -Path /utilities/sqlpackage.zip;
# SHELL ["cmd", "/S", "/C"]
CMD [ "powershell" ]