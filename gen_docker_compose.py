#!/usr/bin/env python3

import os
import sys
import yaml
import logging

logging.basicConfig(
    format="[%(asctime)s] - %(levelname)s - %(message)s", level=logging.INFO
)


if len(sys.argv) != 2:
    print("Usage: python3 gen_docker_compose.py <PUBLIC_IP>")
    sys.exit(1)

PUBLIC_IP = sys.argv[1]
BASE_PORT = 1337

TEMP = """
container_name: chal-{chal}
image: chal-{chal}
build:
  context: {chal}/challenge/project
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

dirs = os.listdir(".")
port = BASE_PORT
for i, chal in enumerate(dirs):
    if (
        os.path.isdir(chal)
        and os.path.exists(f"{chal}/challenge.yaml")
        and os.path.exists(f"{chal}/challenge/Dockerfile.local")
    ):
        logging.info("Found challenge: '%s' with port: %d", chal, port)
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

logging.info("Found %d challenges", len(chals))
logging.info("Writing docker-compose.yml")
with open("docker-compose.yml", "w") as f:
    yaml.dump(compose, f, sort_keys=False)
