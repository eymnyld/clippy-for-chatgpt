param([switch]$Force)
$ErrorActionPreference = "Stop"

$PluginDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$SourceDir = Join-Path $PluginDir "assets/pet/clippy"
$CodexRoot = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
$TargetDir = Join-Path $CodexRoot "pets/clippy"
$ExpectedSprite = "96b04a0a1a82060e663a3b17c914630d47f66b6f80dad425a6c0f5c67c642ea5"
$ExpectedPet = "e18f38295dba206ba9cb69afdd462d472c8e0787ad38dc302bf02c2371c4b88a"

function Assert-Hash([string]$Path, [string]$Expected) {
  $Actual = (Get-FileHash -Algorithm SHA256 -Path $Path).Hash.ToLowerInvariant()
  if ($Actual -ne $Expected) { throw "Checksum mismatch: $Path" }
}

$SourceSprite = Join-Path $SourceDir "spritesheet.webp"
$SourcePet = Join-Path $SourceDir "pet.json"
Assert-Hash $SourceSprite $ExpectedSprite
Assert-Hash $SourcePet $ExpectedPet

$TargetSprite = Join-Path $TargetDir "spritesheet.webp"
$TargetPet = Join-Path $TargetDir "pet.json"
if ((Test-Path $TargetSprite) -and (Test-Path $TargetPet)) {
  $SameSprite = (Get-FileHash $TargetSprite).Hash -eq (Get-FileHash $SourceSprite).Hash
  $SamePet = (Get-FileHash $TargetPet).Hash -eq (Get-FileHash $SourcePet).Hash
  if ($SameSprite -and $SamePet) {
    Write-Output "Clippy is already installed and verified at $TargetDir"
    exit 0
  }
}

if (((Test-Path $TargetSprite) -or (Test-Path $TargetPet)) -and -not $Force) {
  throw "A different Clippy package exists at $TargetDir. Re-run with -Force only after approving replacement."
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
$TempSprite = Join-Path $TargetDir ".spritesheet.webp.$PID.tmp"
$TempPet = Join-Path $TargetDir ".pet.json.$PID.tmp"
try {
  Copy-Item $SourceSprite $TempSprite -Force
  Copy-Item $SourcePet $TempPet -Force
  Assert-Hash $TempSprite $ExpectedSprite
  Assert-Hash $TempPet $ExpectedPet
  Move-Item $TempSprite $TargetSprite -Force
  Move-Item $TempPet $TargetPet -Force
} finally {
  Remove-Item $TempSprite, $TempPet -Force -ErrorAction SilentlyContinue
}

Assert-Hash $TargetSprite $ExpectedSprite
Assert-Hash $TargetPet $ExpectedPet
Write-Output "Installed and verified Clippy at $TargetDir"
