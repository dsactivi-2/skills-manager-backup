/*
 * Hexabot - Fair Core License (FCL-1.0-ALv2)
 * Copyright (c) 2026 Hexastack.
 * Full terms: see LICENSE.md.
 */

import { z } from 'zod';

// This mirrors Hexabot monorepo API source actions. In a standalone
// hexabot-action-* package, replace these imports with the package template's
// public imports or configured TypeScript path aliases after inspecting it.
import { createAction } from '@/actions/create-action';
import { WorkflowRuntimeContext } from '@/workflow/contexts/workflow-runtime.context';

const createCrmTicketInputSchema = z.object({
  subject: z.string().trim().min(1).meta({
    title: 'Subject',
    description: 'Short ticket title shown to the CRM support team.',
  }),
  description: z.string().trim().min(1).meta({
    title: 'Description',
    description: 'Detailed issue or request summary.',
  }),
  requester_email: z.email().meta({
    title: 'Requester email',
    description: 'Email address of the person requesting support.',
  }),
  priority: z.enum(['low', 'normal', 'high']).default('normal').meta({
    title: 'Priority',
    description: 'Ticket priority in the external CRM.',
  }),
  idempotency_key: z.string().trim().min(1).optional().meta({
    title: 'Idempotency key',
    description:
      'Stable key used by the CRM to avoid duplicate tickets when retries occur.',
  }),
});

const createCrmTicketSettingsSchema = z.strictObject({
  base_url: z.url().meta({
    title: 'Base URL',
    description: 'CRM API base URL.',
  }),
  api_key: z.string().optional().meta({
    title: 'Credential',
    description: 'Credential containing the CRM API token.',
    'ui:widget': 'AutoCompleteWidget',
    'ui:options': {
      entity: 'Credential',
      valueKey: 'id',
      labelKey: 'name',
      enableEntityAddButton: true,
    },
  }),
});

const createCrmTicketOutputSchema = z.union([
  z.object({
    success: z.literal(true),
    ticket_id: z.string(),
    status: z.string(),
    url: z.url().optional(),
  }),
  z.object({
    success: z.literal(false),
    status: z.string(),
    error: z.string(),
  }),
]);

type CreateCrmTicketInput = z.infer<typeof createCrmTicketInputSchema>;
type CreateCrmTicketOutput = z.infer<typeof createCrmTicketOutputSchema>;
type CreateCrmTicketSettings = z.infer<typeof createCrmTicketSettingsSchema>;

const normalizeBaseUrl = (baseUrl: string) => baseUrl.replace(/\/+$/, '');

const parseJsonBody = async (response: Response): Promise<unknown> => {
  const text = await response.text();

  if (!text.trim()) {
    return {};
  }

  try {
    return JSON.parse(text) as unknown;
  } catch {
    return { raw: text };
  }
};

const readString = (
  payload: Record<string, unknown>,
  key: string,
): string | undefined => {
  const value = payload[key];

  return typeof value === 'string' && value.trim() ? value : undefined;
};

export const CreateCrmTicketAction = createAction<
  CreateCrmTicketInput,
  CreateCrmTicketOutput,
  WorkflowRuntimeContext,
  CreateCrmTicketSettings
>({
  name: 'create_crm_ticket',
  description:
    'Creates a support ticket in an external CRM using a stored credential reference.',
  group: 'crm',
  icon: 'TicketPlus',
  color: '#2f80ed',
  inputSchema: createCrmTicketInputSchema,
  outputSchema: createCrmTicketOutputSchema,
  settingsSchema: createCrmTicketSettingsSchema,
  async execute({ input, context, settings }) {
    const logger = context.services.logger;
    const token = await context.services.credentials.findOneValue(
      settings.api_key,
    );

    if (!token) {
      throw new Error(
        'Missing CRM credential. Configure the create_crm_ticket api_key setting.',
      );
    }

    const endpoint = `${normalizeBaseUrl(settings.base_url)}/tickets`;
    const timeoutMs = settings.timeout_ms ?? 10000;

    try {
      const response = await fetch(endpoint, {
        method: 'POST',
        headers: {
          authorization: `Bearer ${token}`,
          'content-type': 'application/json',
          ...(input.idempotency_key
            ? { 'idempotency-key': input.idempotency_key }
            : {}),
        },
        body: JSON.stringify({
          subject: input.subject,
          description: input.description,
          requester_email: input.requester_email,
          priority: input.priority,
        }),
        signal: AbortSignal.timeout(timeoutMs),
      });
      const body = await parseJsonBody(response);
      const payload =
        body && typeof body === 'object' && !Array.isArray(body)
          ? (body as Record<string, unknown>)
          : {};

      if (!response.ok) {
        const message =
          readString(payload, 'message') ??
          readString(payload, 'error') ??
          `CRM returned HTTP ${response.status}`;

        logger.warn('create_crm_ticket failed', {
          status: response.status,
          requester_email: input.requester_email,
          idempotency_key: input.idempotency_key,
        });

        return {
          success: false,
          status: String(response.status),
          error: message,
        };
      }

      const ticketId = readString(payload, 'id') ?? readString(payload, 'key');

      if (!ticketId) {
        throw new Error('CRM response did not include a ticket identifier.');
      }

      return {
        success: true,
        ticket_id: ticketId,
        status: readString(payload, 'status') ?? 'created',
        url: readString(payload, 'url'),
      };
    } catch (error) {
      const message =
        error instanceof Error ? error.message : 'Unknown CRM request error';

      logger.warn('create_crm_ticket request error', {
        error: message,
        requester_email: input.requester_email,
        idempotency_key: input.idempotency_key,
      });

      return {
        success: false,
        status: 'request_error',
        error: message,
      };
    }
  },
});

export default CreateCrmTicketAction;
