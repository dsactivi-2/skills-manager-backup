---
name: n8n-workflow-review
description: Review and debug existing n8n workflows with evidence. Use for audits, execution failures, Soll-Ist analysis, and approved safe Pin-data tests; not for building, changing, or publishing workflows.
metadata:
  version: "2.1"
  language: de
  type: review-protocol
---

# n8n Workflow Review

Review existing workflows first. Do not create, update, publish, archive, or
change credentials as part of this skill.

Before any n8n action, use `using-n8n-skills-official` and load the relevant
official skill for the task. The live MCP tool schema is authoritative; do not
guess server prefixes, tool aliases, or node parameters.

## Review

1. Resolve the workflow with `search_workflows` and fetch it using
   `get_workflow_details`.
2. Derive a concise intended contract from the graph, description, and notes.
   Mark uncertain intent as `ANNAHME`.
3. Record triggers, nodes, connections, branches, side effects, error paths,
   sub-workflows, and expressions.
4. Use `search_workflow_executions` for a relevant time window. Inspect a
   bounded success or error execution with `get_workflow_execution` only when
   it answers the review question.
5. For unclear or high-risk node configuration, use `get_node_types` and,
   where available, `validate_node_config`.
6. Report claims with the evidence tags and verdicts in
   [review-evidence.md](references/review-evidence.md).

If an MCP-created workflow is not found, ask the user to confirm that MCP
access is enabled for UI-created workflows before assuming it is absent.

## Testing

Never run `test_workflow` merely to explore. It can execute non-pinned nodes.
Before testing, state the workflow, goal, synthetic input, pinned nodes,
remaining real nodes, and possible side effects. Wait for explicit approval.

After approval, call `prepare_workflow_pin_data`, build data from its returned
schema, and run the smallest useful test. State what the pin test does not
prove. See [review-evidence.md](references/review-evidence.md).

## Debugging

For a failure, first identify the symptom, failing node, and direct upstream
data from an execution. Compare the saved graph and actual node shape before
proposing a fix. Report one primary cause with evidence and a prioritized
recommendation; do not patch the workflow.

## Handoff

If the user asks to change or publish after the review, finish the report and
then use `n8n-workflow-lifecycle-official` and the needed official n8n skills.
Obtain a separate approval before the first write or live execution.
