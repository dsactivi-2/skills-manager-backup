import { ACME_CHANNEL_NAME } from "./settings.schema";

declare global {
  interface SubscriberChannelDict {
    [ACME_CHANNEL_NAME]: {
      tenantId: string;
      recipientId: string;
    };
  }
}

export {};
