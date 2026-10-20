import z from "zod";

export namespace Acme {
  const partySchema = z.looseObject({ id: z.string() });

  export const eventSchema = z.looseObject({
    id: z.string(),
    occurred_at: z.number(),
    tenant_id: z.string(),
    sender: partySchema,
    recipient: partySchema,
    message: z.looseObject({ text: z.string() }),
  });

  export const webhookSchema = z.looseObject({
    events: z.array(eventSchema),
  });

  export type Event = z.infer<typeof eventSchema>;
  export type SendResponse = { id?: string };
}
