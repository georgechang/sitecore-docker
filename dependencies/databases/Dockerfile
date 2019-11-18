ARG WIN_VERSION
FROM common:${WIN_VERSION}
COPY ./scripts /scripts
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -Uri https://go.microsoft.com/fwlink/?linkid=2108813 -OutFile DAC.msi ; \
	Start-Process msiexec.exe -ArgumentList '/I C:\DAC.msi /quiet' -Wait; \
	[Environment]::SetEnvironmentVariable('Path', [Environment]::GetEnvironmentVariable('Path', [EnvironmentVariableTarget]::Machine) + 'C:\Program Files\Microsoft SQL Server\150\DAC\bin', [EnvironmentVariableTarget]::Machine)
RUN Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; Install-Module SqlServer -Force; Install-Module mashups -Force
RUN /scripts/Install-ScDatabases.ps1
ENTRYPOINT [ "pwsh" ]