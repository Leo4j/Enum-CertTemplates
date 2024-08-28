function Enum-CertTemplates{
[CmdletBinding()] Param(
[Parameter (Mandatory=$False, ValueFromPipeline=$true)]
[String]
$Domain
)

$domainDistinguishedName = "DC=" + ($Domain -replace "\.", ",DC=")
$ldapConnection = New-Object System.DirectoryServices.DirectoryEntry
$ldapConnection.Path = "LDAP://CN=Certificate Templates,CN=Public Key Services,CN=Services,CN=Configuration,$domainDistinguishedName"
$ldapConnection.AuthenticationType = "None"

$searcher = New-Object System.DirectoryServices.DirectorySearcher
$searcher.SearchRoot = $ldapConnection
$searcher.Filter = "(objectClass=pKICertificateTemplate)"
$searcher.SearchScope = "Subtree"

$results = $searcher.FindAll()

$AllTemplates = foreach ($result in $results) {
	$templateName = $result.Properties["name"][0]
	$templateName
}

Write-Output ""
Write-Output "[+] Certificate Templates:"
Write-Output ""

$AllTemplates | Sort

Write-Output ""
Write-Output "[+] Certificates that permit client authentication:"
Write-Output ""

$searcher.Filter = "(&(objectClass=pKICertificateTemplate)(pkiExtendedKeyUsage=1.3.6.1.5.5.7.3.2))"
$searcher.SearchScope = "Subtree"

$results = $searcher.FindAll()

$ClientAuthTemplates = foreach ($result in $results) {
	if($result.Properties["pkiextendedkeyusage"] -contains "1.3.6.1.5.5.7.3.2") {
		$templateName = $result.Properties["name"][0]
		$templateName
	}
}

$ClientAuthTemplates | Sort

# Dispose resources
$results.Dispose()
$searcher.Dispose()
$ldapConnection.Dispose()
}
