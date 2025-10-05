# TO-GO Agent: Tutorial Recycling

<div align="center">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![AI Agents](https://img.shields.io/badge/AI-Agents-purple.svg)](https://github.com/topics/ai-agents)
[![MCP](https://img.shields.io/badge/MCP-Protocol-green.svg)](https://modelcontextprotocol.io/)

**Autonomous pipeline for transforming raw tutorials into standardized, personalized formats.**

[Features](#what-is-this) •
[Quick Start](#quick-start) •
[Documentation](#documentation) •
[Contributing](#contributing)

</div>

---

## Why This Exists

**The Problem:** Tutorials scattered across formats (Markdown, HTML, PDF, blogs) need standardization, personalization for different platforms, quality control, and source traceability. Manual processing is slow and doesn't scale.

**The Solution:** An autonomous, 5-stage pipeline that transforms any tutorial into clean, platform-specific output with guaranteed quality—regardless of where you run it.

---

## The TO-GO Philosophy

**TO-GO = Take it anywhere, use it everywhere**

Self-contained agent definitions that run wherever Claude runs:
- **No platform dependencies** - Works in Desktop, API, Projects
- **No vendor lock-in** - Pure JSON configuration
- **Portable workflows** - Copy files, load orchestrator, it works

**[Read more about TO-GO principles →](docs/DEVELOPMENT.md#architecture-overview)**

---

## What Is This?

The TO-GO Agent processes tutorials through a **5-stage pipeline** with user approval gates:

1. **Extract** - Parse source into chunks and steps
2. **Inventory** - Build indices for entities, tools, commands
3. **Normalize** - Map to canonical skeleton structure
4. **Configure** - Filter by user profile (OS, experience, hardware)
5. **Generate** - Emit tutorial.md + tutorial.json

**Quality Promise:**
- Schema conformance: 100%
- Completeness: ≥98%
- Fidelity: ≥99% (code 100% verbatim)
- Full source traceability

**[See detailed pipeline documentation →](docs/PIPELINE.md)**

---

## Quick Start

### Prerequisites

Before starting, ensure you have:
- [ ] Claude Desktop installed - [Download](https://claude.ai/download)
- [ ] Filesystem access configured - [Setup Guide](#installation)
- [ ] Repository cloned - [Installation](#installation)

### Step 1: Create Claude Project

1. **Open Claude Desktop → Create new Project**
2. **Add Project Description:**

   ```
   TO-GO Agent: Autonomous tutorial processing pipeline. Load 
   orchestrator.agent_v2.0.0.json to start. Batch processing with user gates.
   ```

3. **Add Custom Instructions:**

   ```
   You are the TO-GO Agent Orchestrator v2.0.
   
   BATCH PROCESSING:
   - Process ALL files stage-by-stage
   - NEVER infer properties across files
   - WAIT for user approval after EACH stage
   
   QUALITY: Schema 100%, Completeness ≥98%, Fidelity ≥99%
   NO emojis, icons, ellipsis, TODO markers
   
   DIRECTORIES:
   - Input: data/input/*.{md,html,pdf}
   - Outputs: data/{1-5}-{stage}/
   - READ-ONLY: definitions/
   
   EXECUTION:
   Stage 1 → USER GATE → Stage 2 → USER GATE → ... → Stage 5
   
   ERROR HANDLING:
   Max 3 retries per file, failed files don't block batch
   ```

### Step 2: Load Orchestrator

In your Claude Project chat:

```
Load: definitions/orchestrator.agent_v2.0.1.json
```

### Step 3: Prepare Input Files

Place tutorial files in the input directory:

```bash
data/input/
├── tutorial-1.md
├── tutorial-2.html
└── tutorial-3.pdf
```

**Optional - Create user profile for filtering:**

Create `data/profile.json`:
```json
{
  "os": "linux",
  "experience": "intermediate",
  "hardware": "gpu"
}
```

If no profile provided, all platform variants are included.

### Step 4: Start Processing

In Claude Project chat:

```
Process all files in data/input/
```

The orchestrator will:
- Process all files through Stage 1
- Wait for your approval: `APPROVE | REJECT | RETRY_FAILED`
- Continue stage-by-stage with approval gates
- Output to `data/5-generate/` (final Markdown + JSON)

**[See detailed usage patterns →](docs/USAGE.md)**

---

## Installation

### 1. Clone Repository

```bash
git clone https://github.com/neomint-research/to-go-agent-tutorial-recycling.git
cd to-go-agent-tutorial-recycling
```

### 2. Configure Filesystem Access

**Option 1: Claude Desktop with MCP (Recommended)**

Requirements: [Claude Desktop](https://claude.ai/download) + [Node.js](https://nodejs.org/)

1. Open Claude Desktop Settings → Developer → Edit Config
2. Add configuration:

   ```json
   {
     "mcpServers": {
       "filesystem": {
         "command": "npx",
         "args": [
           "-y",
           "@modelcontextprotocol/server-filesystem",
           "/absolute/path/to/to-go-agent-tutorial-recycling"
         ]
       }
     }
   }
   ```

3. Replace `/absolute/path/to/` with your repository path
4. Restart Claude Desktop
5. Verify: Look for hammer icon in input box

**Option 2: Docker Desktop MCP Toolkit**

Requirements: [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.40+ (macOS) or 4.42+ (Windows)

See [Docker MCP Docs](https://docs.docker.com/ai/mcp-catalog-and-toolkit/toolkit/) for setup.

---

## Common Workflows

### Batch Processing

**Process 10 tutorials with approval gates:**

1. Place files in `data/input/`
2. Start: `Process all files in data/input/`
3. Stage 1 processes all files → Review → `APPROVE`
4. Stage 2 processes all files → Review → `APPROVE`
5. Continue through Stages 3-5
6. Final outputs in `data/5-generate/`

**Benefits:**
- Review each stage before proceeding
- Failed files don't block the batch
- Retry only failed files

**[See more usage patterns →](docs/USAGE.md)**

### Processing Different Profiles

**Linux users:**
```json
{"os": "linux", "experience": "beginner"}
```

**Windows users:**
```json
{"os": "windows", "experience": "beginner"}
```

Run pipeline twice with different profiles for platform-specific tutorials.

---

## Troubleshooting

### Common Issues

**Filesystem not working?**
- Verify MCP config has absolute path
- Restart Claude Desktop
- Check Node.js installed: `node --version`

**Pipeline fails?**
- Review `data/task-tracker_session_{id}.json`
- Check for validation errors
- Verify all 8 files exist in `definitions/`

**Missing dependencies?**
- Verify files exist:
- `orchestrator.agent_v2.0.1.json`
- `agent.config_v2.0.1.json`
- `task.schema_v2.0.1.json`
- `agent-{1-5}-*_v2.0.1.json` (5 files)

**[See complete troubleshooting guide →](docs/TROUBLESHOOTING.md)**

---

## Understanding the Pipeline

### Why Stage-by-Stage Processing?

**v2.0 Change:** All files → Stage 1 → USER GATE → All files → Stage 2 → USER GATE

**Benefits:**
1. **Input Isolation** - Each file processed independently
2. **Quality Gates** - Review and approve after each stage
3. **Batch Efficiency** - Process many files without manual intervention
4. **Flexible Retry** - Retry only failed files

**[Deep dive into pipeline architecture →](docs/PIPELINE.md)**

---

## Documentation

### Guides

- **[Pipeline Documentation](docs/PIPELINE.md)** - Deep dive into the 5 stages
- **[Usage Guide](docs/USAGE.md)** - Common workflows and patterns
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Solutions to common issues
- **[Development Guide](docs/DEVELOPMENT.md)** - Extending the pipeline
- **[Complete Reference](docs/REFERENCE.md)** - Detailed specifications

### Key Topics

**Pipeline Architecture:**
- [Stage 1: Extract](docs/PIPELINE.md#stage-1-extract) - Parse into chunks/steps
- [Stage 2: Inventory](docs/PIPELINE.md#stage-2-inventory) - Build indices
- [Stage 3: Normalize](docs/PIPELINE.md#stage-3-normalize) - Canonical structure
- [Stage 4: Configure](docs/PIPELINE.md#stage-4-configure) - Profile filtering
- [Stage 5: Generate](docs/PIPELINE.md#stage-5-generate) - Final outputs

**Common Tasks:**
- [Batch Processing](docs/USAGE.md#batch-processing) - Process multiple files
- [Profile Filtering](docs/USAGE.md#profile-based-filtering) - Platform-specific output
- [Monitoring Progress](docs/USAGE.md#monitoring-progress) - Track execution
- [Retry Strategies](docs/USAGE.md#retry-strategies) - Handle failures

**Development:**
- [Adding Custom Agents](docs/DEVELOPMENT.md#adding-a-custom-agent) - Extend pipeline
- [Naming Conventions](docs/DEVELOPMENT.md#naming-conventions) - File/field naming
- [Token Management](docs/DEVELOPMENT.md#token-budget-management) - Optimize allocations
- [Testing](docs/DEVELOPMENT.md#testing-custom-agents) - Validate changes

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
│   ├── input/                          ← Place source files here
│   ├── {1-5}-{stage}/                  ← Stage outputs
│   ├── profile.json (optional)
│   └── task-tracker_session_{id}.json
├── docs/                               # Documentation
│   ├── PIPELINE.md
│   ├── USAGE.md
│   ├── TROUBLESHOOTING.md
│   ├── DEVELOPMENT.md
│   └── REFERENCE.md
└── README.md (this file)
```

**[See detailed structure reference →](docs/REFERENCE.md#file-structure-reference)**

---

## Contributing

We welcome contributions! See the [Development Guide](docs/DEVELOPMENT.md) for:
- Adding custom agents
- Extending validation rules
- Improving documentation
- Reporting issues

---

## License

MIT License - Copyright (c) 2025 MINT-RESEARCH by NeoMINT GmbH

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

---

## Contact

**Organization:** MINT-RESEARCH by NeoMINT GmbH  
**Email:** research@neomint.com  
**Repository:** https://github.com/neomint-research/to-go-agent-tutorial-recycling

---

## Acknowledgments

Built on the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) specification by Anthropic.

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
