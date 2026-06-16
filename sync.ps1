$destPaths = @(
    "$env:USERPROFILE\.gemini\antigravity\skills",
    "$env:USERPROFILE\.gemini\config\skills"
)

foreach ($destPath in $destPaths) {
    if (!(Test-Path $destPath)) {
        New-Item -ItemType Directory -Force -Path $destPath
    }
}

$folders = @("default_rules", "grill_me", "po_pdf", "novel_translator", "tech_translator", "song_translator", "thai_tech_writer", "av_embedded_planner", "stm32_libopencm3_troubleshoot", "stm32_ll_cmake_dsp_troubleshoot")

foreach ($folder in $folders) {
    $src = Join-Path $PSScriptRoot $folder
    if (Test-Path $src) {
        foreach ($destPath in $destPaths) {
            $dest = Join-Path $destPath $folder
            Write-Host "Syncing $folder to $dest..."
            Copy-Item -Recurse -Force $src -Destination $destPath
        }
    }
}
Write-Host "Sync complete!"
