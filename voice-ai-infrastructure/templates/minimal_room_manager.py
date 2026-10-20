from flask import Flask, render_template_string
import json
import os
import requests
import asyncio
from livekit.api import LiveKitAPI, ListRoomsRequest

app = Flask(__name__)
# Template includes Tailwind, Lucide Icons, and Glassmorphism
HTML_TEMPLATE = """
... [Tailwind/Lucide Dashboard Template] ...
"""

async def get_rooms():
    # Example for lkapi v0.22+
    try:
        lkapi = LiveKitAPI("http://localhost:7880", "devkey", "secretkey")
        rooms = await lkapi.room.list_rooms(ListRoomsRequest())
        await lkapi.aclose()
        return rooms.rooms
    except: return []

@app.route('/')
def index():
    rooms = asyncio.run(get_rooms())
    return render_template_string(HTML_TEMPLATE, rooms=rooms)

if __name__ == "__main__":
    app.run(port=8080)
