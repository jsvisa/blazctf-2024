#!/usr/bin/env python3

import re
import os
import sys
import yaml


def is_valid_ipv4(address: str) -> bool:
    # Regular expression for validating an IPv4 address
    ipv4_regex = r"^(\d{1,3}\.){3}\d{1,3}$"

    # Check if the address matches the IPv4 pattern
    if re.match(ipv4_regex, address):
        # Split the address into parts
        parts = address.split(".")

        # Check if there are 4 parts
        if len(parts) == 4:
            # Check the range of each part [0, 255]
            for part in parts:
                if not part.isdigit() or not 0 <= int(part) <= 255:
                    return False
            return True
    return False


if len(sys.argv) != 2:
    print("Usage: python3 gen_docker_compose.py <PUBLIC_IP>")
    sys.exit(1)

PUBLIC_IP = sys.argv[1]

if not is_valid_ipv4(PUBLIC_IP) or PUBLIC_IP == "127.0.0.1":
    print("Invalid IP address or localhost")
    sys.exit(1)
BASE_PORT = 1337

TEMP = """
image: chal-{chal}
container_name: chal-{chal}
build:
  context: {chal}/challenge/
  dockerfile: Dockerfile.local
command: socat TCP-LISTEN:1337,reuseaddr,fork exec:"python3 -u challenge/challenge.py"
environment:
  - ENV=prod
  - CHALLENGE_ID={chal}
  - PUBLIC_HOST=http://{PUBLIC_IP}
  - BACKEND=docker
  - DATABASE=redis
  - REDIS_URL=redis://database:6379/0
  - TEAM_MANAGER=http://easy-ticket:7766
expose:
  - 1337
ports:
  - "{port}:1337"
networks:
  - ctf_network
"""


chals = {}

dirs = sorted(os.listdir("."))
port = BASE_PORT
for i, chal in enumerate(dirs):
    if (
        chal != "infrastructure"
        and os.path.isdir(chal)
        and os.path.exists(f"{chal}/challenge.yaml")
        and os.path.exists(f"{chal}/challenge/Dockerfile.local")
    ):
        print("Found challenge: '%s' with port: %d", chal, port)
        service = TEMP.format(chal=chal, port=port, PUBLIC_IP=PUBLIC_IP)
        chals[chal] = yaml.safe_load(service)
        port += 1

compose = {
    "name": "paradigm-ctf-challenge",
    "services": chals,
    "networks": {
        "ctf_network": {"name": "paradigmctf", "external": True},
    },
}

print("Found %d challenges", len(chals))
print("Writing docker-compose.yml")
with open("docker-compose.yml", "w") as f:
    yaml.dump(compose, f, sort_keys=False)
