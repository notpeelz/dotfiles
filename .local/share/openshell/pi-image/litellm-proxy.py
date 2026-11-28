#!/usr/bin/env python3
"""Loopback reverse proxy: OpenShell sandboxes -> LiteLLM on the LAN.

OpenShell resolves sandbox egress with its own trusted DNS resolver, so a
split-horizon name such as litellm.crank.peelzfreak.com resolves to the public
record, which serves an expired certificate. Sandboxes can reach the host
through the special name host.openshell.internal (127.0.0.1), so this proxy
takes the placeholder-authenticated HTTP request from the sandbox and forwards
it to the LAN endpoint, where the host's own resolver and the valid certificate
apply. OpenShell substitutes the placeholder credential before it arrives here.

Listen on loopback only: host.openshell.internal maps to 127.0.0.1, so nothing
is exposed to the LAN or the internet.
"""

import aiohttp
from aiohttp import web

UPSTREAM = "https://litellm.crank.peelzfreak.com"
LISTEN_HOST = "127.0.0.1"
LISTEN_PORT = 8787
TIMEOUT = aiohttp.ClientTimeout(total=None, connect=15, sock_read=600)
HOP_BY_HOP = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailers",
    "transfer-encoding",
    "upgrade",
    "host",
    "content-length",
}


async def handle(request: web.Request) -> web.StreamResponse:
    url = UPSTREAM + request.path_qs
    headers = {
        key: value
        for key, value in request.headers.items()
        if key.lower() not in HOP_BY_HOP
    }
    body = await request.read()

    async with aiohttp.ClientSession(
        timeout=TIMEOUT, auto_decompress=False
    ) as session:
        async with session.request(
            request.method, url, headers=headers, data=body or None
        ) as upstream:
            response_headers = [
                (key, value)
                for key, value in upstream.headers.items()
                if key.lower() not in HOP_BY_HOP
            ]
            stream = web.StreamResponse(
                status=upstream.status, headers=response_headers
            )
            await stream.prepare(request)
            async for chunk in upstream.content.iter_any():
                await stream.write(chunk)
            await stream.write_eof()
            return stream


def main() -> None:
    app = web.Application(client_max_size=0)
    app.router.add_route("*", "/{tail:.*}", handle)
    web.run_app(
        app,
        host=LISTEN_HOST,
        port=LISTEN_PORT,
        print=None,
        access_log=None,
    )


if __name__ == "__main__":
    main()
