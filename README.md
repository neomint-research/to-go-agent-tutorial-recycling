# TO-GO Agent: Tutorial Recycling

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![AI Agents](https://img.shields.io/badge/AI-Agents-purple.svg)](https://github.com/topics/ai-agents)
[![MCP](https://img.shields.io/badge/MCP-Protocol-green.svg)](https://modelcontextprotocol.io/)

**Autonomous pipeline for transforming raw tutorials into standardized, personalized formats.**

[Quick Start](#quick-start) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## Overview

**Problem:** Tutorials scattered across formats (Markdown, HTML, PDF) need standardization, personalization, and quality control.

**Solution:** Autonomous 5-stage pipeline that transforms any tutorial into clean, platform-specific output with guaranteed quality.

### Pipeline Stages

1. **Extract** - Parse source into chunks and steps
2. **Inventory** - Build indices for entities, tools, commands
3. **Normalize** - Map to canonical skeleton structure
4. **Configure** - Filter by user profile (OS, experience, hardware)
5. **Generate** - Emit tutorial.md + tutorial.json

**Quality Metrics:**
- Schema conformance: 100%
- Completeness: ≥98%
- Fidelity: ≥99% (code 100% verbatim)

---

## Key Features

**TO-GO = Take it anywhere, use it everywhere**

- **Platform agnostic** - Works with Claude, ChatGPT, any MCP-compatible AI
- **Pure JSON configuration** - No vendor lock-in
- **Resumable execution** - Continue from any checkpoint
- **Batch processing** - Process multiple files with user gates between stages
- **Input isolation** - Each file processed independently

---

## Installation

```bash
git clone https://github.com/neomint-research/to-go-agent-tutorial-recycling.git
cd to-go-agent-tutorial-recycling
```

### Filesystem Access (Optional - For Bulk Processing)

**Recommended: Docker Desktop + MCP Toolkit**

Requirements: [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.40+ (macOS) or 4.42+ (Windows)

1. Install Docker Desktop and enable MCP Toolkit
2. Configure Desktop Commander MCP Server with repository path
3. Connect to your AI Assistant (e.g., Claude Desktop: Settings → Integrations → Add MCP Server)

**Alternative:** Manual file upload for small batches (1-5 files)

---

## Quick Start

### 1. Setup AI Assistant

**For Claude Desktop:**

1. Create new Project
2. Set Project Description:
   ```
   TO-GO Agent: Autonomous tutorial processing pipeline. Load 
   orchestrator.agent_v2.0.1.json to start. Batch processing with user gates.
   ```
3. Add all files from `definitions/` to Project Knowledge
4. Set Custom Instructions (System Prompt):
   ```
   You are the TO-GO Agent Orchestrator v2.0.
   # ROLE ENFORCEMENT
   You COORDINATE agents. You do NOT execute agent tasks directly.
   # INITIALIZATION (MANDATORY FIRST STEP)
   Check if task-tracker exists in data/:
   - IF task-tracker_session_*.json EXISTS:
     → Load it
     → Read current_stage and status
     → Resume from last checkpoint
     → Report: "Resuming session {id}, Stage {N}, {completed}/{total} files done"
   - IF NO task-tracker exists:
     → Create session_id: session_YYYYMMDD_HHMMSS_{random}
     → Create data/task-tracker_session_{id}.json with structure per task.schema_v2.0.1.json
     → Initialize: tasks=[], current_stage=null, status="INITIALIZED"
     → Scan data/input/ for files
     → Report: "New session {id} created, found {N} files, ready for Stage 1"
   BLOCKING RULE: NO file processing until task-tracker exists and is loaded.
   # PER-FILE PROCESSING (MANDATORY)
   For EACH file:
   1. CREATE task entry (status: CREATED)
   2. UPDATE status: ASSIGNED
   3. PROCESS file through current stage agent
   4. WRITE output to data/{stage-id}-{stage-name}/
   5. UPDATE status: COMPLETED
   6. VALIDATE output per agent.config validation_rules
   7. UPDATE status: VALIDATED (or FAILED if validation fails)
   8. SAVE task-tracker to disk
   9. Report progress: "File {n}/{total}: {filename} - {status}"
   # STAGE COMPLETION
   After ALL files in stage:
   - Count successes/failures
   - Report: "Stage {N} complete: {success} succeeded, {failed} failed"
   - IF failed > 0: List failed files with reasons
   - UPDATE stage_summary in task-tracker
   - SAVE task-tracker
   - WAIT for user: APPROVE | REJECT | RETRY_FAILED
   # QUALITY
   - Schema conformance: 100%
   - Completeness: ≥98%  
   - Fidelity: ≥99%
   - NO emojis, icons, ellipsis, TODO markers
   - Input isolation: NEVER infer across files
   # DIRECTORIES
   - Local: {repository-path}
   - Input: data/input/*.{md,html,pdf}
   - Outputs: data/{1-5}-{stage}/
   - READ-ONLY: definitions/
   - Task tracking: data/task-tracker_session_{id}.json
   # ERROR HANDLING
   - Max 3 retries per file
   - Failed files don't block batch
   - Always save task-tracker before stopping
   ```

### 2. Initialize Pipeline

In your AI assistant chat:

```
Load: definitions/orchestrator.agent_v2.0.1.json
```

### 3. Prepare Input

Place tutorial files in `data/input/`:

```bash
data/input/
├── tutorial-1.md
├── tutorial-2.html
└── tutorial-3.pdf
```

Optional - Create `data/profile.json` for filtering:
```json
{
  "os": "linux",
  "experience": "intermediate",
  "hardware": "gpu"
}
```

### 4. Process Files

```
Process all files in data/input/
```

Pipeline will:
- Process all files through Stage 1
- Wait for your approval
- Continue through Stages 2-5 with gates between each
- Output finals to `data/5-generate/`

---

## Resumable Execution

Task-tracker stores complete state. Resume from any checkpoint:

```
Chat 1: Processing Stage 2, file 15/35 → [Chat closed]

Chat 2: Load: definitions/orchestrator.agent_v2.0.1.json
        → "Resuming session {id}, Stage 2, 14/35 complete"
        → Continues processing
```

To start fresh: Delete `data/task-tracker_session_*.json`

---

## Repository Structure

```
to-go-agent-tutorial-recycling/
├── definitions/                        # Agent definitions (READ-ONLY)
│   ├── orchestrator.agent_v2.0.1.json ← Entry point
│   ├── agent.config_v2.0.1.json
│   ├── task.schema_v2.0.1.json
│   └── agent-{1-5}-*_v2.0.1.json
├── data/                               # I/O operations
│   ├── input/                          ← Source files
│   ├── {1-5}-{stage}/                  ← Stage outputs
│   ├── profile.json (optional)
│   └── task-tracker_session_{id}.json ← State
└── docs/                               # Documentation
    ├── PIPELINE.md
    ├── USAGE.md
    ├── TROUBLESHOOTING.md
    ├── DEVELOPMENT.md
    └── REFERENCE.md
```

---

## Documentation

- **[Pipeline Documentation](docs/PIPELINE.md)** - Deep dive into 5 stages
- **[Usage Guide](docs/USAGE.md)** - Common workflows
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Solutions
- **[Development Guide](docs/DEVELOPMENT.md)** - Extending pipeline
- **[Complete Reference](docs/REFERENCE.md)** - Specifications

---

## Troubleshooting

**MCP not working?**
- Verify Docker Desktop MCP Toolkit is running
- Check allowed paths configuration in Desktop Commander
- Restart AI assistant

**AI says "I cannot execute agents"?**
- Verify custom instructions are set correctly
- Key phrase: "You are BOTH the coordinator AND the executor"

**[Complete troubleshooting guide →](docs/TROUBLESHOOTING.md)**

---

## Contributing

See [Development Guide](docs/DEVELOPMENT.md) for extending the pipeline.

---

## License

MIT License - Copyright (c) 2025 MINT-RESEARCH by NeoMINT GmbH

See LICENSE file for full text.

---

## Contact

**Organization:** MINT-RESEARCH by NeoMINT GmbH  
**Email:** research@neomint.com  
**Repository:** https://github.com/neomint-research/to-go-agent-tutorial-recycling

---

Built on the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) specification by Anthropic.

**Version:** 2.0.3 | **Last Updated:** 2025-10-06
