# LiveKit API Versioning & Usage Notes

## SDK v0.22.0+ (Breaking Change)
The Python SDK for LiveKit has moved from a service-based client architecture to a consolidated `LiveKitAPI` object.

### Old Way (v0.8.x - v0.10.x)
```python
from livekit import api
# This will likely fail with AttributeError: module 'livekit.api' has no attribute 'RoomServiceClient'
lk_api = api.RoomServiceClient(URL, KEY, SECRET)
rooms = await lk_api.list_rooms(api.ListRoomsRequest())
```

### New Way (v0.22.x+)
```python
from livekit.api import LiveKitAPI, ListRoomsRequest

# Using context manager is preferred
async with LiveKitAPI(URL, KEY, SECRET) as lkapi:
    rooms = await lkapi.room.list_rooms(ListRoomsRequest())
    for room in rooms.rooms:
        print(room.name)
```

## SIP Integration (LiveKit SIP)
- **Redis Requirement**: The SIP gateway container *requires* a Redis backend for state management. Failing to provide `REDIS_ADDRESS` will cause an immediate crash loop.
- **Port 5060**: Is used for SIP signaling. It must be open for UDP and TCP traffic for Twilio/Asterisk to reach the gateway.

## Environment Variables
- `LIVEKIT_URL`: Should use `http://livekit:7880` (Docker internal) or `http://localhost:7880` (Host).
- `LIVEKIT_API_KEY`: Default "devkey".
- `LIVEKIT_API_SECRET`: Default "secretkey".
