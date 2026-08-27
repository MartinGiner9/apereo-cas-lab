[CmdletBinding()]
param(
    [string]$CasVersion = $(if ($env:CAS_VERSION) { $env:CAS_VERSION } else { '8.0.1.2' }),
    [string]$InitializrUrl = $(if ($env:CAS_INITIALIZR_URL) { $env:CAS_INITIALIZR_URL } else { 'https://getcas.apereo.org/starter.tgz' })
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$RootDir = Split-Path -Parent $PSScriptRoot
$TargetDir = Join-Path $RootDir 'cas-server/overlay'
$TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("apereo-cas-lab-" + [Guid]::NewGuid().ToString('N'))
$ArchivePath = Join-Path $TempDir 'cas-overlay.tgz'

try {
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null

    Get-ChildItem -Path $TargetDir -Force |
        Where-Object { $_.Name -ne '.gitkeep' } |
        Remove-Item -Recurse -Force

    Write-Host "Generating Apereo CAS $CasVersion overlay from $InitializrUrl..."

    $Body = @{
        type       = 'cas-overlay'
        baseDir    = 'overlay'
        casVersion = $CasVersion
    }

    Invoke-WebRequest -Uri $InitializrUrl -Method Post -Body $Body -OutFile $ArchivePath

    & tar -xzf $ArchivePath -C $TempDir
    if ($LASTEXITCODE -ne 0) {
        throw 'Unable to extract the CAS Initializr archive.'
    }

    $GeneratedDir = Join-Path $TempDir 'overlay'
    $GradleWrapper = Join-Path $GeneratedDir 'gradlew'
    $GradleProperties = Join-Path $GeneratedDir 'gradle.properties'

    if (-not (Test-Path $GradleWrapper) -or -not (Test-Path $GradleProperties)) {
        throw 'CAS Initializr did not return the expected overlay structure.'
    }

    Copy-Item -Path (Join-Path $GeneratedDir '*') -Destination $TargetDir -Recurse -Force
    New-Item -ItemType File -Path (Join-Path $TargetDir '.gitkeep') -Force | Out-Null

    Write-Host ''
    Write-Host "CAS overlay generated at: $TargetDir"
    Write-Host "CAS version: $CasVersion"
    Write-Host ''
    Write-Host 'The overlay is generated and intentionally ignored by Git.'
    Write-Host 'Project-owned CAS configuration lives in cas-server/config and cas-server/services.'
    Write-Host ''
    Write-Host 'Build modules: jdbc, json-service-registry, org.postgresql:postgresql'
}
finally {
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
}
