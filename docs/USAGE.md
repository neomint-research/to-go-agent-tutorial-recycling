# Usage Guide

Common patterns and workflows for the TO-GO Agent Tutorial Recycling pipeline.

---

## Basic Workflow

### 1. Prepare Input Files

Place your tutorial files in the input directory:

```bash
data/input/
├── tutorial-react.md
├── tutorial-docker.md
└── tutorial-python.pdf
```

**Supported formats:** `.md`, `.html`, `.pdf`

### 2. Start Processing

In your Claude Project chat:

```
Load: definitions/orchestrator.agent_v2.0.1.json
Process all files in data/input/
```

### 3. Approve Each Stage

The pipeline will process stage-by-stage:

```
Stage 1 (Extract) complete:
- 3 files succeeded
- 0 files failed
- Review outputs in data/1-extract/

Your decision: APPROVE | REJECT | RETRY_FAILED
```

Type: `APPROVE`

### 4. Retrieve Final Outputs

After Stage 5 completes:

```bash
data/5-generate/
├── tutorial-react.md
├── tutorial-react.json
├── tutorial-docker.md
├── tutorial-docker.json
├── tutorial-python.md
└── tutorial-python.json
```

---

## Batch Processing

### Processing Multiple Tutorials

**Scenario:** Convert 20 tutorials from different formats to standardized output

**Workflow:**

1. **Prepare batch:**
   ```bash
   data/input/
   ├── blog-post-1.md
   ├── blog-post-2.md
   ├── documentation-1.html
   ├── documentation-2.html
   ├── pdf-guide-1.pdf
   └── ... (15 more files)
   ```

2. **Start pipeline:**
   ```
   Process all files in data/input/
   ```

3. **Stage-by-stage approval:**
   - Stage 1: All 20 files extracted → APPROVE
   - Stage 2: All 20 files inventoried → APPROVE
   - Stage 3: All 20 files normalized → APPROVE
   - Stage 4: All 20 files configured → APPROVE
   - Stage 5: All 20 files generated → Done!

4. **Result:**
   - 20 standardized Markdown files
   - 20 structured JSON files
   - Complete execution log
   - All in ~10 minutes (depends on file size)

**Benefits:**
- Single approval per stage (not per file)
- Failed files don't block the batch
- Clear progress tracking
- Efficient use of time

---

## Profile-Based Filtering

### Creating a User Profile

Create `data/profile.json` to filter content:

```json
{
  "os": "linux",
  "experience": "intermediate",
  "hardware": "gpu"
}
```

**Supported values:**

| Field | Options |
|-------|---------|
| `os` | `"linux"`, `"windows"`, `"macos"`, `null` |
| `experience` | `"beginner"`, `"intermediate"`, `"advanced"`, `null` |
| `hardware` | `"cpu"`, `"gpu"`, `null` |
| `language` | Any string or `null` |

**Effect:**
- Content tagged with `[linux]` → included
- Content tagged with `[windows]` or `[macos]` → excluded
- Content with GPU instructions → included
- Generic content → always included

### Multiple Profile Runs

**Scenario:** Create tutorials for different platforms

**Run 1 - Linux beginners:**
```json
{
  "os": "linux",
  "experience": "beginner"
}
```

Process files → outputs in `data/5-generate/`

**Backup outputs:**
```bash
mkdir backups/linux-beginner/
mv data/5-generate/* backups/linux-beginner/
```

**Run 2 - Windows beginners:**
```json
{
  "os": "windows",
  "experience": "beginner"
}
```

Process files again → new outputs in `data/5-generate/`

**Result:**
- Two sets of platform-specific tutorials
- Same source, different outputs
- Documented exclusions in each run

### No Profile (All Variants)

**Scenario:** Keep all platform-specific content

**Solution:** Delete or don't create `data/profile.json`

**Effect:**
- All OS variants included
- All experience levels included
- All hardware variants included
- Outputs include `[linux]`, `[windows]`, `[macos]` sections

---

## Retry Strategies

### Retry Failed Files Only

**Scenario:** 8 files succeeded, 2 files failed in Stage 1

**Pipeline reports:**
```
Stage 1 (Extract) complete:
- 8 files succeeded
- 2 files failed (error: schema validation)
- Review outputs in data/1-extract/

Your decision: APPROVE | REJECT | RETRY_FAILED
```

**Type:** `RETRY_FAILED`

**Result:**
- Only the 2 failed files are re-processed
- 8 successful files unchanged
- Retry count incremented (max 3 retries)

**When to use:**
- Transient errors (network, rate limiting)
- Minor validation failures
- Token overflow on large files

### Full Abort and Restart

**Scenario:** Major error detected in Stage 2

**Type:** `REJECT`

**Result:**
- Pipeline stops immediately
- All progress saved to `data/task-tracker_session_{id}.json`
- Error report generated in `data/`
- Fix issues, then restart from beginning

**When to use:**
- Source file format issues
- Configuration problems
- Fundamental errors requiring intervention

---

## Monitoring Progress

### Check Execution Status

Review the task tracker:

```bash
data/task-tracker_session_20251005_143022_abc123.json
```

**Key information:**
```json
{
  "status": "RUNNING",
  "summary": {
    "total_tasks": 40,
    "completed": 32,
    "failed": 2,
    "retries": 1
  },
  "tasks": [
    {
      "task_id": "...",
      "stage_id": 4,
      "status": "VALIDATED",
      "token_usage": 15000,
      "validation_result": {...}
    }
  ]
}
```

**What to check:**
- **status:** RUNNING | SUCCESS | FAILED | ABORTED
- **completed:** Number of successful tasks
- **failed:** Number of failed tasks
- **retries:** Number of retries performed

### Review Stage Outputs

**After Stage 1:**
```bash
ls data/1-extract/
# tutorial-1_extract.json
# tutorial-2_extract.json
# tutorial-3_extract.json
```

Open a file to verify:
- Chunks extracted correctly
- Steps identified properly
- Entities captured
- No emojis/icons present

**After Stage 5:**
```bash
ls data/5-generate/
# tutorial-1.md    ← Final Markdown
# tutorial-1.json  ← Structured data
```

Open `tutorial-1.md` to verify final output quality.

---

## Advanced Workflows

### Incremental Processing

**Scenario:** Add new tutorials to an existing batch

**Workflow:**

1. **Initial batch:**
   ```bash
   data/input/
   ├── tutorial-1.md
   ├── tutorial-2.md
   └── tutorial-3.md
   ```
   
   Process → outputs in `data/5-generate/`

2. **Backup completed outputs:**
   ```bash
   mkdir data/completed-batch-1/
   mv data/5-generate/* data/completed-batch-1/
   mv data/input/* data/completed-batch-1/
   ```

3. **Add new tutorials:**
   ```bash
   data/input/
   ├── tutorial-4.md
   └── tutorial-5.md
   ```

4. **Process new batch:**
   ```
   Process all files in data/input/
   ```

5. **Merge outputs:**
   ```bash
   cp data/5-generate/* data/completed-batch-1/
   ```

### Debugging a Specific File

**Scenario:** One file consistently fails, need to debug

**Workflow:**

1. **Isolate the file:**
   ```bash
   mkdir data/debug/
   mv data/input/problematic-tutorial.md data/debug/
   mv data/input/* temp/backup/  # Move other files temporarily
   mv data/debug/problematic-tutorial.md data/input/
   ```

2. **Process alone:**
   ```
   Process all files in data/input/
   ```

3. **Review each stage carefully:**
   - Check extraction output
   - Verify inventory indices
   - Examine normalization
   - Test with different profiles

4. **Fix source issues:**
   - Correct malformed Markdown
   - Remove problematic characters
   - Validate file encoding (UTF-8)

5. **Re-process:**
   ```
   Process all files in data/input/
   ```

### Quality Comparison

**Scenario:** Compare output quality across profile variants

**Workflow:**

1. **Process with profile A:**
   ```json
   {"os": "linux", "experience": "beginner"}
   ```
   
   Backup: `backups/linux-beginner/`

2. **Process with profile B:**
   ```json
   {"os": "linux", "experience": "advanced"}
   ```
   
   Backup: `backups/linux-advanced/`

3. **Compare outputs:**
   ```bash
   diff backups/linux-beginner/tutorial-1.md \
        backups/linux-advanced/tutorial-1.md
   ```

4. **Verify filtering:**
   - Beginner: More explanations, simpler commands
   - Advanced: Fewer explanations, complex options
   - Both: Core steps identical

---

## Performance Optimization

### Token Budget Tuning

**Scenario:** Large tutorials hit token limits

**Solution:** Adjust token allocations in `agent.config_v2.0.1.json`

**Example:**
```json
{
  "agents": [
    {
      "agent_id": 1,
      "name": "extract",
      "token_allocation_percent": 35  // Increase from 30%
    },
    {
      "agent_id": 5,
      "name": "generate",
      "token_allocation_percent": 45  // Increase from 40%
    }
  ]
}
```

**Test:**
- Process large file
- Check token_usage in task-tracker
- Adjust percentages if needed
- Keep total around 120%

### Parallel Processing (Manual)

**Scenario:** Process 100 tutorials faster

**Strategy:** Split into multiple batches

**Workflow:**

1. **Split files:**
   ```bash
   mkdir data/input-batch-1/
   mkdir data/input-batch-2/
   # ... up to batch-10
   
   # Distribute 100 files across 10 batches
   ```

2. **Process each batch separately:**
   - Use different Claude Project sessions
   - Or process sequentially with backups between batches

3. **Merge outputs:**
   ```bash
   mkdir data/all-outputs/
   cp data/batch-*/5-generate/* data/all-outputs/
   ```

**Note:** Pipeline is sequential by design. Manual parallelization requires multiple sessions.

---

## Common Patterns Summary

| Use Case | Profile | Input | Action |
|----------|---------|-------|--------|
| Standardize docs | None | Mixed formats | Process all |
| Linux-only tutorial | `{"os":"linux"}` | Multi-platform | Filter OS |
| Beginner guide | `{"experience":"beginner"}` | All levels | Filter complexity |
| GPU-specific | `{"hardware":"gpu"}` | CPU+GPU content | Filter hardware |
| Debug one file | Any | Single file | Isolate & process |
| Batch convert | None | 20+ files | Process all |
| Compare variants | Switch profiles | Same input | Process twice |

---

## Next Steps

- **[Pipeline Documentation →](PIPELINE.md)** - Deep dive into the 5 stages
- **[Troubleshooting Guide →](TROUBLESHOOTING.md)** - Solutions to common issues
- **[Development Guide →](DEVELOPMENT.md)** - Extending the pipeline
- **[Complete Reference →](REFERENCE.md)** - Detailed specifications

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
