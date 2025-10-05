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

Self-contained agent definitions that run **anywhere**:
- **Platform agnostic** - Works in web, desktop, API, wherever AI assistants run
- **No specific chatbot required** - Works with Claude, or any MCP-compatible AI assistant
- **Pure JSON configuration** - No vendor lock-in
- **Portable workflows** - Copy files, load orchestrator, it works
- **Resumable execution** - Copy prompt to new chat, continues where it left off

**The key:** Agent definitions are just JSON files with instructions. Any AI assistant that can:
1. Read JSON files
2. Follow instructions
3. Write output files

...can run this pipeline.

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

## Prerequisites

### What You Need

1. **An AI Assistant** - Any of these work:
   - Claude (Desktop, Web, API)
   - ChatGPT (with file access)
   - Any MCP-compatible AI assistant

2. **File System Access** - For batch processing of larger datasets:
   - Desktop chatbot with filesystem access (recommended for bulk processing)
   - MCP connectors (most modern desktop chatbots support these)
   - Or manual file upload (works but slower for many files)

3. **This Repository** - Clone or download the agent definitions

---

## Installation

### Step 1: Clone Repository

```bash
git clone https://github.com/neomint-research/to-go-agent-tutorial-recycling.git
cd to-go-agent-tutorial-recycling
```

### Step 2: Configure Filesystem Access (for Bulk Processing)

**Why:** For processing many files (10+), direct filesystem access is much faster than manual uploads.

**Recommended: MCP-Compatible Desktop Chatbot**

Most modern desktop chatbots now support filesystem access via MCP connectors. Examples:
- Claude Desktop (Anthropic)
- ChatGPT Desktop (OpenAI)  
- Other MCP-compatible assistants

**Method 1: Docker Desktop + MCP Toolkit (Recommended - Works with any MCP client)**

Requirements: [Docker Desktop](https://www.docker.com/products/docker-desktop/) 4.40+ (macOS) or 4.42+ (Windows)

1. **Install Docker Desktop** and enable MCP Toolkit
2. **Configure Desktop Commander MCP Server:**

   In Docker Desktop:
   - Open MCP Toolkit settings
   - Add "Desktop Commander" server
   - Configure allowed paths:
     ```
     /path/to/to-go-agent-tutorial-recycling
     ```
   - Save configuration

3. **Connect MCP Toolkit to your AI Assistant:**

   **For Claude Desktop:**
   - Settings → Integrations → Add MCP Server
   - Select: Docker Desktop MCP Toolkit
   - Authorize access

   **For other MCP clients:**
   - Check your client's documentation for MCP server integration

4. **Verify:**
   - Look for MCP server indicator (hammer icon in Claude, varies by client)
   - Test: Ask assistant to list files in repository directory

**Method 2: Direct MCP Configuration (Alternative - for specific chatbots)**

Some chatbots allow direct MCP server configuration:

**Example for Claude Desktop** (if not using Docker Desktop):

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

3. Replace `/absolute/path/to/` with your actual repository path
4. Restart Claude Desktop
5. Verify: Look for hammer icon in input box

**Note:** This method requires Node.js and varies by chatbot. Docker Desktop method is more universal.

**Method 3: Manual File Upload (No MCP needed)**

Works with any AI assistant (web or desktop):
- Drag and drop files from `data/input/` into chat
- Slower for bulk processing
- Good for testing or processing 1-5 files

---

## Quick Start

### Step 1: Setup AI Assistant

**For Claude Desktop (example):**

1. Create new Project
2. Add all files from `definitions/` to Project Knowledge
3. Add Custom Instructions from `docs/CUSTOM_INSTRUCTIONS.md`

**For other AI assistants:**
- Upload agent definitions from `definitions/` folder
- Set custom instructions (adapt from `docs/CUSTOM_INSTRUCTIONS.md`)

### Step 2: Initialize Pipeline

In your AI assistant chat:

```
Load: definitions/orchestrator.agent_v2.0.1.json
```

The orchestrator will:
- Check for existing task-tracker (resume if found)
- Or initialize new session
- Scan input directory for files
- Report status and wait for command

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

### Step 4: Process Files

```
Process all files in data/input/
```

The AI assistant will:
- Load each agent spec from definitions/
- Execute the agent's work (extraction, indexing, etc.)
- Write outputs to stage directories
- Update task-tracker after each file
- Wait for approval after each stage
- Output finals to `data/5-generate/`

**[See detailed usage patterns →](docs/USAGE.md)**

---

## How It Works

### The Orchestrator Model

```
User → Load orchestrator.agent_v2.0.1.json
         ↓
AI Assistant reads orchestrator spec
         ↓
Checks for task-tracker (resume or initialize)
         ↓
Scans input files
         ↓
FOR EACH STAGE:
  FOR EACH FILE:
    Loads agent-{N}-{stage}_v2.0.1.json
    Reads the agent's instructions
    Executes instructions (parses, extracts, transforms)
    Writes output file
    Updates task-tracker
  END
  Waits for user approval
END
```

**Key insight:** Agent specs are instructions. The AI assistant reads them and executes the work.

---

## Resumable Execution

**The killer feature:** Copy the initialization prompt to ANY new chat, it resumes automatically.

### Scenario 1: Session Interrupted

```
Chat 1: Processing Stage 2, file 15/35
        → Browser crash / Token limit / Chat closed

Chat 2: [Paste initialization prompt]
        → Loads task-tracker
        → Reports: "Resuming session {id}, Stage 2, 14/35 complete"
        → "Ready to continue with file 15"
```

### Scenario 2: Review Between Stages

```
Chat 1: Stage 1 complete → USER GATE
        → "I'll review outputs first"
        → Chat ends

[User reviews data/1-extract/ outputs]

Chat 2: [Paste initialization prompt]  
        → "Stage 1 complete, waiting for approval"
        → User: "APPROVE"
        → Continues to Stage 2
```

**Key:** The task-tracker (`data/task-tracker_session_{id}.json`) holds ALL state.

---

## Common Workflows

### Batch Processing

1. Place files in `data/input/`
2. Load orchestrator (auto-initializes)
3. Start: `Process all files in data/input/`
4. Review Stage 1 → `APPROVE`
5. Review Stage 2 → `APPROVE`
6. Continue through Stages 3-5
7. Finals in `data/5-generate/`

**Benefits:**
- Review each stage before proceeding
- Failed files don't block batch
- Retry only failed files
- Resume anytime from task-tracker

### Processing Different Profiles

Run pipeline twice with different profiles:

**Linux:**
```json
{"os": "linux", "experience": "beginner"}
```

**Windows:**
```json
{"os": "windows", "experience": "beginner"}
```

---

## Troubleshooting

### Filesystem Issues

**MCP not working?**
- Verify Docker Desktop MCP Toolkit is running
- Check allowed paths configuration
- Restart AI assistant
- Try "list files in repository" as test

**Desktop Commander issues?**
- Ensure Docker Desktop 4.40+ (macOS) or 4.42+ (Windows)
- Verify MCP Toolkit enabled in Docker settings
- Check server logs in Docker Desktop

**Alternative:** Use manual file upload for testing

### Pipeline Issues

**AI says "I cannot execute agents"?**
- Check custom instructions match `docs/CUSTOM_INSTRUCTIONS.md`
- Key phrase: "You are BOTH the coordinator AND the executor"

**Want to start fresh?**
- Delete `data/task-tracker_session_*.json`
- Next load creates new session

**[Complete troubleshooting guide →](docs/TROUBLESHOOTING.md)**

---

## Understanding the Pipeline

### Why Stage-by-Stage?

All files → Stage 1 → USER GATE → All files → Stage 2 → USER GATE

**Benefits:**
1. **Input Isolation** - Each file processed independently
2. **Quality Gates** - Review before proceeding
3. **Batch Efficiency** - Process many files
4. **Flexible Retry** - Retry only failed files
5. **Full Resumability** - Continue from any point

**[Pipeline details →](docs/PIPELINE.md)**

---

## Documentation

### Guides

- **[Pipeline Documentation](docs/PIPELINE.md)** - Deep dive into 5 stages
- **[Usage Guide](docs/USAGE.md)** - Common workflows
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Solutions
- **[Development Guide](docs/DEVELOPMENT.md)** - Extending pipeline
- **[Complete Reference](docs/REFERENCE.md)** - Specifications
- **[Custom Instructions](docs/CUSTOM_INSTRUCTIONS.md)** - Setup reference

### Key Topics

**Pipeline:**
- [Extract](docs/PIPELINE.md#stage-1-extract) - Parse to chunks/steps
- [Inventory](docs/PIPELINE.md#stage-2-inventory) - Build indices
- [Normalize](docs/PIPELINE.md#stage-3-normalize) - Canonical structure
- [Configure](docs/PIPELINE.md#stage-4-configure) - Profile filtering
- [Generate](docs/PIPELINE.md#stage-5-generate) - Final outputs

**Common Tasks:**
- [Batch Processing](docs/USAGE.md#batch-processing)
- [Profile Filtering](docs/USAGE.md#profile-based-filtering)
- [Session Management](docs/USAGE.md#session-management)

---

## Repository Structure

```
to-go-agent-tutorial-recycling/
├── definitions/                        # Agent definitions (READ-ONLY)
│   ├── orchestrator.agent_v2.0.1.json ← Entry point
│   ├── agent.config_v2.0.1.json
│   ├── task.schema_v2.0.1.json
│   └── agent-{1-5}-*_v2.0.1.json      ← Agent specs
├── data/                               # I/O operations
│   ├── input/                          ← Source files
│   ├── {1-5}-{stage}/                  ← Stage outputs
│   ├── profile.json (optional)
│   └── task-tracker_session_{id}.json ← STATE
├── docs/                               # Documentation
│   ├── CUSTOM_INSTRUCTIONS.md
│   ├── PIPELINE.md
│   ├── USAGE.md
│   ├── TROUBLESHOOTING.md
│   ├── DEVELOPMENT.md
│   └── REFERENCE.md
└── README.md (this file)
```

---

## Contributing

See [Development Guide](docs/DEVELOPMENT.md) for:
- Adding custom agents
- Extending validation rules
- Documentation improvements
- Issue reporting

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

**Version:** 2.0.3  
**Last Updated:** 2025-10-06
