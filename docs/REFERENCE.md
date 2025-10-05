# Complete Reference

Detailed specifications for the TO-GO Agent Tutorial Recycling pipeline.

---

## File Structure Reference

### Repository Layout

```
to-go-agent-tutorial-recycling/
├── definitions/                        # Agent definitions (READ-ONLY)
│   ├── orchestrator.agent_v2.0.1.json ← Entry point (load this)
│   ├── agent.config_v2.0.1.json       ← Agent definitions & validation
│   ├── task.schema_v2.0.1.json        ← Task structure schema
│   ├── agent-1-extract_v2.0.1.json    ← Extract agent spec
│   ├── agent-2-inventory_v2.0.1.json  ← Inventory agent spec
│   ├── agent-3-normalize_v2.0.1.json  ← Normalize agent spec
│   ├── agent-4-configure_v2.0.1.json  ← Configure agent spec
│   └── agent-5-generate_v2.0.1.json   ← Generate agent spec
├── data/                               # I/O operations (READ/WRITE)
│   ├── input/                          ← Place source files here
│   │   ├── tutorial-1.md
│   │   ├── tutorial-2.html
│   │   └── tutorial-3.pdf
│   ├── 1-extract/                      ← Stage 1 outputs
│   │   ├── tutorial-1_extract.json
│   │   ├── tutorial-2_extract.json
│   │   └── tutorial-3_extract.json
│   ├── 2-inventory/                    ← Stage 2 outputs
│   │   └── {basename}_inventory.json
│   ├── 3-normalize/                    ← Stage 3 outputs
│   │   └── {basename}_normalize.json
│   ├── 4-configure/                    ← Stage 4 outputs
│   │   └── {basename}_configure.json
│   ├── 5-generate/                     ← Final outputs
│   │   ├── tutorial-1.md
│   │   ├── tutorial-1.json
│   │   └── ...
│   ├── profile.json (optional)         ← User profile
│   └── task-tracker_session_{id}.json ← Execution log
├── temp/                               # Logs (READ/WRITE, ephemeral)
│   └── .gitkeep
├── docs/                               # Documentation
│   ├── PIPELINE.md
│   ├── USAGE.md
│   ├── TROUBLESHOOTING.md
│   ├── DEVELOPMENT.md
│   └── REFERENCE.md (this file)
├── README.md
├── LICENSE
├── .gitignore
└── project.manifest.json
```

---

## Stage Output Schemas

### Stage 1: Extract Output

**File:** `data/1-extract/{basename}_extract.json`

**Schema:**
```json
{
  "source_file": "string",
  "source_format": "md|html|pdf",
  "extracted_at": "ISO 8601 timestamp",
  
  "chunks": [
    {
      "id": "chunk_{:03d}",
      "kind": "paragraph|code|heading|table|image|callout",
      "content": "string (verbatim from source)",
      "language": "string|null (for code blocks)",
      "source_line": "integer|null",
      "metadata": {}
    }
  ],
  
  "steps": [
    {
      "id": "step_{:03d}",
      "ordinal": "integer (1, 2, 3...)",
      "title": "string",
      "action": "Install|Configure|Run|Verify|Create|etc",
      "source_refs": ["chunk_001", "chunk_002"],
      "commands": ["string"],
      "notes": "string|null"
    }
  ],
  
  "entities": [
    "string (tool, package, file, dataset, product names)"
  ],
  
  "references": [
    "string (URLs)"
  ],
  
  "metadata": {
    "total_chunks": "integer",
    "total_steps": "integer",
    "total_entities": "integer",
    "processing_notes": []
  }
}
```

**Validation Rules:**
- All chunks have `id` and `kind`
- All steps have `id`, `ordinal`, `title`, `action`, `source_refs` (min 1)
- Code content 100% verbatim
- NO emojis, icons, ellipsis, TODO markers
- All `source_refs` point to valid chunk IDs

---

### Stage 2: Inventory Output

**File:** `data/2-inventory/{basename}_inventory.json`

**Schema:**
```json
{
  "source_file": "string",
  "indexed_at": "ISO 8601 timestamp",
  
  "indices": {
    "entities": [
      {
        "name": "string",
        "category": "tool|package|file|dataset|product",
        "source_refs": ["chunk_001"]
      }
    ],
    "tools": [
      {
        "name": "string",
        "source_refs": ["chunk_002"]
      }
    ],
    "files": [
      {
        "path": "string",
        "source_refs": ["chunk_003"]
      }
    ],
    "commands": [
      {
        "command": "string",
        "source_refs": ["chunk_004"]
      }
    ],
    "datasets": [
      {
        "name": "string",
        "source_refs": ["chunk_005"]
      }
    ]
  },
  
  "mappings": {
    "chunk_to_step": {
      "chunk_001": ["step_001"],
      "chunk_002": ["step_001", "step_002"]
    },
    "deduplications": {
      "python3": "python",
      "py": "python",
      "npm": "npm"
    }
  },
  
  "statistics": {
    "unique_entities": "integer",
    "unique_tools": "integer",
    "unique_files": "integer",
    "unique_commands": "integer",
    "unique_datasets": "integer"
  }
}
```

**Validation Rules:**
- All indices non-empty (or explicitly null with note)
- All items have `source_refs`
- Alphabetical sorting (case-insensitive)
- All `source_refs` point to valid chunk IDs
- No duplicate entries within same index

---

### Stage 3: Normalize Output

**File:** `data/3-normalize/{basename}_normalize.json`

**Schema:**
```json
{
  "source_file": "string",
  "normalized_at": "ISO 8601 timestamp",
  
  "skeleton": {
    "overview": {
      "title": "string|null",
      "content": ["chunk_001", "chunk_002"],
      "source_refs": ["chunk_001", "chunk_002"]
    },
    
    "prerequisites": {
      "title": "string|null",
      "items": [
        {
          "type": "software|hardware|knowledge",
          "description": "string",
          "source_refs": ["chunk_003"]
        }
      ]
    },
    
    "setup": {
      "title": "string|null",
      "steps": [
        {
          "id": "s{:03d}",
          "title": "string",
          "content": ["chunk_004"],
          "source_refs": ["chunk_004"]
        }
      ]
    },
    
    "steps": [
      {
        "id": "s{:03d}",
        "ordinal": "integer",
        "title": "string",
        "action": "string",
        "content": ["chunk_005", "chunk_006"],
        "commands": ["string"],
        "expected_output": "string|null",
        "source_refs": ["chunk_005", "chunk_006"]
      }
    ],
    
    "validation": {
      "title": "string|null",
      "checks": [
        {
          "description": "string",
          "command": "string|null",
          "source_refs": ["chunk_007"]
        }
      ]
    },
    
    "troubleshooting": {
      "title": "string|null",
      "issues": [
        {
          "problem": "string",
          "solution": "string",
          "source_refs": ["chunk_008"]
        }
      ]
    },
    
    "references": {
      "title": "string|null",
      "links": [
        {
          "url": "string",
          "description": "string|null",
          "source_refs": ["chunk_009"]
        }
      ]
    }
  },
  
  "metadata": {
    "total_sections": 7,
    "sections_populated": "integer",
    "total_steps": "integer"
  }
}
```

**Validation Rules:**
- All 7 sections present (even if empty/null)
- Fixed section order maintained
- Steps ordered by `ordinal` (ascending)
- Stable ID format: `s{:03d}`
- All `source_refs` point to valid chunk IDs

---

### Stage 4: Configure Output

**File:** `data/4-configure/{basename}_configure.json`

**Schema:**
```json
{
  "source_file": "string",
  "configured_at": "ISO 8601 timestamp",
  "profile_applied": {
    "os": "linux|windows|macos|null",
    "experience": "beginner|intermediate|advanced|null",
    "hardware": "cpu|gpu|null",
    "language": "string|null"
  },
  
  "selected_content": {
    "skeleton": {
      // Same structure as Stage 3, but filtered
    }
  },
  
  "exclusions": [
    {
      "section": "string",
      "item_id": "string",
      "item_type": "step|prerequisite|check|issue",
      "reason": "string (OS mismatch, experience level, hardware)",
      "content_preview": "string (first 100 chars)",
      "source_refs": ["chunk_010"]
    }
  ],
  
  "statistics": {
    "items_included": "integer",
    "items_excluded": "integer",
    "exclusion_rate": "float (0.0-1.0)"
  }
}
```

**Validation Rules:**
- `selected_content` non-empty
- All exclusions documented with reasons
- Profile values valid (see profile schema)
- All `source_refs` point to valid chunk IDs
- Exclusion rate < 0.50 (sanity check)

---

### Stage 5: Generate Output

**Files:** 
- `data/5-generate/{basename}.md` (Markdown)
- `data/5-generate/{basename}.json` (JSON mirror)

**Markdown Structure:**
```markdown
# Tutorial Title

Brief overview paragraph.

## Overview

Detailed overview content...

## Prerequisites

### Software
- Item 1
- Item 2

### Hardware
- Requirement 1

## Materials

List of required materials...

## Setup

### Setup Step 1: Title

Content...

## Step 1: Main Step Title

Detailed step content...

```bash
command here
```

Expected output: Description

## Step 2: Next Step

...

## Validation

### Check 1: Verify Installation

How to verify...

## Troubleshooting

### Issue: Problem Description

**Solution:** How to fix...

## References

- [Link 1](url)
- [Link 2](url)
```

**JSON Schema:**
```json
{
  "metadata": {
    "title": "string",
    "generated_at": "ISO 8601 timestamp",
    "source_file": "string",
    "version": "2.0.0"
  },
  
  "content": {
    "title": "string",
    "overview": "string",
    "prerequisites": {},
    "materials": {},
    "setup": {},
    "steps": [
      {
        "number": 1,
        "title": "string",
        "content": "string (markdown)",
        "commands": ["string"],
        "expected_output": "string|null"
      }
    ],
    "validation": {},
    "troubleshooting": {},
    "references": []
  }
}
```

**Validation Rules:**
- Both files present (MD and JSON)
- Markdown valid (parseable)
- Steps numbered 1..N (contiguous)
- NO emojis, icons, trailing spaces
- LF line endings only
- UTF-8 encoding
- 2-space indentation for lists
- Code blocks fenced with language specified

---

## Profile Schema

**File:** `data/profile.json` (optional)

**Schema:**
```json
{
  "os": "linux|windows|macos|null",
  "experience": "beginner|intermediate|advanced|null",
  "hardware": "cpu|gpu|null",
  "language": "string|null",
  
  "preferences": {
    "verbosity": "minimal|normal|detailed",
    "include_examples": "boolean",
    "include_explanations": "boolean"
  }
}
```

**Valid Values:**

| Field | Type | Valid Values |
|-------|------|-------------|
| `os` | string\|null | `"linux"`, `"windows"`, `"macos"`, `null` |
| `experience` | string\|null | `"beginner"`, `"intermediate"`, `"advanced"`, `null` |
| `hardware` | string\|null | `"cpu"`, `"gpu"`, `null` |
| `language` | string\|null | Any ISO 639-1 code or `null` |
| `preferences.verbosity` | string | `"minimal"`, `"normal"`, `"detailed"` |
| `preferences.include_examples` | boolean | `true`, `false` |
| `preferences.include_explanations` | boolean | `true`, `false` |

**Null Behavior:**
- `null` means "include all variants"
- No profile file = all `null` (include everything)

---

## Task Tracker Schema

**File:** `data/task-tracker_session_{id}.json`

**Schema:**
```json
{
  "session_id": "session_{YYYYMMDD}_{HHMMSS}_{random}",
  "pipeline_name": "Tutorial Processing Pipeline",
  "started_at": "ISO 8601 timestamp",
  "completed_at": "ISO 8601 timestamp|null",
  "status": "RUNNING|SUCCESS|FAILED|ABORTED",
  
  "tasks": [
    {
      "task_id": "string",
      "stage_id": "integer (1-5)",
      "agent_id": "integer (1-5)",
      "input_file": "string",
      "output_file": "string",
      "status": "CREATED|ASSIGNED|IN_PROGRESS|COMPLETED|FAILED|VALIDATED|REJECTED|RETRY_SCHEDULED|ABORTED",
      
      "timestamps": {
        "created_at": "ISO 8601 timestamp",
        "assigned_at": "ISO 8601 timestamp|null",
        "completed_at": "ISO 8601 timestamp|null",
        "validated_at": "ISO 8601 timestamp|null"
      },
      
      "execution": {
        "retry_count": "integer",
        "token_usage": "integer",
        "token_target": "integer",
        "utilization": "float (0.0-1.0)"
      },
      
      "validation_result": {
        "decision": "ACCEPT|REJECT",
        "checks": {
          "schema_valid": "boolean",
          "patterns_clean": "boolean",
          "completeness_met": "boolean",
          "fidelity_met": "boolean"
        },
        "failure_reasons": ["string"],
        "warnings": ["string"]
      },
      
      "execution_log": [
        {
          "timestamp": "ISO 8601 timestamp",
          "event_type": "start|checkpoint|decision|warning|error|completion",
          "description": "string",
          "severity": "low|medium|high|critical"
        }
      ]
    }
  ],
  
  "summary": {
    "total_files": "integer",
    "total_tasks": "integer (files × stages)",
    "completed": "integer",
    "failed": "integer",
    "retries": "integer",
    "total_tokens": "integer"
  }
}
```

**Status Transitions:**
```
CREATED → ASSIGNED → IN_PROGRESS → COMPLETED → VALIDATED
                                  → FAILED → RETRY_SCHEDULED → ASSIGNED
                                          → ABORTED
                     → REJECTED → RETRY_SCHEDULED → ASSIGNED
                               → ABORTED
```

---

## Token Management

### Allocation Formula

```
actual_tokens = (model_context_window × token_allocation_percent) / 100
```

**Example (Claude Sonnet 4.5, 200K window):**

| Agent | Percentage | Calculation | Tokens |
|-------|-----------|------------|--------|
| Extract | 30% | 200000 × 0.30 | 60,000 |
| Inventory | 20% | 200000 × 0.20 | 40,000 |
| Normalize | 20% | 200000 × 0.20 | 40,000 |
| Configure | 10% | 200000 × 0.10 | 20,000 |
| Generate | 40% | 200000 × 0.40 | 80,000 |
| **Total** | **120%** | — | **240,000** |

### Safety Thresholds

```json
{
  "token_management": {
    "safety_threshold": 0.85,  // 85% - Warning logged
    "abort_threshold": 0.90    // 90% - Abort and retry
  }
}
```

**Behavior:**
- Usage < 85%: Normal operation
- Usage 85-90%: Warning logged, continue
- Usage > 90%: Abort task, mark for retry
- After 3 retries: Fail task, continue pipeline

### Model-Agnostic Design

Pipeline adapts to different models:

| Model | Context | Extract | Inventory | Normalize | Configure | Generate |
|-------|---------|---------|-----------|-----------|-----------|----------|
| Claude Sonnet 4 | 200K | 60K | 40K | 40K | 20K | 80K |
| Claude Opus 4 | 200K | 60K | 40K | 40K | 20K | 80K |
| Claude Haiku 4 | 200K | 60K | 40K | 40K | 20K | 80K |
| Future Model | 500K | 150K | 100K | 100K | 50K | 200K |

Same percentages, scales automatically.

---

## Quality Metrics

### Completeness

**Definition:** Percentage of source content captured in outputs

**Formula:**
```
completeness = (output_content_units / source_content_units)
```

**Content Units:**
- Paragraphs
- Code blocks
- Tables
- Lists
- Images

**Threshold:** ≥ 98%

**Example:**
- Source: 100 paragraphs
- Output: 99 paragraphs
- Completeness: 0.99 (99%) ✅

---

### Fidelity

**Definition:** Accuracy of content preservation

**Formula:**
```
fidelity = 1 - (edit_distance / source_length)
```

**Rules:**
- Code blocks: 100% required (edit_distance = 0)
- Text: ≥ 99% (minor edits acceptable)
- Commands: 100% required

**Threshold:** ≥ 99% overall, 100% for code

**Example:**
- Source code: 1000 characters
- Output code: 1000 characters (identical)
- Fidelity: 1.0 (100%) ✅

---

### Schema Conformance

**Definition:** Output matches defined JSON schema

**Formula:**
```
conformance = (valid_fields / total_fields)
```

**Threshold:** 100% (1.0)

**Validation:**
- All required fields present
- All field types correct
- All enums within valid values
- All references valid (IDs exist)

**Example:**
- Required fields: 10
- Present fields: 10
- Valid types: 10
- Conformance: 1.0 (100%) ✅

---

## Forbidden Patterns

### Emoji Detection

**Pattern:** `/[\u{1F300}-\u{1F9FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}\u{2190}-\u{21FF}]/u`

**Covers:**
- Emoticons: 😀 😃 😄
- Symbols: ✅ ❌ ⚠️
- Arrows: → ← ↑ ↓
- Shapes: ★ ☆ ■ □

**Severity:** BLOCKER

---

### Ellipsis

**Pattern:** `/\.\.\.+/`

**Matches:**
- `...` (three dots)
- `....` (four or more)

**Severity:** BLOCKER

**Reason:** Indicates incomplete content

---

### TODO Markers

**Pattern:** `/\b(TODO|TBD|FIXME)\b/`

**Matches:**
- TODO
- TBD
- FIXME

**Severity:** BLOCKER

**Reason:** Indicates incomplete work

---

### Speculation Keywords

**Pattern:** `/\b(maybe|perhaps|likely)\b/`

**Matches:**
- maybe
- perhaps  
- likely

**Severity:** WARNING

**Reason:** Indicates uncertainty

---

## Error Codes

### Structure Errors

| Code | Message | Severity | Action |
|------|---------|----------|--------|
| `STRUCT_001` | Unauthorized file in definitions directory | CRITICAL | Abort immediately |
| `STRUCT_002` | Missing required file | CRITICAL | Abort immediately |
| `STRUCT_003` | Invalid directory structure | CRITICAL | Abort immediately |

### Validation Errors

| Code | Message | Severity | Action |
|------|---------|----------|--------|
| `VALID_001` | Schema validation failed | HIGH | Retry (max 3x) |
| `VALID_002` | Forbidden pattern detected | HIGH | Retry (max 3x) |
| `VALID_003` | Completeness below threshold | HIGH | Retry (max 3x) |
| `VALID_004` | Fidelity below threshold | HIGH | Retry (max 3x) |

### Execution Errors

| Code | Message | Severity | Action |
|------|---------|----------|--------|
| `EXEC_001` | Agent definition not found | CRITICAL | Abort immediately |
| `EXEC_002` | Input contract violation | CRITICAL | Abort immediately |
| `EXEC_003` | Token overflow | MEDIUM | Retry (max 3x) |
| `EXEC_004` | Timeout | MEDIUM | Retry (max 3x) |

---

## API Endpoints (Future)

### Planned REST API

**Note:** Currently CLI-only. REST API planned for v3.0.

**Proposed endpoints:**

```
POST /api/v1/pipelines
GET  /api/v1/pipelines/{id}
GET  /api/v1/pipelines/{id}/status
POST /api/v1/pipelines/{id}/approve
POST /api/v1/pipelines/{id}/reject
GET  /api/v1/outputs/{pipeline_id}
```

---

## Performance Benchmarks

### Typical Processing Times

| Input Size | Files | Stages | Duration | Tokens/File |
|-----------|-------|--------|----------|-------------|
| Small (<500 lines) | 10 | 5 | ~5 min | ~15K |
| Medium (500-2000 lines) | 10 | 5 | ~15 min | ~40K |
| Large (>2000 lines) | 10 | 5 | ~30 min | ~80K |

**Variables:**
- Model speed
- Network latency
- File complexity
- Code/text ratio

---

## Next Steps

- **[Pipeline Documentation →](PIPELINE.md)** - Deep dive into the 5 stages
- **[Usage Guide →](USAGE.md)** - Common workflows and patterns
- **[Troubleshooting Guide →](TROUBLESHOOTING.md)** - Solutions to common issues
- **[Development Guide →](DEVELOPMENT.md)** - Extending the pipeline

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
