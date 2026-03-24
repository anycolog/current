param(
  [string]$ProjectId,
  [string]$ProjectRoot,
  [string]$CursorProjectsRoot = "$env:USERPROFILE\.cursor\projects",
  [string]$OutDir = (Join-Path $PSScriptRoot "..\chat-history")
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

$projectFolder = Resolve-ProjectFolder -ProjectId $ProjectId -ProjectRoot $ProjectRoot -CursorProjectsRoot $CursorProjectsRoot
$transcriptsRoot = Join-Path $projectFolder "agent-transcripts"
if (-not (Test-Path -LiteralPath $transcriptsRoot)) {
  throw "No agent-transcripts in: $projectFolder"
}

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$files = Get-ChildItem -LiteralPath $transcriptsRoot -Recurse -File -Filter "*.jsonl"
$count = 0
foreach ($f in $files) {
  $dst = Join-Path $OutDir $f.Name
  Copy-Item -LiteralPath $f.FullName -Destination $dst -Force
  $count++
}

Write-Output "Exported $count transcript file(s)"
Write-Output "Source: $transcriptsRoot"
Write-Output "Destination: $(Resolve-Path -LiteralPath $OutDir)"
