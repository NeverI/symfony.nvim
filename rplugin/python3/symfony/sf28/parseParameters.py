import re

class ParameterParser:
    def __init__(self):
        self.parameters = dict()

    def parse(self, lines):
        for line in lines:
            self._parseLine(line)

        return self.parameters

    def _parseLine(self, line):
        match = re.match(r'^- `([\w\._]+)`: `(.+)`$', line)
        if not match:
            return None

        self.parameters[match.group(1)] = match.group(2)
