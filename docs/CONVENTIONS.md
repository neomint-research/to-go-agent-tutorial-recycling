# Naming Conventions

Official naming conventions for the TO-GO Agent Tutorial Recycling project.

**Version:** 2.0.0  
**Date:** 2025-10-05

---

## General Principle

**This project follows standard open source naming conventions.**

When no explicit convention is defined below for a specific element, **default to conventions commonly used in open source projects**.

Examples of open source standards we follow:
- Directories: `src/`, `docs/`, `config/`, `data/`, `test/`
- Files: `README.md`, `LICENSE`, `.gitignore`
- Package names: `my-package-name` (lowercase with dashes)
- Configuration: `.eslintrc.json`, `tsconfig.json`

---

## Directory Naming

**Convention: `lowercase_with_underscores`**

All directories use lowercase with underscores for word separation.

**Examples:**
```
✅ definitions/
✅ data/
✅ temp/
✅ docs/
✅ data/input/
✅ data/1-extract/
✅ data/5-generate/
```

**Rationale:**
- Standard in open source (node_modules/, src/, dist/, config/)
- Platform-independent (no case-sensitivity issues)
- Easier to type (no Shift key needed)
- Consistent with repository name (lowercase with dashes)

**Deprecated:**
```
❌ TO-GO-AGENT_TUTORIAL-RECYCLING/ → use definitions/
❌ DATA/ → use data/
❌ TEMP/ → use temp/
❌ Input/ → use input/
```

---

## File Naming

### Repository and Package Names

**Convention: `lowercase-with-dashes`**

```
✅ to-go-agent-tutorial-recycling
✅ my-package-name
```

### Agent Definition Files

**Convention: `agent-{id}-{name}_v{major}.{minor}.{patch}.json`**

```
✅ agent-1-extract_v2.0.1.json
✅ agent-2-inventory_v2.0.1.json
✅ agent-3-normalize_v2.0.1.json
```

**Components:**
- `agent-` prefix (required)
- `{id}` - numeric identifier (1, 2, 3, etc.)
- `-{name}` - lowercase agent name
- `_v{version}` - semantic version separator
- `.json` extension

### Configuration Files

**Convention: `{name}.config_v{major}.{minor}.{patch}.json`**

```
✅ agent.config_v2.0.1.json
✅ pipeline.config_v1.0.0.json
```

### Schema Files

**Convention: `{name}.schema_v{major}.{minor}.{patch}.json`**

```
✅ task.schema_v2.0.1.json
✅ validation.schema_v1.0.0.json
```

### Stage Output Files

**Convention: `{input_basename}_{stage_name}.json`**

```
✅ tutorial-1_extract.json
✅ tutorial-1_inventory.json
✅ tutorial-1_normalize.json
```

**Basename Preservation:**
- Input: `tutorial-docker.md`
- Stage 1: `tutorial-docker_extract.json`
- Stage 2: `tutorial-docker_inventory.json`
- Final: `tutorial-docker.md` + `tutorial-docker.json`

### Documentation Files

**Convention: `ALLCAPS.md` for major docs, `lowercase.md` for others**

```
✅ README.md (standard)
✅ LICENSE (standard)
✅ CHANGELOG.md (standard)
✅ PIPELINE.md
✅ USAGE.md
✅ TROUBLESHOOTING.md
```

---

## JSON Field Naming

### Field Names

**Convention: `snake_case`**

All JSON field names use snake_case (lowercase with underscores).

```json
✅ "agent_id": 1
✅ "token_allocation_percent": 30
✅ "source_refs": ["chunk_001"]
✅ "input_basename": "tutorial-1"
```

**Rationale:**
- Consistent with Python conventions (common in data science/ML)
- Readable for non-programmers
- No ambiguity (no camelCase vs PascalCase confusion)

### Agent Names (Internal vs Display)

**Internal (in code):** `lowercase`

```json
✅ "name": "extract"
✅ "name": "inventory"
✅ "name": "normalize"
```

**Display (in documentation):** `Title Case`

```json
✅ "name": "Extract" (in agent spec files)
✅ "name": "Inventory"
✅ "name": "Normalize"
```

**Rationale:**
- Internal: Programmatic consistency
- Display: Human readability
- This dual convention is intentional

---

## Semantic Versioning

**Convention: `{major}.{minor}.{patch}`**

```
✅ v2.0.0 - Major release (breaking changes)
✅ v2.1.0 - Minor release (new features, backward compatible)
✅ v2.0.1 - Patch release (bug fixes, no new features)
```

**When to Increment:**

| Type | When | Examples |
|------|------|----------|
| **MAJOR** | Breaking changes | API changes, removed features, incompatible updates |
| **MINOR** | New features (backward compatible) | New agents, enhanced validation, new options |
| **PATCH** | Bug fixes (no new features) | Fixed bugs, documentation updates, typos |

**File Naming with Versions:**
```
✅ agent-1-extract_v2.0.1.json
✅ agent.config_v2.1.0.json
✅ orchestrator.agent_v2.0.1.json
```

---

## Constant and Enum Values

### Status Values

**Convention: `SCREAMING_SNAKE_CASE`**

```json
✅ "status": "CREATED"
✅ "status": "IN_PROGRESS"
✅ "status": "VALIDATED"
✅ "decision": "APPROVE"
✅ "decision": "REJECT"
```

### Severity Levels

**Convention: `SCREAMING_SNAKE_CASE` or `lowercase`**

```json
✅ "severity": "CRITICAL"
✅ "severity": "HIGH"
✅ "event_type": "warning"
✅ "event_type": "error"
```

**Rationale:**
- SCREAMING_SNAKE_CASE for user-facing statuses (visual emphasis)
- lowercase for internal event types (less critical)

---

## ID and Reference Formats

### Chunk IDs

**Convention: `chunk_{:03d}`**

```json
✅ "chunk_001"
✅ "chunk_042"
✅ "chunk_127"
```

**Format:**
- Prefix: `chunk_`
- Zero-padded 3-digit number
- Allows up to 999 chunks per document

### Step IDs (Stage 1-2)

**Convention: `step_{:03d}`**

```json
✅ "step_001"
✅ "step_015"
```

### Normalized Step IDs (Stage 3+)

**Convention: `s{:03d}`**

```json
✅ "s001"
✅ "s015"
```

**Rationale:**
- Shorter for final outputs
- Clear distinction from extraction IDs

### Task IDs

**Convention: `task_{session_id}_{stage_id}`**

```
✅ task_session_20251005_143022_abc123_1
✅ task_session_20251005_143022_abc123_2
```

### Session IDs

**Convention: `session_{YYYYMMDD}_{HHMMSS}_{random}`**

```
✅ session_20251005_143022_abc123
✅ session_20251005_150000_def456
```

---

## Special Cases

### Acronyms and Abbreviations

**Convention: Treat as single word, follow naming convention**

```
✅ html_parser (not HTML_parser)
✅ pdf_reader (not PDF_reader)
✅ api_client (not API_client)
✅ json_schema (not JSON_schema)
```

**Exception:** When acronym is the entire word
```
✅ HTML.md (document name)
✅ JSON.schema (file extension context)
```

### Compound Words

**Convention: Use underscore to separate**

```
✅ input_file
✅ output_directory
✅ token_allocation
✅ source_refs
```

### Boolean Fields

**Convention: Use `is_` or `has_` prefix, snake_case**

```json
✅ "is_valid": true
✅ "has_errors": false
✅ "include_examples": true
```

---

## Git Conventions

### Branch Names

**Convention: `type/description-with-dashes`**

```
✅ feature/batch-processing
✅ fix/validation-bug
✅ docs/update-readme
✅ refactor/naming-conventions
```

### Commit Messages

**Convention: Conventional Commits**

```
✅ feat: add batch processing mode
✅ fix: correct path validation
✅ docs: update installation guide
✅ refactor: migrate to lowercase directories
```

**Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `refactor:` - Code change (no behavior change)
- `test:` - Adding tests
- `chore:` - Maintenance tasks

---

## Code Style (Future)

When adding TypeScript/JavaScript/Python code to the project, follow these conventions:

### TypeScript/JavaScript

```typescript
✅ camelCase for variables and functions
✅ PascalCase for classes and types
✅ SCREAMING_SNAKE_CASE for constants
```

### Python

```python
✅ snake_case for variables and functions
✅ PascalCase for classes
✅ SCREAMING_SNAKE_CASE for constants
```

---

## Default to Open Source Standards

**Critical Rule:** When in doubt, **default to what is standard in open source projects**.

### Examples of Open Source Conventions

**Directories:**
```
src/ config/ dist/ build/ test/ docs/
node_modules/ .github/ public/
```

**Files:**
```
README.md LICENSE .gitignore
package.json tsconfig.json
.env .eslintrc
```

**Field Names (varies by ecosystem):**
- JavaScript: `camelCase`
- Python: `snake_case`
- **This project (JSON):** `snake_case`

**Why Follow Open Source Standards?**
1. **Familiarity** - Developers recognize patterns immediately
2. **Tooling** - Tools expect standard names
3. **Professionalism** - Shows knowledge of conventions
4. **Compatibility** - Reduces friction across platforms

---

## Changelog

### v2.0.0 (2025-10-05)

**Changed:**
- All directories to lowercase (definitions/, data/, temp/)
- Added general principle: "Default to open source conventions"
- Clarified when to use lowercase vs SCREAMING_SNAKE_CASE
- Added docs/ directory to conventions

**Added:**
- Explicit "Default to Open Source Standards" section
- Examples of open source conventions
- Branch naming conventions
- Commit message conventions

**Deprecated:**
- UPPERCASE directory names (TO-GO-AGENT_TUTORIAL-RECYCLING/, DATA/, TEMP/)

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
