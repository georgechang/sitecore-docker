if (Test-Path /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSL.xml) {
	Rename-Item /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSL.xml -NewName sc.XConnect.Security.EnforceSSL.xml.disabled
}
if (Test-Path /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSLWithCertificateValidation.xml) {
	Rename-Item /inetpub/wwwroot/App_Data/Config/Sitecore/CoreServices/sc.XConnect.Security.EnforceSSLWithCertificateValidation.xml -NewName sc.XConnect.Security.EnforceSSLWithCertificateValidation.xml.disabled
}