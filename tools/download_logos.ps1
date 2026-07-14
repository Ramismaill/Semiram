# Downloads high-res square logos for all 20 companies from logo.dev
# Usage:  powershell -ExecutionPolicy Bypass -File tools\download_logos.ps1 -Token pk_YOUR_KEY
param([Parameter(Mandatory = $true)][string]$Token)

$domains = @(
    "tsmc.com", "asml.com", "nvidia.com", "amd.com", "intel.com",
    "samsung.com", "qualcomm.com", "mediatek.com", "arm.com", "broadcom.com",
    "micron.com", "skhynix.com", "gf.com", "smics.com", "ti.com",
    "analog.com", "marvell.com", "cadence.com", "synopsys.com", "latticesemi.com",
    "nxp.com", "infineon.com", "st.com", "appliedmaterials.com", "lamresearch.com",
    "kla.com", "tel.com", "renesas.com", "onsemi.com", "umc.com"
)

$outDir = Join-Path $PSScriptRoot "..\assets\logos"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$ok = 0; $fail = @()
foreach ($d in $domains) {
    $url = "https://img.logo.dev/$d`?token=$Token&size=256&format=png"
    $dest = Join-Path $outDir "$d.png"
    try {
        Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
        Write-Host "OK   $d" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "FAIL $d : $($_.Exception.Message)" -ForegroundColor Red
        $fail += $d
    }
}
Write-Host ""
Write-Host "Done: $ok/20 downloaded to assets\logos"
if ($fail.Count -gt 0) { Write-Host "Failed: $($fail -join ', ')" -ForegroundColor Yellow }
