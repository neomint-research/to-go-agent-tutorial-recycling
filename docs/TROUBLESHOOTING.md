# Troubleshooting Guide

Solutions to common issues when running the TO-GO Agent Tutorial Recycling pipeline.

---

## Quick Diagnostic

Before diving into specific issues, run this checklist:

```bash
# 1. Verify repository structure
ls definitions/
# Should show: 8 JSON files (orchestrator, agent.config, task.schema, 5 agent specs)

# 2. Check data directories
ls data/
# Should show: input/, 1-extract/, 2-inventory/, 3-normalize/, 4-configure/, 5-generate/

# 3. Verify MCP connection
# In Claude Desktop: Look for hammer icon in input box

# 4. Check task tracker
ls data/task-tracker*.json
# Review latest session log for errors
```

---

## Filesystem Access Issues

### Hammer Icon Missing

**Symptoms:**
- No hammer icon in Claude Desktop input box
- "Access denied" errors when trying to read files
- Orchestrator can't load files

**Cause:** MCP server not configured or not running

**Solutions:**

1. **Verify MCP configuration:**
   - Open Claude Desktop Settings → Developer → Edit Config
   - Check for filesystem server entry:
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

2. **Verify path is absolute:**
   - ❌ Wrong: `to-go-agent-tutorial-recycling`
   - ❌ Wrong: `~/projects/to-go-agent-tutorial-recycling`
   - ✅ Correct (macOS/Linux): `/Users/username/projects/to-go-agent-tutorial-recycling`
   - ✅ Correct (Windows): `C:\Users\username\projects\to-go-agent-tutorial-recycling`

3. **Restart Claude Desktop:**
   - Quit Claude Desktop completely
   - Reopen application
   - Check for hammer icon

4. **Verify Node.js installed:**
   ```bash
   node --version
   # Should show: v18.0.0 or higher
   ```

5. **Check filesystem permissions:**
   ```bash
   ls -la /path/to/to-go-agent-tutorial-recycling
   # Verify you have read/write permissions
   ```

### File Not Found Errors

**Symptoms:**
- "File not found" when loading orchestrator
- "Access denied - path outside allowed directories"

**Cause:** MCP server not configured with correct path

**Solutions:**

1. **Check Claude Desktop config:**
   - Verify path in MCP config matches actual repository location
   - Use `pwd` (Unix) or `cd` (Windows) to get exact path

2. **Verify repository cloned:**
   ```bash
   cd /path/to/to-go-agent-tutorial-recycling
   git status
   # Should show: On branch main
   ```

3. **Check file exists:**
   ```bash
   ls definitions/orchestrator.agent_v2.0.1.json
   # Should show the file
   ```

---

## Pipeline Execution Issues

### Agent Definition Not Found

**Symptoms:**
- "Agent definition not found" error
- Pipeline aborts at initialization

**Cause:** Missing or incorrectly named agent files

**Solution:**

Verify all 8 required files exist:

```bash
cd definitions/
ls -1

# Expected output:
# agent-1-extract_v2.0.1.json
# agent-2-inventory_v2.0.1.json
# agent-3-normalize_v2.0.1.json
# agent-4-configure_v2.0.1.json
# agent-5-generate_v2.0.1.json
# agent.config_v2.0.1.json
# orchestrator.agent_v2.0.1.json
# task.schema_v2.0.1.json
```

**If files missing:**
- Re-clone repository: `git pull origin main`
- Or copy missing files from GitHub release

---

### Validation Failures

**Symptoms:**
- "Schema validation failed" error
- "Forbidden patterns detected" error
- Pipeline retries then aborts

**Cause:** Output doesn't meet quality standards

**Solutions:**

1. **Review validation errors in task-tracker:**
   ```bash
   cat data/task-tracker_session_*.json
   ```
   
   Look for:
   ```json
   {
     "validation_result": {
       "decision": "REJECT",
       "failure_reasons": [
         "Schema validation failed: missing required field 'ordinal'",
         "Forbidden pattern detected: emoji in content"
       ]
     }
   }
   ```

2. **Common validation issues:**

   **Emojis/Icons in source:**
   - Remove emojis from input files
   - Pipeline rejects any Unicode emoji characters
   
   **Malformed Markdown:**
   - Check for unclosed code blocks
   - Verify proper heading hierarchy
   - Ensure UTF-8 encoding
   
   **Incomplete source content:**
   - Source might be too short (< 100 words)
   - Missing required sections
   - No actionable steps found

3. **Debug specific file:**
   - Isolate problem file in data/input/
   - Process alone
   - Review each stage output
   - Fix source issues

---

### Token Overflow

**Symptoms:**
- "Token overflow" error
- "CONTINUATION_REQUIRED" status
- Pipeline retries multiple times

**Cause:** Tutorial too large for allocated token budget

**Solutions:**

1. **Check token usage in task-tracker:**
   ```json
   {
     "token_usage": 65000,
     "agent_id": 1,
     "note": "Exceeded 60000 token allocation"
   }
   ```

2. **Adjust token allocations:**
   
   Edit `definitions/agent.config_v2.0.1.json`:
   
   ```json
   {
     "agents": [
       {
         "agent_id": 1,
         "token_allocation_percent": 35  // Increase from 30
       },
       {
         "agent_id": 5,
         "token_allocation_percent": 45  // Increase from 40
       }
     ]
   }
   ```

3. **Alternative - Split large files:**
   ```bash
   # Split 10,000-line tutorial into 2 files
   split -l 5000 large-tutorial.md tutorial-part-
   mv tutorial-part-aa data/input/tutorial-part-1.md
   mv tutorial-part-ab data/input/tutorial-part-2.md
   ```

4. **Re-process:**
   ```
   Process all files in data/input/
   ```

---

### Structure Integrity Violations

**Symptoms:**
- "Unauthorized files detected" error
- "Structure integrity violation" error
- Pipeline aborts immediately

**Cause:** Files created in wrong directories or modified files in definitions directory

**Solutions:**

1. **Check what violated structure:**
   ```bash
   cat data/error-report.json
   ```
   
   Example:
   ```json
   {
     "error": "Structure integrity violation",
     "details": "Unauthorized file in definitions directory",
     "file": "definitions/my-notes.txt"
   }
   ```

2. **Remove unauthorized files:**
   ```bash
   # Move to temp for review
   mv definitions/my-notes.txt temp/
   ```

3. **Verify structure matches manifest:**
   ```bash
   cat project.manifest.json
   # Review required_structure
   ```

4. **Common violations:**
   - Creating files in `definitions/` during runtime
   - Modifying agent definition files during execution
   - Wrong file extensions in data directories
   - Extra directories in root

---

## Profile Configuration Issues

### Profile Validation Failed

**Symptoms:**
- "Profile validation failed" error
- Stage 4 (Configure) fails

**Cause:** Invalid profile.json syntax or values

**Solutions:**

1. **Verify JSON syntax:**
   ```bash
   cat data/profile.json
   # Check for:
   # - Missing commas
   # - Unclosed braces
   # - Invalid quotes
   ```

2. **Validate against schema:**
   
   Valid values only:
   ```json
   {
     "os": "linux|windows|macos|null",
     "experience": "beginner|intermediate|advanced|null",
     "hardware": "cpu|gpu|null",
     "language": "string|null"
   }
   ```

3. **Common mistakes:**
   
   ❌ Wrong:
   ```json
   {
     "os": "Linux",           // Wrong: capital L
     "experience": "expert",  // Wrong: should be "advanced"
     "hardware": "CPU"        // Wrong: capital letters
   }
   ```
   
   ✅ Correct:
   ```json
   {
     "os": "linux",
     "experience": "advanced",
     "hardware": "cpu"
   }
   ```

4. **If unsure, remove profile:**
   ```bash
   mv data/profile.json temp/profile.json.backup
   # Process without profile - all variants included
   ```

---

## Input File Issues

### Unsupported File Format

**Symptoms:**
- "Unsupported file format" error
- Stage 1 fails to parse file

**Cause:** File extension not recognized

**Solutions:**

1. **Verify supported formats:**
   - ✅ `.md` - Markdown
   - ✅ `.html` - HTML
   - ✅ `.pdf` - PDF
   - ❌ `.docx` - Not supported
   - ❌ `.txt` - Not supported (use .md instead)

2. **Convert unsupported formats:**
   ```bash
   # Convert .docx to .md using pandoc
   pandoc input.docx -o output.md
   
   # Rename .txt to .md
   mv tutorial.txt tutorial.md
   ```

3. **Re-process:**
   ```
   Process all files in data/input/
   ```

### Malformed Source Content

**Symptoms:**
- Extraction succeeds but chunks are wrong
- Steps not identified correctly
- Missing content in outputs

**Cause:** Source file has formatting issues

**Solutions:**

1. **Check for common issues:**
   
   **Unclosed code blocks:**
   ```markdown
   ```python
   def hello():
       print("world")
   # Missing closing ```
   ```
   
   **Invalid heading structure:**
   ```markdown
   # Title
   ### Subtitle  ❌ Skipped level 2
   ## Section    ✅ Should come before ###
   ```

2. **Validate Markdown:**
   ```bash
   # Use markdownlint or similar
   markdownlint data/input/*.md
   ```

3. **Verify UTF-8 encoding:**
   ```bash
   file data/input/tutorial.md
   # Should show: UTF-8 Unicode text
   ```

4. **Fix and re-process:**
   - Correct formatting issues
   - Save as UTF-8
   - Process again

---

## Output Quality Issues

### Missing Steps

**Symptoms:**
- Final output has fewer steps than expected
- Steps excluded without clear reason

**Cause:** Steps might be filtered by profile or not detected as imperatives

**Solutions:**

1. **Check exclusions in Stage 4 output:**
   ```bash
   cat data/4-configure/tutorial_configure.json
   ```
   
   Look for:
   ```json
   {
     "exclusions": [
       {
         "item_id": "s003",
         "reason": "Windows-specific (profile.os=linux)",
         "content_preview": "Install using PowerShell..."
       }
     ]
   }
   ```

2. **Verify step detection in Stage 1:**
   ```bash
   cat data/1-extract/tutorial_extract.json
   ```
   
   Check `steps` array - should contain all imperative actions

3. **Common step detection issues:**
   - Source uses passive voice ("Dependencies should be installed")
   - Steps phrased as descriptions ("The next thing to do is...")
   - No clear action verbs (Install, Configure, Run, etc.)

4. **Fix source content:**
   - Rephrase as imperatives: "Install dependencies"
   - Use action verbs: "Run the server"
   - Make steps explicit: "Step 1: Configure environment"

### Code Blocks Modified

**Symptoms:**
- Code in output differs from source
- Missing lines or altered syntax

**Cause:** Should NEVER happen - this is a critical bug

**Solutions:**

1. **Verify code fidelity:**
   ```bash
   diff <(grep -A10 '```python' data/input/tutorial.md) \
        <(grep -A10 '```python' data/5-generate/tutorial.md)
   ```

2. **If differences found:**
   - Document exact differences
   - Check Stage 1 extraction output
   - Review validation logs
   - Report as critical issue

3. **Workaround:**
   - Manually restore code from source
   - Note: This should not be necessary

**Note:** 100% code fidelity is a core requirement. Any deviation is a critical bug.

---

## Performance Issues

### Slow Processing

**Symptoms:**
- Pipeline takes > 5 minutes per file
- Long delays between stages

**Cause:** Large files, complex content, or token budget issues

**Solutions:**

1. **Check file sizes:**
   ```bash
   ls -lh data/input/
   # Files > 1MB might be slow
   ```

2. **Split large files:**
   ```bash
   split -l 1000 large-file.md small-file-
   ```

3. **Review token usage:**
   ```bash
   cat data/task-tracker*.json | grep token_usage
   ```

4. **Optimize token allocations:**
   - Reduce percentages if under-utilized
   - Increase for bottleneck stages

### Memory Issues

**Symptoms:**
- Claude Desktop crashes or freezes
- "Out of memory" errors

**Cause:** Processing too many large files simultaneously

**Solutions:**

1. **Process in smaller batches:**
   ```bash
   # Instead of 50 files, process 10 at a time
   mkdir data/batch-1/
   mv data/input/file-{1..10}.md data/batch-1/
   ```

2. **Restart Claude Desktop between batches:**
   - Clears memory
   - Prevents accumulation

---

## Getting Help

If issues persist after trying these solutions:

1. **Gather diagnostic information:**
   ```bash
   # Collect these files
   cp data/task-tracker*.json diagnostics/
   cp data/error-report.json diagnostics/
   cp definitions/*.json diagnostics/
   ```

2. **Create minimal reproduction:**
   - Isolate single failing file
   - Document exact steps to reproduce
   - Include error messages

3. **Check project repository:**
   - GitHub Issues: https://github.com/neomint-research/to-go-agent-tutorial-recycling/issues
   - Documentation: https://github.com/neomint-research/to-go-agent-tutorial-recycling

4. **Contact support:**
   - Email: research@neomint.com
   - Include: diagnostics folder, reproduction steps, error messages

---

## Preventive Maintenance

### Before Each Run

```bash
# 1. Verify structure
ls -la definitions/ data/

# 2. Clear old outputs (optional)
rm -rf data/1-extract/* data/2-inventory/* data/3-normalize/* data/4-configure/* data/5-generate/*

# 3. Backup important data
cp -r data/5-generate BACKUP-$(date +%Y%m%d)/

# 4. Verify MCP connection
# Check hammer icon in Claude Desktop
```

### After Each Run

```bash
# 1. Review task tracker
cat data/task-tracker*.json | grep status

# 2. Verify outputs
ls data/5-generate/

# 3. Archive completed session
mkdir archives/session-$(date +%Y%m%d-%H%M%S)/
mv data/task-tracker*.json archives/session-*/
cp -r data/5-generate/* archives/session-*/
```

---

## Next Steps

- **[Pipeline Documentation →](PIPELINE.md)** - Deep dive into the 5 stages
- **[Usage Guide →](USAGE.md)** - Common workflows and patterns
- **[Development Guide →](DEVELOPMENT.md)** - Extending the pipeline
- **[Complete Reference →](REFERENCE.md)** - Detailed specifications

---

**Version:** 2.0.0  
**Last Updated:** 2025-10-05
