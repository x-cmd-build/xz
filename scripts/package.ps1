# Package xz for Windows: zip archive containing bin/xz.exe + LICENSE +
# NOTICE.md + README.md + README.cn.md.
#
# Used by release.yml on windows-latest after MSYS build.
$ErrorActionPreference = 'Stop'

$root    = (Resolve-Path "$PSScriptRoot/..").Path
$target  = $env:TARGET
if (-not $target) { throw 'TARGET env var required (e.g. windows-x64)' }

$srcBin  = Join-Path $root 'build/src/xz/.libs/xz.exe'
if (-not (Test-Path $srcBin)) {
	$srcBin = Join-Path $root 'build/src/xz/xz.exe'
}
if (-not (Test-Path $srcBin)) { throw "missing: $srcBin" }

$outDir  = Join-Path $root "dist/xz-$target"
if (Test-Path $outDir) { Remove-Item -Recurse -Force $outDir }
$binDir  = Join-Path $outDir 'bin'
New-Item -ItemType Directory -Path $binDir -Force | Out-Null

Copy-Item $srcBin (Join-Path $binDir 'xz.exe')
Copy-Item (Join-Path $root 'LICENSE')     (Join-Path $outDir 'LICENSE')
Copy-Item (Join-Path $root 'NOTICE.md')   (Join-Path $outDir 'NOTICE.md')
Copy-Item (Join-Path $root 'README.md')   (Join-Path $outDir 'README.md')
Copy-Item (Join-Path $root 'README.cn.md') (Join-Path $outDir 'README.cn.md')

$zipPath = Join-Path $root "dist/xz-$target.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($outDir, $zipPath)

$hash = (Get-FileHash $zipPath -Algorithm SHA256).Hash.ToLower()
"$hash  $(Split-Path $zipPath -Leaf)" | Set-Content -Encoding ascii (Join-Path $root "dist/xz-$target.zip.sha256")

Write-Output "==> packaged:"
Get-ChildItem $zipPath | Format-Table Name, Length
Get-Content (Join-Path $root "dist/xz-$target.zip.sha256")