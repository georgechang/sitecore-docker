FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8

# RUN Invoke-WebRequest https://download.microsoft.com/download/6/E/4/6E48E8AB-DC00-419E-9704-06DD46E5F81D/NDP472-KB4054530-x86-x64-AllOS-ENU.exe -OutFile C:\netfx-472.exe

# RUN C:\netfx-472.exe /q /norestart

COPY /base/common/configuration /configuration
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Enable-LocalUser Administrator; \
    SecEdit.exe /export /cfg secpol.cfg; \
    (Get-Content secpol.cfg).Replace('PasswordComplexity = 1', 'PasswordComplexity = 0') | \
    Out-File secpol.cfg; \
    SecEdit.exe /configure /db C:\Windows\Security\Local.sdb /cfg secpol.cfg /areas SECURITYPOLICY; \
    Remove-Item secpol.cfg; \
    Set-LocalUser Administrator -Password (New-Object SecureString)
ENTRYPOINT ["powershell"]