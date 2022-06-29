# If you're having a problem with the SCOM web catalog, the following PowerShell should fix it for you.
#


$NetRegistryPath = “HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v2.0.50727”
New-ItemProperty -Path $NetRegistryPath -Name “SchUseStrongCrypto” -Value “1” -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $NetRegistryPath -Name “SystemDefaultTlsVersions” -Value “1” -PropertyType DWORD -Force | Out-Null

$NetRegistryPath = “HKLM:\SOFTWARE\WOW6432Node\Microsoft\.NETFramework\v4.0.30319”
New-ItemProperty -Path $NetRegistryPath -Name “SchUseStrongCrypto” -Value “1” -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $NetRegistryPath -Name “SystemDefaultTlsVersions” -Value “1” -PropertyType DWORD -Force | Out-Null

$NetRegistryPath = “HKLM:\SOFTWARE\Microsoft\.NETFramework\v2.0.50727”
New-ItemProperty -Path $NetRegistryPath -Name “SchUseStrongCrypto” -Value “1” -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $NetRegistryPath -Name “SystemDefaultTlsVersions” -Value “1” -PropertyType DWORD -Force | Out-Null

$NetRegistryPath = “HKLM:\SOFTWARE\Microsoft\.NETFramework\v4.0.30319”
New-ItemProperty -Path $NetRegistryPath -Name “SchUseStrongCrypto” -Value “1” -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path $NetRegistryPath -Name “SystemDefaultTlsVersions” -Value “1” -PropertyType DWORD -Force | Out-Null
