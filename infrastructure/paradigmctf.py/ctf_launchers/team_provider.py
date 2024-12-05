import abc
import os
import random
import string
from dataclasses import dataclass
from typing import Optional
import requests


RANDOM_TICKET = os.getenv("RANDOM_TICKET", "true") == "true"
TEAM_MANAGER = os.getenv("TEAM_MANAGER", "http://team-manager")


def generate_random_ticket(length=40):
    characters = string.ascii_letters + string.digits
    random_string = "".join(random.choice(characters) for _ in range(length))
    return random_string


class TeamProvider(abc.ABC):
    @abc.abstractmethod
    def get_team(self) -> Optional[str]:
        pass


class TicketTeamProvider(TeamProvider):
    @dataclass
    class Ticket:
        challenge_id: str

    def __init__(self, challenge_id):
        self.__challenge_id = challenge_id

    def get_team(self):
        if RANDOM_TICKET:
            print("1. Get a new ticket")
            print("2. Use an existing ticket")
            try:
                choice = int(input("action? "))
                assert choice in [1, 2]
            except:
                print("can you not")
                return None
            if choice == 1:
                ticket_value = generate_random_ticket()
                print(f"Your ticket is: {ticket_value} (keep it safe!)")
            else:
                ticket_value = input("ticket? ").strip()
        else:
            ticket_value = input("ticket? ").strip()
        team_id = self.__check_ticket(ticket_value)
        if not team_id:
            print("invalid ticket!")
            return None

        return "team-" + team_id

    def __check_ticket(self, ticket: str) -> Optional[str]:
        ticket_info = requests.post(
            f"{TEAM_MANAGER}/api/internal/check-ticket",
            json={"ticket": ticket, "challenge_id": self.__challenge_id},
        ).json()

        if not ticket_info["ok"]:
            return None

        if ticket_info["ticket"]["challengeId"] != self.__challenge_id:
            return None

        return ticket_info["ticket"]["teamId"]


class StaticTeamProvider(TeamProvider):
    def __init__(self, team_id, ticket):
        self.__team_id = team_id
        self.__ticket = ticket

    def get_team(self) -> str | None:
        ticket = input("ticket? ")

        if ticket != self.__ticket:
            print("invalid ticket!")
            return None

        return self.__team_id


class LocalTeamProvider(TeamProvider):
    def __init__(self, team_id):
        self.__team_id = team_id

    def get_team(self):
        return self.__team_id


def get_team_provider() -> TeamProvider:
    env = os.getenv("ENV", "local")
    if env == "local":
        return LocalTeamProvider(team_id="local")
    elif env == "dev":
        return StaticTeamProvider(team_id="dev", ticket="dev2023")
    else:
        return TicketTeamProvider(challenge_id=os.getenv("CHALLENGE_ID"))
