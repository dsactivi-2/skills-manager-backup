# startCall opening mechanics

## Two layers
| Field | Use |
|-------|-----|
| `greeting` | Short identity before LLM |
| `prompt` | After greeting: reason + permission only |

## Config
- `delayed_start` true, ~1–2s  
- `allow_interrupt` on open: prefer **false** (docs: finish greeting)  
- later nodes: interrupt often true  

## Never
Product catalog or COD in `greeting`  
Re-introduce full name if greeting already did  

## BS example shape
greeting: "Dobar dan, ovdje Amina, {{business_name}}."  
prompt: no re-intro; one why; "20 sekundi?"; edges only.
