# Pipeline Documentation

Complete guide to the 5-stage tutorial processing pipeline.

---

## Overview

The TO-GO Agent processes tutorials through 5 sequential stages, each with validation gates and quality checks. Files are processed **stage-by-stage** in batch mode.

---

## Processing Model: Stage-by-Stage

**v2.0 Architecture:**
```
All files → Stage 1 → USER GATE → All files → Stage 2 → USER GATE → ...
```

**Benefits:**
1. **Input Isolation** - Each file processed independently, no cross-contamination
2. **Quality Gates** - Review and approve after each stage
3. **Batch Efficiency** - Process many files without manual intervention per file
4. **Precise Debugging** - Failed stages are isolated, easy to diagnose
5. **Flexible Retry** - Retry only failed files without reprocessing successful ones

**vs. v1.0 (File-by-File):**
- v1.0: File 1 → all 5 stages → File 2 → all 5 stages
- v2.0: All files → Stage 1 → USER GATE → All files → Stage 2 → USER GATE

---

## Stage 1: Extract

**Purpose:** Parse source into atomic elements

**Input:**
- Location: `data/input/*.{md,html,pdf}`
- Format: Raw tutorial content

**Processing:**
- Every source element → exactly ONE chunk
- Extract imperative steps (Install, Configure, Run, etc.)
- Identify entities (tools, packages, files, datasets)
- Assign unique IDs and source references
- **NO interpretation** - pure parsing

**Output:**
- Location: `data/1-extract/{basename}_extract.json`
- Structure:
  ```json
  {
    "chunks": [
      {
        "id": "chunk_001",
        "kind": "paragraph|code|heading|table|image|callout",
        "content": "...",
        "source_line": 42
      }
    ],
    "steps": [
      {
        "id": "step_001",
        "ordinal": 1,
        "title": "Install Python",
        "action": "Install",
        "source_refs": ["chunk_003", "chunk_004"]
      }
    ],
    "entities": ["python", "pip", "venv"],
    "references": ["https://python.org"]
  }
  ```

**Validation:**
- All chunks have `id` and `kind`
- All steps have `id`, `ordinal`, `title`, `action`, `source_refs` (min 1)
- Code blocks 100% verbatim
- NO emojis, icons, ellipsis, TODO markers

---

## Stage 2: Inventory

**Purpose:** Build semantic indices and mappings

**Input:**
- Location: `data/1-extract/{basename}_extract.json`
- Structure: Extraction output

**Processing:**
- Create 5 category indices:
  - **entities** - All named things (tools, products, concepts)
  - **tools** - Executable programs (python, npm, git)
  - **files** - File paths and names
  - **commands** - Shell commands and scripts
  - **datasets** - Data files and resources
- Map chunks to steps (traceability)
- Deduplicate aliases (e.g., "python3" = "python")
- Sort alphabetically (case-insensitive)
- **NO restructuring** - pure indexing

**Output:**
- Location: `data/2-inventory/{basename}_inventory.json`
- Structure:
  ```json
  {
    "indices": {
      "entities": ["docker", "python", "tensorflow"],
      "tools": ["docker", "python", "pip"],
      "files": ["Dockerfile", "requirements.txt"],
      "commands": ["docker build", "pip install"],
      "datasets": []
    },
    "mappings": {
      "chunk_to_step": {
        "chunk_003": ["step_001"],
        "chunk_004": ["step_001", "step_002"]
      },
      "deduplications": {
        "python3": "python",
        "py": "python"
      }
    }
  }
  ```

**Validation:**
- All indices non-empty (or explicitly null)
- All items have source_refs
- Alphabetical sorting maintained

---

## Stage 3: Normalize

**Purpose:** Map to canonical skeleton structure

**Input:**
- Location: `data/2-inventory/{basename}_inventory.json`
- Structure: Inventory output

**Processing:**
- Apply fixed section order:
  1. overview
  2. prerequisites
  3. setup
  4. steps
  5. validation
  6. troubleshooting
  7. references
- All sections present (even if empty/null)
- Steps ordered by ordinal (ascending)
- Assign stable IDs (format: `s{:03d}`)
- **NO filtering** - all content included

**Output:**
- Location: `data/3-normalize/{basename}_normalize.json`
- Structure:
  ```json
  {
    "skeleton": {
      "overview": {
        "title": "...",
        "content": [...],
        "source_refs": [...]
      },
      "prerequisites": [...],
      "setup": [...],
      "steps": [
        {
          "id": "s001",
          "ordinal": 1,
          "title": "Install Python",
          "action": "Install",
          "content": [...],
          "source_refs": [...]
        }
      ],
      "validation": [...],
      "troubleshooting": [...],
      "references": [...]
    }
  }
  ```

**Validation:**
- All 7 sections present
- Steps ordered by ordinal
- Stable ID format maintained

---

## Stage 4: Configure

**Purpose:** Filter content by user profile

**Input:**
- Location: `data/3-normalize/{basename}_normalize.json`
- Optional: `data/profile.json`
- Structure: Normalized skeleton + user profile

**Processing:**
- Load user profile (OS, experience, hardware)
- Detect platform-specific content:
  - **Explicit tags:** `[linux]`, `[windows]`, `[macos]`, `[cpu]`, `[gpu]`
  - **Heuristics:** Keywords like "apt-get", "brew", "PowerShell"
- Filter steps and content:
  - **Match:** Include content matching profile
  - **Mismatch:** Exclude with documented reason
  - **Generic:** Include always
- Document ALL exclusions
- **NO generation** - pure filtering

**Profile Schema:**
```json
{
  "os": "linux|windows|macos|null",
  "experience": "beginner|intermediate|advanced|null",
  "hardware": "cpu|gpu|null",
  "language": "string|null"
}
```

**Output:**
- Location: `data/4-configure/{basename}_configure.json`
- Structure:
  ```json
  {
    "selected_content": {
      "skeleton": {...}  // Filtered skeleton
    },
    "exclusions": [
      {
        "item_id": "s003",
        "reason": "Windows-specific (profile.os=linux)",
        "content_preview": "Install using PowerShell..."
      }
    ]
  }
  ```

**Validation:**
- `selected_content` non-empty
- All exclusions documented with reasons
- Profile match logic correct

---

## Stage 5: Generate

**Purpose:** Emit final formatted outputs

**Input:**
- Location: `data/4-configure/{basename}_configure.json`
- Structure: Configured content

**Processing:**
- Generate `tutorial.md` (formatted Markdown)
- Generate `tutorial.json` (structured data mirror)
- Apply formatting rules:
  - Line endings: LF
  - Heading style: ATX (`#`, `##`, `###`)
  - Indentation: 2 spaces for lists
  - Code blocks: Fenced (```) with language
  - Steps: `## Step {N}: {heading}`
- Ensure contiguous step numbering (1..N)
- 100% code fidelity (verbatim from source)
- **NO content changes** - pure formatting

**Output:**
- Location: `data/5-generate/{basename}.md` and `{basename}.json`
- Markdown structure:
  ```markdown
  # Tutorial Title
  
  ## Overview
  ...
  
  ## Prerequisites
  ...
  
  ## Step 1: Install Dependencies
  ...
  
  ## Step 2: Configure Environment
  ...
  
  ## Validation
  ...
  
  ## Troubleshooting
  ...
  
  ## References
  ...
  ```

**Validation:**
- Both files present (MD and JSON)
- Markdown valid
- Steps numbered 1..N (contiguous)
- NO emojis, icons, trailing spaces
- LF line endings, UTF-8 encoding

---

## Quality Standards

All stages enforce these standards:

**Schema Conformance: 100%**
- Every output file must match its defined JSON schema exactly
- No deviations, no optional fields skipped

**Completeness: ≥98%**
- At least 98% of source content must be captured in outputs
- Missing content must be documented with uncertainty_note

**Fidelity: ≥99%**
- Text content must be 99% identical to source
- Code blocks and commands must be 100% verbatim

**Traceability: 100%**
- Every output element links back to source via `source_refs`
- Full audit trail from final output → original source

**Forbidden Patterns:**
- NO emojis or icons (ASCII only)
- NO ellipsis (`...`)
- NO TODO/TBD/FIXME markers
- NO speculation (maybe, perhaps, likely)

---

## User Gates

After each stage completes, the orchestrator:

1. **Reports status:**
   ```
   Stage 1 (Extract) complete:
   - 8 files succeeded
   - 2 files failed
   - Review outputs in data/1-extract/
   ```

2. **Waits for user decision:**
   - **APPROVE** - Continue to next stage
   - **REJECT** - Abort pipeline, write error report
   - **RETRY_FAILED** - Re-run only failed files

3. **Proceeds based on decision:**
   - Approved → Next stage begins
   - Rejected → Pipeline stops, logs written
   - Retry → Failed files re-queued, successful files unchanged

**Benefits:**
- Catch errors early (before later stages)
- Verify quality incrementally
- Control over pipeline progress
- Transparency into batch status

---

## Error Handling

**Per-File Retry:**
- Max 3 retries per file per stage
- Failed files don't block successful files
- Retry counter tracked in task-tracker

**Retry Conditions:**
- Schema validation failed
- Forbidden patterns detected
- Quality thresholds not met
- Token overflow (CONTINUATION_REQUIRED)

**No Retry Conditions:**
- Input contract violation (bad input data)
- Agent definition not found
- Structure integrity violation
- Critical system error

**On Abort:**
- Mark all in-flight tasks as ABORTED
- Write complete task-tracker to data/
- Generate error report in data/
- Optionally write debug logs to temp/

---

## Token Management

The pipeline allocates tokens as percentages of the model's context window:

| Stage | Allocation | Example (200K window) |
|-------|------------|----------------------|
| Extract | 30% | 60,000 tokens |
| Inventory | 20% | 40,000 tokens |
| Normalize | 20% | 40,000 tokens |
| Configure | 10% | 20,000 tokens |
| Generate | 40% | 80,000 tokens |
| **Total** | **120%** | **240,000 tokens** |

**Why 120%?**
- Agents run sequentially, not in parallel
- Overlap is acceptable
- Safety threshold at 85% prevents actual overflow

**To Adjust:**
- Edit `token_allocation_percent` in `agent.config_v2.0.1.json`
- Maintain total around 120% for balance
- Higher percentages for content-heavy stages (Extract, Generate)

**On Overflow:**
- Agent reports CONTINUATION_REQUIRED
- Pipeline retries (max 3x)
- If still failing, abort with error report

---

## Execution Tracking

All execution details logged to `data/task-tracker_session_{id}.json`:

```json
{
  "session_id": "session_20251005_143022_abc123",
  "pipeline_name": "Tutorial Processing Pipeline",
  "started_at": "2025-10-05T14:30:22Z",
  "completed_at": "2025-10-05T14:47:18Z",
  "status": "SUCCESS",
  "tasks": [
    {
      "task_id": "task_session_20251005_143022_abc123_1",
      "stage_id": 1,
      "agent_id": 1,
      "status": "VALIDATED",
      "input_file": "data/input/tutorial-1.md",
      "output_file": "data/1-extract/tutorial-1_extract.json",
      "retry_count": 0,
      "token_usage": 25000,
      "validation_result": {
        "decision": "ACCEPT",
        "checks": {
          "schema_valid": true,
          "patterns_clean": true,
          "completeness_met": true,
          "fidelity_met": true
        }
      }
    }
  ],
  "summary": {
    "total_tasks": 40,
    "completed": 40,
    "failed": 0,
    "retries": 2
  }
}
```

---

## Next Steps

- **[Common Usage Patterns →](USAGE.md)** - Real-world workflows
- **[Troubleshooting Guide →](TROUBLESHOOTING.md)** - Solutions to common issues
- **[Development Guide →](DEVELOPMENT.md)** - Extending the pipeline
- **[Complete Reference →](REFERENCE.md)** - Detailed specifications

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
