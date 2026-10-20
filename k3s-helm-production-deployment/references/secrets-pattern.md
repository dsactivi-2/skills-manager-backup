# Secrets Pattern (Best Practice)

## Recommended Structure
```
deploy/
  values.prod.yaml
  secrets.env          # .gitignore
  deploy-prod.sh
```

## Workflow
1. Create `secrets.env` with all credentials
2. Load via `--from-env-file` in the deploy script
3. Never commit `secrets.env`

## Why
- Keeps credentials out of git
- Easy to rotate
- Works with both Helm and raw kubectl

This pattern was established during the LightRAG (Perfekt!) k3s deployment.