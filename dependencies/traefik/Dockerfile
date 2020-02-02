ARG WIN_VERSION
ARG SC_VERSION
FROM builder:${SC_VERSION}-${WIN_VERSION} as builder
ARG TRAEFIK_VERSION
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Invoke-WebRequest -Uri "https://github.com/containous/traefik/releases/download/v$($env:TRAEFIK_VERSION)/traefik_v$($env:TRAEFIK_VERSION)_windows_amd64.zip" -OutFile /traefik.zip; \
	Expand-Archive -Path /traefik.zip -DestinationPath C:\traefik -Force; \
	Remove-Item /traefik.zip -Force
FROM mcr.microsoft.com/windows/servercore:${WIN_VERSION}
COPY --from=builder ./traefik /traefik
COPY ./configuration/traefik.yml /traefik/traefik.yml
#ADD https://github.com/containous/traefik/releases/download/v1.7.20/traefik_windows-amd64.exe ./traefik/traefik.exe
USER ContainerAdministrator
EXPOSE 80
ENTRYPOINT ["/traefik/traefik.exe"]