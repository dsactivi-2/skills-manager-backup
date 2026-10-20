# Safe Browse Behavior

`hermes skills browse` only loads a paginated view from the registry. It does **not**:
- Install skills
- Enable skills
- Modify `.hub/` contents
- Change any profile state

User explicitly confirmed concern about accidental activation. Always state clearly that browse is read-only when user asks.