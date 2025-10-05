# TEMP Directory Convention

Convention for organizing temporary files, logs, and ephemeral content.

---

## Purpose

The `temp/` directory is for:
- **Development artifacts** - Prompts, experiments
- **Debug logs** - Troubleshooting and diagnostic files
- **Archive** - Deprecated versions and backups
- **Session work** - Temporary working files

**NOT for:**
- Production data (use `data/`)
- Agent definitions (use `definitions/`)
- Documentation (use `docs/`)

---

## Directory Structure

```
temp/
├── README.md                          # This file
├── .gitkeep                           # Keep directory in git
├── archive/                           # Old versions, deprecated files
│   ├── .gitkeep
│   ├── YYYY-MM-DD_##_{description}.ext  ← Single files
│   └── YYYY-MM-DD_##_{description}/     ← Multiple related files
├── logs/                              # Debug and execution logs
│   ├── .gitkeep
│   └── YYYY-MM-DD_##_{type}.log
├── prompts/                           # Reusable prompts and workflows
│   ├── .gitkeep
│   └── YYYY-MM-DD_##_{topic}.md
└── scratch/                           # Temporary experiments
    ├── .gitkeep
    └── {any-structure}
```

---

## Naming Conventions

### Standard Pattern: `YYYY-MM-DD_##_{description}.{ext}`

**All files MUST follow this pattern:**

Correct:
```
2025-10-05_01_backup-definitions.zip
2025-10-05_02_feature-ideas.md
2025-10-05_03_session-log.log
2025-10-06_01_sprint-planning.md      # New day, counter resets to 01
```

Wrong:
```
2025-10-05_backup.zip                 # Missing counter
backup.zip                            # Missing date and counter
2025-10-05_1_backup.zip              # Counter must be 2 digits (01)
oct-5-2025_01_backup.zip             # Wrong date format
```

**Exception:** Files in `scratch/` directory (no rules apply)

### Counter Rules

- **Format:** Always 2 digits (01, 02, 03, ..., 99)
- **Reset:** Counter resets to 01 every day
- **Sequence:** Increment for each new file created on the same day
- **Per Directory:** Each subdirectory has its own counter sequence

**Examples:**
```
prompts/
├── 2025-10-05_01_project-audit.md
├── 2025-10-05_02_code-review.md
├── 2025-10-05_03_migration-plan.md
└── 2025-10-06_01_sprint-retro.md    # New day, reset to 01

logs/
├── 2025-10-05_01_debug-session.log
├── 2025-10-05_02_error-report.log
└── 2025-10-06_01_validation-run.log
```

---

## Orchestrator Integration

### Automatic File Placement

The orchestrator determines file placement based on content type:

**Decision Rules:**

```javascript
function getTargetDirectory(content, fileType) {
  // Logs: Contains stack traces, error codes, debug output
  if (containsLogPatterns(content)) {
    return "temp/logs/";
  }
  
  // Prompts: Contains prompt instructions, workflows
  if (containsPromptMarkers(content)) {
    return "temp/prompts/";
  }
  
  // Archive: Old versions, deprecated files, backups
  if (isArchiveContent(fileType, content)) {
    return "temp/archive/";
  }
  
  // Default: When unsure, use scratch
  return "temp/scratch/";
}
```

### Classification Patterns

**Logs:** `temp/logs/YYYY-MM-DD_##_{type}.log`
- Contains: Stack traces, timestamps, error codes, DEBUG/INFO/ERROR markers
- Keywords: `error`, `exception`, `traceback`, `failed`, `timeout`
- Extensions: `.log`, `.trace`, `.debug`

**Prompts:** `temp/prompts/YYYY-MM-DD_##_{topic}.md`
- Contains: Prompt instructions, workflows, agent directives
- Keywords: `prompt`, `instruction`, `workflow`, `You are`, `Your task`
- Extensions: `.md`, `.txt`

**Archive:** `temp/archive/YYYY-MM-DD_##_{description}.{ext}` OR `temp/archive/YYYY-MM-DD_##_{description}/`
- Contains: Old versions, backups, deprecated code
- Keywords: `v1.0.0`, `backup`, `old`, `deprecated`, `archive`
- **Single file:** Place directly in archive/ with naming pattern
- **Multiple files:** Create subdirectory only when 2+ related files

**Scratch:** `temp/scratch/{anything}`
- Contains: Everything else, experiments, temporary tests
- No pattern matching needed
- No naming rules

### Filename Generation

```javascript
function generateFilename(targetDir, description, extension) {
  const date = getCurrentDate();        // YYYY-MM-DD
  const counter = getNextCounter(targetDir, date);  // 01, 02, 03...
  const sanitized = sanitizeDescription(description);
  
  return `${date}_${counter}_${sanitized}.${extension}`;
}

function getNextCounter(directory, date) {
  const files = listFiles(directory);
  const todayFiles = files.filter(f => f.startsWith(date));
  const counters = todayFiles.map(f => extractCounter(f));
  const maxCounter = Math.max(...counters, 0);
  
  return String(maxCounter + 1).padStart(2, '0');
}
```

---

## Directory Guidelines

### 1. `archive/`

**Purpose:** Deprecated files that might be needed for reference

**Organization:**
- **Single files:** Direct placement `YYYY-MM-DD_##_{description}.{ext}`
- **Multiple related files:** Subdirectory `YYYY-MM-DD_##_{description}/` (only if 2+ files)

**Decision Rule:** Create subdirectory ONLY when you have 2 or more related files that belong together.

**Examples:**
```
archive/
├── .gitkeep
├── 2025-10-05_01_old-prompt.md                    ← Single file
├── 2025-10-05_02_deprecated-config.json           ← Single file  
├── 2025-10-05_03_v1-agent-backups/                ← 8 related files
│   ├── agent-1-extract_v1.0.0.json
│   ├── agent-2-inventory_v1.0.0.json
│   └── ... (6 more agent files)
└── incomplete-session/                             ← 4 related files
    ├── step-1_extract_Input-1.json
    └── ... (3 more pipeline files)
```

**Anti-Pattern (DO NOT DO):**
```
❌ archive/2025-10-05_01_single-file/
    └── single-file.md              ← Unnecessary nesting

✅ archive/2025-10-05_01_single-file.md  ← Correct
```

---

### 2. `logs/`

**Purpose:** Debug logs, execution traces, error reports

**Naming:**
```
YYYY-MM-DD_##_{type}.log
```

**Types:**
- `debug` - Detailed execution logs
- `error` - Error reports
- `session` - Session execution logs
- `validation` - Validation failures

**Examples:**
```
logs/
├── .gitkeep
├── 2025-10-05_01_debug-session-abc123.log
├── 2025-10-05_02_error-validation-failed.log
├── 2025-10-05_03_session-morning-run.log
└── 2025-10-06_01_validation-retry.log
```

---

### 3. `prompts/`

**Purpose:** Reusable prompts and workflow instructions

**Naming:**
```
YYYY-MM-DD_##_{topic}.md
```

**Examples:**
```
prompts/
├── .gitkeep
├── 2025-10-05_01_complete-project-audit.md
├── 2025-10-05_02_code-review-checklist.md
├── 2025-10-05_03_migration-workflow.md
└── 2025-10-06_01_agent-testing.md
```

**Guidelines:**
- Store reusable prompt templates
- Include usage instructions at top
- Version prompts when significantly changed
- Reference prompts in documentation when needed

---

### 4. `scratch/`

**Purpose:** Temporary experiments, quick tests, throwaway code

**Rules:** NONE - Anything goes

**Examples:**
```
scratch/
├── .gitkeep
├── test.json
├── quick-calc.py
├── experiment/
└── whatever.txt
```

**Guidelines:**
- No naming conventions required
- Delete freely and frequently
- Never reference from production code

---

## Git Integration

### Directory Structure in Git

Only directory structure is tracked:

```
temp/
├── README.md          # Committed
├── .gitkeep           # Committed
├── archive/
│   └── .gitkeep       # Committed
├── logs/
│   └── .gitkeep       # Committed
├── prompts/
│   └── .gitkeep       # Committed
└── scratch/
    └── .gitkeep       # Committed
```

### .gitignore Configuration

```gitignore
# Temp directory - only structure tracked
temp/*
!temp/.gitkeep
!temp/README.md
!temp/archive/
temp/archive/*
!temp/archive/.gitkeep
!temp/logs/
temp/logs/*
!temp/logs/.gitkeep
!temp/prompts/
temp/prompts/*
!temp/prompts/.gitkeep
!temp/scratch/
temp/scratch/*
!temp/scratch/.gitkeep
```

**Result:**
- Directory structure committed
- README and .gitkeep files committed
- All actual content ignored
- No retention management needed

---

## Usage Examples

### Creating Files Manually

```bash
# Get today's date
DATE=$(date +%Y-%m-%d)

# Find next counter for prompts
COUNTER=$(ls temp/prompts/${DATE}_* 2>/dev/null | wc -l | awk '{printf "%02d", $1+1}')

# Create prompt
touch temp/prompts/${DATE}_${COUNTER}_my-workflow.md
```

### Orchestrator Usage

```python
# Orchestrator automatically determines placement and naming
orchestrator.save_to_temp(
    content="Prompt instructions...",
    description="agent-testing",
    suggested_type="prompt"
)
# Creates: temp/prompts/2025-10-05_03_agent-testing.md
```

---

## Counter Management

### Finding Next Counter

```bash
# For a specific directory
get_next_counter() {
  local dir=$1
  local date=$(date +%Y-%m-%d)
  local max=$(ls ${dir}/${date}_* 2>/dev/null | 
              sed -n "s/.*${date}_\([0-9][0-9]\)_.*/\1/p" | 
              sort -n | 
              tail -1)
  
  if [ -z "$max" ]; then
    echo "01"
  else
    printf "%02d" $((10#$max + 1))
  fi
}

# Usage
COUNTER=$(get_next_counter "temp/prompts")
echo "temp/prompts/$(date +%Y-%m-%d)_${COUNTER}_my-prompt.md"
```

### Cross-Platform Compatibility

```python
import os
from datetime import datetime
from pathlib import Path

def get_next_counter(directory: str) -> str:
    """Get next counter for today in given directory."""
    date_str = datetime.now().strftime("%Y-%m-%d")
    pattern = f"{date_str}_*"
    
    files = list(Path(directory).glob(pattern))
    if not files:
        return "01"
    
    counters = []
    for f in files:
        parts = f.stem.split('_')
        if len(parts) >= 2 and parts[1].isdigit():
            counters.append(int(parts[1]))
    
    max_counter = max(counters) if counters else 0
    return f"{max_counter + 1:02d}"

# Usage
counter = get_next_counter("temp/prompts")
filename = f"temp/prompts/{datetime.now().strftime('%Y-%m-%d')}_{counter}_my-topic.md"
```

---

## Quick Reference

### File Naming Template

```
YYYY-MM-DD_##_{description}.{ext}

Where:
  YYYY-MM-DD = ISO 8601 date
  ##         = 2-digit counter (01-99)
  description = lowercase-with-hyphens
  ext        = file extension
```

### Directory Selection Guide

| Content Type | Directory | Example |
|--------------|-----------|---------|
| Error logs, debug output | `logs/` | `2025-10-05_01_error-trace.log` |
| Prompt templates, workflows | `prompts/` | `2025-10-05_01_audit-prompt.md` |
| Old versions, backups | `archive/` | `2025-10-05_01_pre-refactor/` |
| Quick tests, experiments | `scratch/` | `anything-goes.txt` |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.2.0 | 2025-10-05 | Replaced notes/ and drafts/ with prompts/ |
| 1.1.0 | 2025-10-05 | Added 2-digit counter, orchestrator integration, removed retention |
| 1.0.0 | 2025-10-05 | Initial convention created |

---

**Maintained by:** MINT-RESEARCH by NeoMINT GmbH  
**Last Updated:** 2025-10-05
