# Dispatcher wake vs hangup vs import

Three clocks. Do not collapse them when the user asks what a Schedule node does.

| Piece | Job |
|---|---|
| Import workflow | Sheet → queue table (e.g. every 3h). Not a call. |
| Dispatcher Schedule | Wake: "window open, try one queued lead if slots free". First call of the day. Backup if hangup event lost. |
| LiveKit `room_finished` | Chain: hang up → free slot → **new** dispatcher run. This is the normal next-call. |

Hourly cron is not "one conversation per hour". One dispatcher **run** starts at most one call. Parallel cap (e.g. 4) is a count of `status=calling` rows. Between cron ticks, hangup events refill slots.

Without cron: queue full, silence until someone runs the dispatcher by hand — nobody has hung up yet at 09:00.

Window example (Europe/Berlin): Mo–Fr `0 9-17 * * 1-5`, Sa `0 10-13 * * 6`. Last start 17:00 / 13:00 so a call can still sit inside 18:00 / 14:00. Never Execute / Test this trigger on a draft that can SIP.
