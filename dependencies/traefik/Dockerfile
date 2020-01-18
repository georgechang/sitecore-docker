ARG WIN_VERSION
FROM common:${WIN_VERSION} as stage
ARG TRAEFIK_VERSION
RUN Invoke-WebRequest -Uri https://github.com/containous/traefik/releases/download/v${TRAEFIK_VERSION}/traefik_v${TRAEFIK_VERSION}_windows_amd64.zip -OutFile /traefik.zip; \
	Expand-Archive -Path /traefik.zip -DestinationPath C:\traefik -Force; \
	Remove-Item /traefik.zip -Force
SHELL ["pwsh", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
FROM mcr.microsoft.com/windows/nanoserver:${WIN_VERSION}
COPY --from=stage ./traefik /traefik
EXPOSE 80
ENTRYPOINT ["/traefik"]