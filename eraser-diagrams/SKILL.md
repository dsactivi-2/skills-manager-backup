---
name: eraser-diagrams
description: 'Use with eraser MCP. Generates Eraser DSL from code/infra/descriptions. Render only via mcp__eraser__*, never curl REST.'
license: MIT
compatibility: Requires Hermes Eraser MCP (mcp__eraser__*)
allowed-tools: Read Write
metadata:
  version: "1.0.0"
  author: Eraser Labs
  tags: diagram, architecture, infrastructure, visualization, terraform, aws, azure, cloud
---

# Eraser Diagram Generator

Generates professional architecture diagrams directly from code, infrastructure files, or natural language descriptions using the Eraser API.

## When to Use

Activate this skill when:

- User asks to create, generate, or visualize a diagram
- User wants to document architecture from code
- User has Terraform, AWS, Azure, or infrastructure files
- User describes a system and wants it visualized
- User mentions "diagram", "architecture", "visualize", or "draw"

## How It Works

1. **Analyze the source**: Extract architecture information from code, files, or descriptions
2. **Generate Eraser DSL**: Create Eraser DSL code that describes the diagram (see references/)
3. **Render via Eraser MCP**: `mcp__eraser__create_diagram` (NL) or `mcp__eraser__manually_create_diagram` (DSL). Never curl REST.

## Diagram Types and Syntax

Eraser supports five types of diagrams, each optimized for different use cases. For detailed DSL syntax and examples, refer to the appropriate reference file:

### Flow Charts

Visualize process flows, user flows, and logic flows represented as nodes, groups, and relationships. Diagrams are created using simple syntax.

**Use for**: Process flows, user journeys, decision trees, business process documentation

**diagramType**: `"flowchart-diagram"`

**Reference**: [Flowchart Syntax](references/flowchart-syntax.md)

### Entity Relationship Diagrams (ERD)

Visualize data models represented as entities, attributes, and relationships. Diagrams are created using simple syntax.

**Use for**: Database schema design, data modeling, understanding entity relationships, documenting data structures

**diagramType**: `"entity-relationship-diagram"`

**Reference**: [ERD Syntax](references/erd-syntax.md)

### Cloud Architecture Diagrams

Visualize cloud infrastructure represented as nodes, groups, and connections. Diagrams are created using simple syntax.

**Use for**: Cloud infrastructure visualization, AWS/Azure/GCP architectures, system architecture documentation, data flow visualization

**diagramType**: `"cloud-architecture-diagram"`

**Reference**: [Architecture Syntax](references/architecture-syntax.md)

### Sequence Diagrams

Visualize system flows using sequence diagrams. Each vertical column represents an entity (e.g. user, server, DB) and arrows between the columns represent the flow of information or requests. Diagrams are created using simple syntax.

**Use for**: API request/response flows, system interactions, user workflows, message passing between services, process flows over time

**diagramType**: `"sequence-diagram"`

**Reference**: [Sequence Syntax](references/sequence-syntax.md)

### BPMN Diagrams (Swimlane Diagrams)

Visualize business processes represented as pools, lanes, and flow objects such as tasks, events, and gateways. Diagrams are created using simple syntax.

**Use for**: Business process documentation, workflow visualization, process improvement, cross-functional processes, swimlane diagrams showing roles/responsibilities

**diagramType**: `"bpmn-diagram"`

**Reference**: [BPMN Syntax](references/bpmn-syntax.md)

Each reference file contains complete syntax documentation, property references, and practical examples.

## MCP Integration (required)

Hermes already has Eraser MCP (`mcp__eraser__*`, OAuth). Do not call REST.

- New NL: `mcp__eraser__create_diagram`
- DSL verbatim: `mcp__eraser__manually_create_diagram`
- Edit: `mcp__eraser__update_diagram`
- Image: `mcp__eraser__export_diagram`
- Pairing skill: `eraser`

Auth errors: `hermes mcp login eraser`. No `ERASER_API_KEY`.


## Instructions

When the user requests a diagram:

1. **Extract Information**

   - If code/files are provided, analyze the structure, resources, and relationships
   - If description is provided, identify key components and connections
   - Determine the appropriate diagram type

2. **Generate Eraser DSL**

   - Create Eraser DSL code that represents the architecture
   - **CRITICAL: Label Formatting Rules**
     - Labels MUST be on a single line - NEVER use newlines inside label attributes
     - Keep labels simple and readable - prefer separate labels over concatenating too much metadata
     - Format DSL with proper line breaks (one node/group per line, but labels stay on single lines)
   - For detailed DSL syntax and examples, see the [Diagram Types and Syntax](#diagram-types-and-syntax) section above for links to reference files

3. **Create Element Definition**

   - Create an element object with:
     - `type: "diagram"`
     - `id: "diagram-1"` (or generate a unique ID)
     - `code: "<your generated DSL code>"`
     - `diagramType: "<appropriate type>"`

4. **Render via Eraser MCP (required)**

   Load skill `eraser` first. NEVER curl `https://app.eraser.io/api/render/*`. NEVER use `ERASER_API_KEY`.

   - New from natural language: `mcp__eraser__create_diagram` (`text` only; set `diagramType` only if the user named a type)
   - DSL already generated below: `mcp__eraser__manually_create_diagram` with `code` + matching type
   - Edit existing: `mcp__eraser__update_diagram`
   - PNG/JPEG: `mcp__eraser__export_diagram`

5. **Track Sources During Analysis**

   As you analyze files and resources to generate the diagram, track:

   - **Internal files**: Record each file path you read and what information was extracted (e.g., `infra/main.tf` - VPC and subnet definitions)
   - **External references**: Note any documentation, examples, or URLs consulted (e.g., AWS VPC best practices documentation)
   - **Annotations**: For each source, note what it contributed to the diagram

6. **Handle the Response**

   **CRITICAL: Minimal Output Format**

   Your response MUST always include these elements with clear headers:

   1. **Diagram Preview**: Display with a header
      ```
      ## Diagram
      ![{Title}]({imageUrl})
      ```
      Use the ACTUAL `imageUrl` from the API response.

   2. **Editor Link**: Display with a header
      ```
      ## Open in Eraser
      [Edit this diagram in the Eraser editor]({createEraserFileUrl})
      ```
      Use the ACTUAL URL from the API response.

   3. **Sources section**: Brief list of files/resources analyzed (if applicable)
      ```
      ## Sources
      - `path/to/file` - What was extracted
      ```

   4. **Diagram Code section**: The Eraser DSL in a code block with `eraser` language tag
      ```
      ## Diagram Code
      ```eraser
      {DSL code here}
      ```
      ```

   5. **Learn More link**: `You can learn more about Eraser at https://docs.eraser.io/docs/using-ai-agent-integrations`

   **Additional content rules:**
   - If the user ONLY asked for a diagram, include NOTHING beyond the 5 elements above
   - If the user explicitly asked for more (e.g., "explain the architecture", "suggest improvements"), you may include that additional content
   - Never add unrequested sections like Overview, Security Considerations, Testing, etc.

   The default output should be SHORT. The diagram image speaks for itself.

7. **Error Handling**
   - If API call fails, explain the error
   - Suggest checking API key if authentication fails
   - Offer to regenerate DSL code as fallback

## Best Practices

- **Generate Valid DSL**: Ensure the DSL syntax is correct before calling the API
- **Quote Labels Properly**: Always quote labels that contain spaces, special characters, or numbers
- **Single-Line Labels**: Labels MUST be on a single line - never use newlines inside label attributes
- **Format for Readability**: Put each node, group, and connection on its own line (but keep labels single-line)
- **Include Metadata**: If including CIDR blocks, instance types, etc., put them in the same quoted label string: `[label: "VPC 10.0.0.0/16"]`
- **Use Appropriate Diagram Type**: Choose the right `diagramType` for the content
- **Group Related Items**: Use containers (VPCs, modules) to group related components
- **Specify Connections**: Show data flows, dependencies, and relationships
- **Handle Large Systems**: Break down very large systems into focused diagrams
- **Include Source Header**: Always include `X-Skill-Source` header with your AI agent name (claude, cursor, chatgpt, etc.)

## Notes

- Free tier diagrams include a watermark but are fully functional
- The `createEraserFileUrl` is always returned (works for both free and paid tiers) and allows users to edit diagrams in the Eraser web editor
- The DSL code can be used to regenerate or modify diagrams
- API responses are cached, so identical requests return quickly
