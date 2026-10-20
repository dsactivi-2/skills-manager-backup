# Developer message

Use this order.

1. **Identity** — purpose, style, goal.
2. **Instructions** — what to do and what never to do, including tool-call rules.
3. **Examples** — diverse inputs with the desired outputs.
4. **Context** — private or retrieved data for this request only.

Markdown headers mark sections. XML tags mark a span of data. Put metadata the instructions refer to in attributes.

Copy [assets/developer-message.txt](../assets/developer-message.txt) into the feature module and fill it. Pass the file contents as `instructions`. Pass only the new user request as `input`.

## Code-generation shape

```text
# Identity

You are a coding assistant that enforces snake_case variables in JavaScript
and code that runs in Internet Explorer 6.

# Instructions

* Name variables in snake_case (my_variable), not camelCase (myVariable).
* Declare variables with var.
* Return only the code. No Markdown.

# Examples

<user_query>
How do I declare a string variable for a first name?
</user_query>

<assistant_response>
var first_name = "Anna";
</assistant_response>
```

Input for that prompt: `How would I declare a variable for a last name?`

## Few-shot shape

Put examples in the developer message. Vary the inputs. Match each example to its answer with the same `id`.

```text
# Identity

You label short product reviews as Positive, Negative, or Neutral.

# Instructions

* Output one word: Positive, Negative, or Neutral.
* No formatting and no commentary.

# Examples

<product_review id="example-1">
I absolutely love these headphones — sound quality is amazing!
</product_review>

<assistant_response id="example-1">
Positive
</assistant_response>

<product_review id="example-2">
Battery life is okay, but the ear pads feel cheap.
</product_review>

<assistant_response id="example-2">
Neutral
</assistant_response>

<product_review id="example-3">
Terrible customer service, I'll never buy from them again.
</product_review>

<assistant_response id="example-3">
Negative
</assistant_response>
```

The live review goes in `input`, not in the examples block.

## Context shape

```text
# Context

<source id="policy-2026" title="Return policy">
...retrieved passage...
</source>
```

Tell the instructions which tags they may use. Leave this section out of the cached prefix when its text changes per request.
