import { createHmac, timingSafeEqual } from "crypto";

import {
  ChannelCapabilities,
  ChannelInboundEvent,
  ChannelInboundEventContext,
  CredentialService,
  DEFAULT_CHANNEL_CAPABILITIES,
  HttpChannelHandler,
  MessageInboundEvent,
  SubscriberCreateDto,
  SyntheticMessageInboundEvent,
} from "@hexabot-ai/api";
import {
  ActionOptions,
  IncomingMessageType,
  OutgoingMessageType,
  Source,
  StdOutgoingMessageEnvelope,
} from "@hexabot-ai/types";
import { Inject, Injectable } from "@nestjs/common";
import { ModuleRef } from "@nestjs/core";
import { Request, Response } from "express";

import {
  ACME_CHANNEL_NAME,
  ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA,
  AcmeChannelSettings,
} from "./settings.schema";
import { Acme } from "./types";

type RawBodyRequest = Request & { rawBody?: string | Buffer };

@Injectable()
export default class AcmeChannelHandler extends HttpChannelHandler<
  typeof ACME_CHANNEL_NAME
> {
  @Inject(ModuleRef)
  private readonly credentialsModuleRef!: ModuleRef;

  private credentialService?: CredentialService;

  constructor() {
    super(ACME_CHANNEL_NAME, ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA);
  }

  getCapabilities(): ChannelCapabilities {
    return {
      ...DEFAULT_CHANNEL_CAPABILITIES,
      [OutgoingMessageType.quickReply]: false,
      [OutgoingMessageType.buttons]: false,
      [OutgoingMessageType.attachment]: false,
      [OutgoingMessageType.list]: false,
      [OutgoingMessageType.carousel]: false,
      typingIndicator: false,
      maxTextLength: 2000,
    };
  }

  protected async verifySignature(
    req: Request,
    _res: Response,
    source: Source,
  ): Promise<void> {
    const settings = this.parseSettings(source.settings);
    const secret = await this.resolveCredential(settings.webhook_secret);
    const signature = req.header("x-acme-signature")?.replace(/^sha256=/, "");
    const rawBody = (req as RawBodyRequest).rawBody;

    if (!secret || !signature || rawBody === undefined) {
      throw new Error("Missing Acme webhook authentication data");
    }

    const expected = createHmac("sha256", secret).update(rawBody).digest("hex");
    const actualBytes = Buffer.from(signature, "hex");
    const expectedBytes = Buffer.from(expected, "hex");

    if (
      actualBytes.length !== expectedBytes.length ||
      !timingSafeEqual(actualBytes, expectedBytes)
    ) {
      throw new Error("Invalid Acme webhook signature");
    }
  }

  protected async decode(
    req: Request,
    source: Source,
  ): Promise<ChannelInboundEvent<typeof ACME_CHANNEL_NAME>[]> {
    const settings = this.parseSettings(source.settings);
    const payload = Acme.webhookSchema.parse(req.body);

    return payload.events.flatMap((rawEvent) => {
      if (settings.tenant_id && rawEvent.tenant_id !== settings.tenant_id) {
        return [];
      }

      const context = new ChannelInboundEventContext(
        ACME_CHANNEL_NAME,
        rawEvent,
        {
          tenantId: rawEvent.tenant_id,
          recipientId: rawEvent.recipient.id,
        },
        this.toDate(rawEvent.occurred_at),
        rawEvent.id,
        rawEvent.sender.id,
        rawEvent.recipient.id,
      );

      return [
        new SyntheticMessageInboundEvent(
          context,
          {
            type: IncomingMessageType.text,
            data: { text: rawEvent.message.text },
          },
          IncomingMessageType.text,
        ),
      ];
    });
  }

  protected async doSendMessage(
    event: MessageInboundEvent<typeof ACME_CHANNEL_NAME>,
    envelope: StdOutgoingMessageEnvelope,
    _options: ActionOptions,
  ): Promise<{ mid: string }> {
    if (envelope.type !== OutgoingMessageType.text) {
      throw new Error(`Unsupported Acme message type: ${envelope.type}`);
    }

    const settings = this.parseSettings(event.getSourceSettings());
    const apiKey = await this.resolveCredential(settings.api_key);

    if (!apiKey) {
      throw new Error("Missing Acme API key");
    }

    const response = await fetch(`${settings.api_url}/messages`, {
      method: "POST",
      headers: {
        authorization: `Bearer ${apiKey}`,
        "content-type": "application/json",
      },
      body: JSON.stringify({
        to: event.getSenderForeignId(),
        text: envelope.data.text,
      }),
    });

    if (!response.ok) {
      throw new Error(`Acme send failed with HTTP ${response.status}`);
    }

    const body = (await response.json()) as Acme.SendResponse;

    if (!body.id) {
      throw new Error("Acme send response did not include a message id");
    }

    return { mid: body.id };
  }

  async getSubscriberData(
    event: MessageInboundEvent<typeof ACME_CHANNEL_NAME>,
  ): Promise<SubscriberCreateDto> {
    return {
      foreignId: event.getSenderForeignId(),
      firstName: "Acme",
      lastName: "User",
      assignedTo: null,
      assignedAt: null,
      lastvisit: new Date(),
      retainedFrom: new Date(),
      avatar: null,
      channel: event.getChannelData(),
      language: "",
      locale: "",
      timezone: 0,
      gender: null,
      country: null,
      labels: [],
      source: event.getSourceId() ?? "",
    };
  }

  private parseSettings(settings: unknown): AcmeChannelSettings {
    return ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA.parse(settings ?? {});
  }

  private async resolveCredential(id: string): Promise<string> {
    const credentialId = id.trim();

    if (!credentialId) {
      return "";
    }

    this.credentialService ??= this.credentialsModuleRef.get(
      CredentialService,
      { strict: false },
    );

    return (await this.credentialService.findOneValue(credentialId)).trim();
  }

  private toDate(timestamp: number): Date {
    const milliseconds =
      timestamp < 100_000_000_000 ? timestamp * 1000 : timestamp;
    const date = new Date(milliseconds);

    return Number.isNaN(date.getTime()) ? new Date() : date;
  }
}
