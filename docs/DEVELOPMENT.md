# Development Guide

Guide for extending and customizing the TO-GO Agent Tutorial Recycling pipeline.

---

## Architecture Overview

The pipeline follows a **multi-agent orchestration** pattern:

```
Orchestrator (conductor)
    ↓
Agent 1: Extract  ─→  data/1-extract/
    ↓
Agent 2: Inventory  ─→  data/2-inventory/
    ↓
Agent 3: Normalize  ─→  data/3-normalize/
    ↓
Agent 4: Configure  ─→  data/4-configure/
    ↓
Agent 5: Generate  ─→  data/5-generate/
```

**Key principles:**
- **Single Responsibility:** Each agent has one job
- **Loose Coupling:** Agents communicate via JSON files
- **Validation Gates:** Quality checks between stages
- **Traceability:** Full audit trail via source_refs

---

## Naming Conventions

This project uses strict naming conventions for consistency.

### File Naming

**Repository:**
- Format: `lowercase-with-dashes`
- Example: `to-go-agent-tutorial-recycling`

**Directories:**
- Format: `lowercase`
- Examples: `definitions`, `data`, `temp`

**Agent Files:**
- Format: `agent-{id}-{name}_v{major}.{minor}.{patch}.json`
- Examples: 
  - `agent-1-extract_v2.0.1.json`
  - `agent-2-inventory_v2.0.1.json`

**Config Files:**
- Format: `{name}.config_v{major}.{minor}.{patch}.json`
- Example: `agent.config_v2.0.0.json`

**Schema Files:**
- Format: `{name}.schema_v{major}.{minor}.{patch}.json`
- Example: `task.schema_v2.0.0.json`

### JSON Field Naming

**Field Names:**
- Format: `snake_case`
- Examples: `agent_id`, `token_allocation_percent`, `source_refs`

**Agent Names (internal):**
- Format: lowercase
- Example: `"name": "inventory"`

**Agent Names (display):**
- Format: Title Case
- Example: `"name": "Inventory"` (in spec files)

**Why This Dual Convention?**
- Internal references use lowercase for programmatic consistency
- Display names use Title Case for human readability
- This is intentional and documented

**Full Documentation:** See `temp/naming-convention_v1.0.0.md`

---

## Adding a Custom Agent

### Step 1: Create Agent Specification

Create `definitions/agent-6-custom_v2.0.1.json`:

```json
{
  "agent_id": 6,
  "name": "Custom",
  "file": "agent-6-custom_v2.0.1.json",
  "version": "2.0.1",
  "role": "Brief description of agent purpose",
  
  "task_reception": {
    "from_orchestrator": "Receives task object with input data",
    "validates": "Input contract validation rules"
  },
  
  "execution": {
    "processing": {
      "description": "What the agent does",
      "inputs": "Expected input structure",
      "outputs": "Produced output structure"
    }
  },
  
  "result_submission": {
    "to_orchestrator": "Returns task object with output_data",
    "output_structure": {
      "field1": "Description",
      "field2": "Description"
    }
  },
  
  "changelog": [
    {
      "version": "2.0.1",
      "date": "2025-10-05",
      "changes": [
        "Initial version",
        "Compatible with orchestrator.agent_v2.0.1.json"
      ]
    }
  ]
}
```

### Step 2: Update Agent Config

Edit `definitions/agent.config_v2.0.1.json`:

```json
{
  "agents": [
    // ... existing agents ...
    {
      "agent_id": 6,
      "name": "custom",
      "spec_file": "agent-6-custom_v2.0.1.json",
      "role": "Brief description",
      "input_contract": {
        "required": ["input_field"],
        "schema_ref": "Description"
      },
      "output_contract": {
        "required": ["output_field"],
        "file": "step-6_custom.json",
        "schema_ref": "Description"
      },
      "validation_rules": {
        "schema": "Validation description",
        "forbidden_patterns": ["emojis", "icons"],
        "completeness_min": 0.98,
        "fidelity_min": 0.99
      },
      "token_allocation_percent": 15
    }
  ]
}
```

**Important:**
- Adjust token percentages (total should stay around 120%)
- Define clear validation rules
- Specify input/output contracts

### Step 3: Update Orchestrator Pipeline

Edit `definitions/orchestrator.agent_v2.0.1.json`:

Add stage to `pipeline_definition.stages`:

```json
{
  "stage_id": 6,
  "name": "custom",
  "agent_id": 6,
  "description": "Brief description",
  "input_required": "step-5_generate.json",
  "input_location": "data/",
  "output_produces": "step-6_custom.json",
  "output_location": "data/",
  "validation_contract": "agent.config::agents[5].validation_rules"
}
```

### Step 4: Update Project Manifest

Edit `project.manifest.json`:

Add to `required_files` in `definitions_directory`:

```json
{
  "definitions_directory": {
    "required_files": [
      // ... existing files ...
      "agent-6-custom_v2.0.1.json"
    ]
  }
}
```

### Step 5: Test

1. **Verify files:**
   ```bash
   ls definitions/agent-6-custom_v2.0.1.json
   ```

2. **Load orchestrator:**
   ```
   Load: definitions/orchestrator.agent_v2.0.1.json
   ```

3. **Process test file:**
   ```
   Process all files in data/input/
   ```

4. **Verify new stage executes:**
   - Check for Stage 6 user gate
   - Verify output in `data/6-custom/`
   - Review task-tracker

---

## Structure Validation

### Understanding project.manifest.json

The manifest defines the **exact** allowed repository structure:

```json
{
  "repository_root": "to-go-agent-tutorial-recycling/",
  "required_structure": {
    "definitions_directory": {
      "path": "definitions/",
      "access": "read-only",
      "required_files": [
        "orchestrator.agent_v2.0.1.json",
        "agent.config_v2.0.1.json",
        // ... etc
      ]
    },
    "working_directory": {
      "path": "data/",
      "access": "read-write",
      "allowed_subdirectories": [
        "input/",
        "1-extract/",
        // ... etc
      ]
    }
  }
}
```

### Validation Timing

Structure is validated at:

1. **Initialization** - Before pipeline starts
2. **Before file operations** - Each read/write
3. **After file operations** - Verify no violations
4. **Completion** - Final check

### Common Violations

**Creating files in definitions directory:**
```bash
❌ definitions/notes.txt
✅ temp/notes.txt
```

**Modifying agent definitions during runtime:**
```bash
❌ Editing agent.config_v2.0.1.json during execution
✅ Edit before or after pipeline runs
```

**Wrong file extensions:**
```bash
❌ data/input/tutorial.txt
✅ data/input/tutorial.md
```

**Extra directories:**
```bash
❌ to-go-agent-tutorial-recycling/backup/
✅ temp/backup/  (or outside repo)
```

### Handling Violations

When violation detected:

1. **Pipeline aborts immediately**
2. **Error report written to `data/error-report.json`:**
   ```json
   {
     "error": "Structure integrity violation",
     "severity": "CRITICAL",
     "details": "Unauthorized file detected",
     "file": "definitions/unauthorized.txt",
     "timestamp": "2025-10-05T14:30:22Z"
   }
   ```

3. **Task tracker updated:**
   ```json
   {
     "status": "ABORTED",
     "abort_reason": "Structure integrity violation"
   }
   ```

4. **Fix and restart:**
   ```bash
   mv definitions/unauthorized.txt temp/
   # Then restart pipeline
   ```

---

## Extending Validation Rules

### Adding Custom Patterns

Edit `agent.config_v2.0.1.json` → `global_rules.forbidden_patterns`:

```json
{
  "forbidden_patterns": {
    "no_emojis_icons": {
      "pattern": "/[\\u{1F300}-\\u{1F9FF}]/u",
      "severity": "BLOCKER",
      "message": "NO emojis or icons - ASCII only"
    },
    "no_profanity": {
      "pattern": "/\\b(badword1|badword2)\\b/i",
      "severity": "BLOCKER",
      "message": "NO profanity allowed"
    },
    "custom_pattern": {
      "pattern": "/your-regex-here/",
      "severity": "WARNING|BLOCKER",
      "message": "Your message"
    }
  }
}
```

**Severity levels:**
- `BLOCKER` - Validation fails, retry/abort
- `WARNING` - Logged but doesn't fail validation

### Custom Quality Thresholds

Edit `agent.config_v2.0.1.json` → `global_rules.quality_thresholds`:

```json
{
  "quality_thresholds": {
    "completeness_min": 0.95,     // Lower from 0.98
    "fidelity_min": 0.99,          // Keep strict
    "schema_conformance": 1.0,     // Always 100%
    "custom_metric_min": 0.90      // Add custom metric
  }
}
```

---

## Token Budget Management

### Understanding Allocations

Token allocations are **percentages** of the model's context window:

```json
{
  "token_management": {
    "allocation_mode": "percentage",
    "total_window": 200000,
    "runtime_calculation": "actual_target = (total_window * agent.token_allocation_percent / 100)"
  }
}
```

**Example with 200K window:**

| Agent | Percentage | Actual Tokens |
|-------|-----------|---------------|
| Extract | 30% | 60,000 |
| Inventory | 20% | 40,000 |
| Normalize | 20% | 40,000 |
| Configure | 10% | 20,000 |
| Generate | 40% | 80,000 |
| **Total** | **120%** | **240,000** |

**Why 120%?**
- Agents run sequentially, not in parallel
- No actual overlap in token usage
- Gives flexibility for varying content sizes

### Adjusting for Different Content

**Small tutorials (<500 lines):**
```json
{
  "agents": [
    {"agent_id": 1, "token_allocation_percent": 20},  // Reduce Extract
    {"agent_id": 5, "token_allocation_percent": 30}   // Reduce Generate
  ]
}
```

**Large tutorials (>2000 lines):**
```json
{
  "agents": [
    {"agent_id": 1, "token_allocation_percent": 40},  // Increase Extract
    {"agent_id": 5, "token_allocation_percent": 50}   // Increase Generate
  ]
}
```

**Code-heavy content:**
```json
{
  "agents": [
    {"agent_id": 1, "token_allocation_percent": 35},  // More extraction
    {"agent_id": 2, "token_allocation_percent": 25}   // More inventory
  ]
}
```

### Monitoring Token Usage

Review task tracker:

```json
{
  "tasks": [
    {
      "agent_id": 1,
      "token_usage": 58000,
      "token_target": 60000,
      "utilization": 0.97  // 97% of allocation
    }
  ]
}
```

**Optimization rules:**
- Utilization > 90%: Increase allocation
- Utilization < 50%: Decrease allocation
- Keep total around 120%

---

## Testing Custom Agents

### Unit Testing

Test agent in isolation:

1. **Create minimal input:**
   ```json
   {
     "input_field": "test data"
   }
   ```

2. **Save as:** `temp/test-input.json`

3. **Call agent directly:**
   ```
   Load agent-6-custom_v2.0.1.json
   Process temp/test-input.json
   ```

4. **Verify output:**
   - Matches output contract
   - Passes validation
   - Correct structure

### Integration Testing

Test in full pipeline:

1. **Create small test tutorial:**
   ```markdown
   # Test Tutorial
   
   ## Step 1: Test Step
   Do something.
   ```

2. **Save as:** `data/input/test.md`

3. **Run pipeline:**
   ```
   Process all files in data/input/
   ```

4. **Verify:**
   - All stages complete
   - New stage executes correctly
   - Final output includes custom processing

### Regression Testing

Test against known-good outputs:

```bash
# 1. Save baseline outputs
cp -r data/5-generate/ BASELINE/

# 2. Make changes to agent

# 3. Re-run pipeline
# Process all files in data/input/

# 4. Compare outputs
diff -r BASELINE/ data/5-generate/
```

---

## Version Management

### Semantic Versioning

Follow semantic versioning (MAJOR.MINOR.PATCH):

**MAJOR (2.0.0):**
- Breaking changes to agent contracts
- Incompatible with previous orchestrator versions
- Requires migration

**MINOR (2.1.0):**
- New features, backward compatible
- New agents added
- Enhanced validation

**PATCH (2.0.1):**
- Bug fixes
- Documentation updates
- No contract changes

### Changelog Requirements

Every version change needs changelog entry:

```json
{
  "changelog": [
    {
      "version": "2.0.1",
      "date": "2025-10-06",
      "changes": [
        "Fixed: Bug in entity extraction",
        "Updated: Validation error messages",
        "Improved: Token usage efficiency"
      ]
    },
    {
      "version": "2.0.0",
      "date": "2025-10-05",
      "changes": [
        "Changed: Batch processing mode",
        "Added: User gates after each stage"
      ]
    }
  ]
}
```

### Compatibility Matrix

| Orchestrator | Agent Config | Agents | Compatible |
|-------------|--------------|--------|-----------|
| v2.0.0 | v2.0.0 | v2.0.0 | ✅ Yes |
| v2.0.0 | v1.0.0 | v1.0.0 | ❌ No |
| v2.1.0 | v2.0.0 | v2.0.0 | ✅ Yes (backward compatible) |

---

## Best Practices

### Agent Design

1. **Single Responsibility:**
   - Each agent does ONE thing
   - No mixing of concerns
   - Clear boundaries

2. **Stateless Execution:**
   - No dependencies on previous runs
   - All input via task object
   - No global state

3. **Explicit Contracts:**
   - Document all inputs
   - Define all outputs
   - Specify validation rules

4. **Error Handling:**
   - Fail fast on invalid input
   - Provide clear error messages
   - Log all decisions

### Code Quality

1. **Validation First:**
   - Validate input before processing
   - Check output before submission
   - Document all assumptions

2. **Traceability:**
   - Every output has source_refs
   - Full audit trail
   - Debuggable at any stage

3. **Performance:**
   - Minimize token usage
   - Avoid redundant processing
   - Checkpoint progress

4. **Documentation:**
   - Clear spec files
   - Inline comments for complex logic
   - Usage examples

---

## Contributing

### Development Workflow

1. **Fork repository**
2. **Create feature branch:** `git checkout -b feature/my-agent`
3. **Implement changes**
4. **Test thoroughly**
5. **Update documentation**
6. **Submit pull request**

### Pull Request Checklist

- [ ] Agent spec file created/updated
- [ ] agent.config updated
- [ ] orchestrator pipeline updated (if needed)
- [ ] project.manifest updated
- [ ] Validation rules defined
- [ ] Changelog entry added
- [ ] Tests pass
- [ ] Documentation updated

---

## Next Steps

- **[Pipeline Documentation →](PIPELINE.md)** - Deep dive into the 5 stages
- **[Usage Guide →](USAGE.md)** - Common workflows and patterns
- **[Troubleshooting Guide →](TROUBLESHOOTING.md)** - Solutions to common issues
- **[Complete Reference →](REFERENCE.md)** - Detailed specifications

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
