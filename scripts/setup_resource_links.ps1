param(
  [string]$RepoRoot = (Split-Path -Parent $PSCommandPath)
)

$ErrorActionPreference = 'Stop'

# Paths
$libSrc = Join-Path $RepoRoot 'external\library-matlab\src'

# Map of repo-relative link -> library-relative target
$links = @(
  @{ Link = '+UserInterface\Resources'; Target = '+UserInterface\Resources' },
  @{ Link = '+SimViewer\Resources';     Target = '+SimViewer\Resources' },
  @{ Link = '+Utilities\Resources';     Target = '+Utilities\Resources' },
  @{ Link = 'imgs';                      Target = 'imgs' }
)

function Ensure-Junction {
  param([string]$linkPath, [string]$targetPath)
  if(Test-Path -LiteralPath $linkPath){
    try {
      $item = Get-Item -LiteralPath $linkPath
      $attrs = $item.Attributes
      if($attrs.ToString() -match 'ReparsePoint'){
        return
      } else {
        # If directory exists and is empty, replace with junction; else skip
        $entries = Get-ChildItem -LiteralPath $linkPath -Force -ErrorAction SilentlyContinue
        if(-not $entries){
          Remove-Item -LiteralPath $linkPath -Force
        } else {
          Write-Host "Exists (not a junction, not empty), skipping: $linkPath"
          return
        }
      }
    } catch {}
  }
  $parent = Split-Path -Parent $linkPath
  if($parent){ New-Item -ItemType Directory -Path $parent -Force | Out-Null }
  New-Item -ItemType Junction -Path $linkPath -Target $targetPath | Out-Null
}

foreach($m in $links){
  $linkAbs   = Join-Path $RepoRoot $m.Link
  $targetAbs = Join-Path $libSrc   $m.Target
  if(Test-Path -LiteralPath $targetAbs){
    Ensure-Junction -linkPath $linkAbs -targetPath $targetAbs
  } else {
    Write-Host "Target missing in library, skipping link: $($m.Target)"
  }
}

Write-Output "Resource junctions ensured under $RepoRoot pointing to $libSrc"