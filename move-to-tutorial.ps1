# Move Non-Codebase Files to Tutorial Directory
# Version: 1.0.0
# Date: 2025-10-05

# Configuration
$sourceBase = "C:\Users\skrlo\Documents\GitHub\to-go-agent-tutorial-recycling"
$targetBase = "C:\Users\skrlo\Documents\Tutorial\to-go-agent-tutorial-recycling"

# Color output functions
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

Write-Info "==========================================="
Write-Info "  Move Non-Codebase Files to Tutorial"
Write-Info "==========================================="
Write-Info ""

# Verify source directory exists
if (-not (Test-Path $sourceBase)) {
    Write-Error "Source directory not found: $sourceBase"
    exit 1
}

# Create target base directory if it doesn't exist
if (-not (Test-Path $targetBase)) {
    Write-Info "Creating target directory: $targetBase"
    New-Item -ItemType Directory -Path $targetBase -Force | Out-Null
}

# Create target subdirectories
$targetDirs = @(
    "data\input",
    "data\1-extract",
    "data\2-inventory",
    "data\3-normalize",
    "data\4-configure",
    "data\5-generate",
    "temp\archive",
    "temp\logs",
    "temp\prompts",
    "temp\scratch"
)

Write-Info "Creating target directory structure..."
foreach ($dir in $targetDirs) {
    $fullPath = Join-Path $targetBase $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Success "  Created: $dir"
    }
}

Write-Info ""

# Move data/ files
Write-Info "Moving data/ files..."
$dataSource = Join-Path $sourceBase "data"
$dataTarget = Join-Path $targetBase "data"

# Move input files
$inputSource = Join-Path $dataSource "input"
if (Test-Path $inputSource) {
    $inputFiles = Get-ChildItem -Path $inputSource -File
    if ($inputFiles.Count -gt 0) {
        foreach ($file in $inputFiles) {
            $targetPath = Join-Path $dataTarget "input\$($file.Name)"
            Move-Item -Path $file.FullName -Destination $targetPath -Force
            Write-Success "  Moved: data\input\$($file.Name)"
        }
    } else {
        Write-Warning "  No files in data\input\"
    }
}

# Move stage output files (1-5)
for ($i = 1; $i -le 5; $i++) {
    $stageDirs = @(
        "$i-extract",
        "$i-inventory", 
        "$i-normalize",
        "$i-configure",
        "$i-generate"
    )
    
    foreach ($stageDir in $stageDirs) {
        $stageSource = Join-Path $dataSource $stageDir
        if (Test-Path $stageSource) {
            $stageFiles = Get-ChildItem -Path $stageSource -File
            if ($stageFiles.Count -gt 0) {
                foreach ($file in $stageFiles) {
                    $targetPath = Join-Path $dataTarget "$stageDir\$($file.Name)"
                    Move-Item -Path $file.FullName -Destination $targetPath -Force
                    Write-Success "  Moved: data\$stageDir\$($file.Name)"
                }
            }
        }
    }
}

# Move profile.json if exists
$profileSource = Join-Path $dataSource "profile.json"
if (Test-Path $profileSource) {
    $profileTarget = Join-Path $dataTarget "profile.json"
    Move-Item -Path $profileSource -Destination $profileTarget -Force
    Write-Success "  Moved: data\profile.json"
}

# Move task-tracker files
$trackerFiles = Get-ChildItem -Path $dataSource -Filter "task-tracker*.json" -File
if ($trackerFiles.Count -gt 0) {
    foreach ($file in $trackerFiles) {
        $targetPath = Join-Path $dataTarget $file.Name
        Move-Item -Path $file.FullName -Destination $targetPath -Force
        Write-Success "  Moved: data\$($file.Name)"
    }
}

Write-Info ""

# Move temp/ files
Write-Info "Moving temp/ files..."
$tempSource = Join-Path $sourceBase "temp"
$tempTarget = Join-Path $targetBase "temp"

# Move archive files and directories
$archiveSource = Join-Path $tempSource "archive"
if (Test-Path $archiveSource) {
    $archiveItems = Get-ChildItem -Path $archiveSource -Exclude ".gitkeep"
    if ($archiveItems.Count -gt 0) {
        foreach ($item in $archiveItems) {
            $targetPath = Join-Path $tempTarget "archive\$($item.Name)"
            Move-Item -Path $item.FullName -Destination $targetPath -Force -Recurse
            if ($item.PSIsContainer) {
                Write-Success "  Moved: temp\archive\$($item.Name)\ (directory)"
            } else {
                Write-Success "  Moved: temp\archive\$($item.Name)"
            }
        }
    } else {
        Write-Warning "  No files in temp\archive\"
    }
}

# Move log files
$logsSource = Join-Path $tempSource "logs"
if (Test-Path $logsSource) {
    $logFiles = Get-ChildItem -Path $logsSource -File -Exclude ".gitkeep"
    if ($logFiles.Count -gt 0) {
        foreach ($file in $logFiles) {
            $targetPath = Join-Path $tempTarget "logs\$($file.Name)"
            Move-Item -Path $file.FullName -Destination $targetPath -Force
            Write-Success "  Moved: temp\logs\$($file.Name)"
        }
    } else {
        Write-Warning "  No files in temp\logs\"
    }
}

# Move prompt files
$promptsSource = Join-Path $tempSource "prompts"
if (Test-Path $promptsSource) {
    $promptFiles = Get-ChildItem -Path $promptsSource -File -Exclude ".gitkeep"
    if ($promptFiles.Count -gt 0) {
        foreach ($file in $promptFiles) {
            $targetPath = Join-Path $tempTarget "prompts\$($file.Name)"
            Move-Item -Path $file.FullName -Destination $targetPath -Force
            Write-Success "  Moved: temp\prompts\$($file.Name)"
        }
    } else {
        Write-Warning "  No files in temp\prompts\"
    }
}

# Move scratch files
$scratchSource = Join-Path $tempSource "scratch"
if (Test-Path $scratchSource) {
    $scratchItems = Get-ChildItem -Path $scratchSource -Exclude ".gitkeep"
    if ($scratchItems.Count -gt 0) {
        foreach ($item in $scratchItems) {
            $targetPath = Join-Path $tempTarget "scratch\$($item.Name)"
            Move-Item -Path $item.FullName -Destination $targetPath -Force -Recurse
            if ($item.PSIsContainer) {
                Write-Success "  Moved: temp\scratch\$($item.Name)\ (directory)"
            } else {
                Write-Success "  Moved: temp\scratch\$($item.Name)"
            }
        }
    } else {
        Write-Warning "  No files in temp\scratch\"
    }
}

Write-Info ""
Write-Info "==========================================="
Write-Success "Migration completed successfully!"
Write-Info "==========================================="
Write-Info ""
Write-Info "Files moved to: $targetBase"
Write-Info ""
Write-Info "IMPORTANT: Repository structure preserved:"
Write-Info "  - definitions/ (unchanged - codebase)"
Write-Info "  - docs/ (unchanged - codebase)"
Write-Info "  - data/ (only .gitkeep remains)"
Write-Info "  - temp/ (only .gitkeep remains)"
Write-Info "  - README.md, LICENSE, etc. (unchanged)"
Write-Info ""
Write-Warning "Next steps:"
Write-Info "  1. Verify files in tutorial directory"
Write-Info "  2. Test pipeline with tutorial data"
Write-Info "  3. Keep codebase clean for development"
Write-Info ""
