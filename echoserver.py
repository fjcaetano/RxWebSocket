#!/usr/bin/env python

import asyncio
import websockets
import sys

PORT = sys.argv[1]

async def echo(websocket, path):
    async for message in websocket:
        await websocket.send(message)

async def test_connection():
    async with websockets.connect('ws://127.0.0.1:'+PORT) as websocket:
        await websocket.send('hello')
        await websocket.recv()

async def main():
    await websockets.serve(echo, '127.0.0.1', PORT)
    await asyncio.wait_for(test_connection(), 3)

if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main())
    loop.run_forever()
