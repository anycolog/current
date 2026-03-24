param(
  [string]$ProjectId,
  [string]$ProjectRoot,
  [string]$CursorProjectsRoot = "$env:USERPROFILE\.cursor\projects",
  [string]$InDir = (Join-Path $PSScriptRoot "..\chat-history")
)

$ErrorActionPreference = 'Stop'

function Resolve-ProjectFolder {
  param(
    [string]$ProjectId,
    [string]$ProjectRoot,
    [string]$CursorProjectsRoot
  )

  if ($ProjectId) {
    $p = Join-Path $CursorProjectsRoot $ProjectId
    if (Test-Path -LiteralPath $p) { return $p }
    throw "ProjectId not found: $ProjectId"
  }

  if ($ProjectRoot) {
    $needle = (Resolve-Path -LiteralPath $ProjectRoot).Path.ToLowerInvariant()
    $candidates = Get-ChildItem -LiteralPath $CursorProjectsRoot -Directory
    foreach ($c in $candidates) {
      if ($c.Name.ToLowerInvariant().Contains($needle.Replace(':','').Replace('\\','-').Replace('/','-'))) {
        return $c.FullName
      }
    }
    throw "Could not map ProjectRoot to Cursor project folder: $ProjectRoot"
  }

  throw "Specify -ProjectId or -ProjectRoot"
}

if (-not (Test-Path -LiteralPath $InDir)) {
  throw "Input folder not found: $InDir"
}

$projectFolder = Resolve-ProjectFolder -ProjectId $ProjectId -ProjectRoot $ProjectRoot -CursorProjectsRoot $CursorProjectsRoot
$transcriptsRoot = Join-Path $projectFolder "agent-transcripts"
New-Item -ItemType Directory -Path $transcriptsRoot -Force | Out-Null

$files = Get-ChildItem -LiteralPath $InDir -File -Filter "*.jsonl"
$count = 0
foreach ($f in $files) {
  $id = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
  $dstDir = Join-Path $transcriptsRoot $id
  New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
  $dst = Join-Path $dstDir $f.Name
  Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
  $count++
}

Write-Output "Restored $count transcript file(s)"
Write-Output "Source: $(Resolve-Path -LiteralPath $InDir)"
Write-Output "Destination: $transcriptsRoot"
