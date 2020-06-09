if ($env:SC_INSTALL) {
	Import-Module /scripts/Modules/SitecoreDatabaseTools/SitecoreDatabaseTools.psm1
	Install-XConnectDatabases
	Install-SitecoreDatabases -Version $env:SC_VERSION
	Install-SitecoreSolrCores -Version $env:SC_VERSION
}