import re

class EntityParser:
    def __init__(self):
        self.entities = []

    def parse(self, lines):
        for line in lines:
            self._parseLine(line)

        return self.entities

    def _parseLine(self, line):
        match = re.match(r'^\[OK\]\s+([\w\\]+)$', line)
        if not match:
            return None

        self.entities.append(match.group(1))
