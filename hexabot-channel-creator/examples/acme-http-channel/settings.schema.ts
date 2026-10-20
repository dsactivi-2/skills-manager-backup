import z from "zod";

export const ACME_CHANNEL_NAME = "acme" as const;

const credentialSetting = (title: string, description: string) =>
  z
    .string()
    .default("")
    .meta({
      title,
      description,
      "ui:widget": "AutoCompleteWidget",
      "ui:options": {
        entity: "Credential",
        valueKey: "id",
        labelKey: "name",
        enableEntityAddButton: true,
      },
    });

export const ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA = z
  .strictObject({
    api_url: z.url().default("https://api.acme.example").meta({
      title: "API URL",
      description: "Base URL for Acme messaging requests.",
    }),
    api_key: credentialSetting(
      "API key credential",
      "Credential containing the Acme API key.",
    ),
    webhook_secret: credentialSetting(
      "Webhook secret credential",
      "Credential containing the Acme signing secret.",
    ),
    tenant_id: z.string().default("").meta({
      title: "Tenant ID",
      description: "Optional tenant filter for inbound events.",
    }),
  })
  .meta({ title: "Acme Channel" });

export type AcmeChannelSettings = z.infer<
  typeof ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA
>;
