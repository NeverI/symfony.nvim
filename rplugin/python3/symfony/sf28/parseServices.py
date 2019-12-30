import re

class ServiceParser:
    def __init__(self):
        self.services = dict()
        self.currentService = None

    def parse(self, lines, parameters, camelCase):
        for line in lines:
            self._serCurrentService(line)

            if not self.currentService:
                continue

            if self._matchClass(line, parameters, camelCase):
                continue
            elif self._matchBoolean(line, 'Public'):
                continue
            elif self._matchBoolean(line, 'Shared'):
                continue
            elif self._matchBoolean(line, 'Abstract'):
                continue
            elif self._matchAlias(line, camelCase):
                continue

        return self.services

    def _serCurrentService(self, line):
        serviceName = re.match(r'^### ([\w\._]+)$', line)
        if not serviceName:
            return self.currentService

        self.currentService = {
            'name': serviceName.group(1),
            'class': '',
            'public': True,
            'shared': True,
            'abstract': False,
            'aliasSource': '',
            }

        self.services[self.currentService['name']] = self.currentService
        return self.currentService

    def _matchClass(self, line, parameters, camelCase):
        serviceClass = re.match(r'^- Class: `([\w\\]+)`$', line)
        if not serviceClass:
            return False

        self.currentService['class'] = serviceClass.group(1)
        classAsParameter = re.match(r'^%([\w\._])%', self.currentService['class'])
        if classAsParameter:
            self.currentService['classParameter'] = classAsParameter.group(1)
            if classAsParameter.group(1) in parameters:
                self.currentService['class'] = parameters[classAsParameter.group(1)]

        if camelCase:
            self.currentService['name'] = self._restoreCamelCase(self.currentService['name'], self.currentService['class'].split('\\'))

        return True

    def _restoreCamelCase(self, name, splittedSource):
        splittedName = name.split('.')

        for i in range(len(splittedName)):
            for sourcePart in splittedSource:
                namePart = splittedName[i]
                partIndex = sourcePart.lower().find(namePart)
                if partIndex == -1 or sourcePart.upper() == sourcePart:
                    continue

                splittedName[i] = sourcePart[partIndex:(partIndex + len(namePart))]
                splittedName[i] = splittedName[i][0].lower() + splittedName[i][1:]

        return '.'.join(splittedName)

    def _matchBoolean(self, line, prop):
        value = re.match(r'^- ' + prop + r': (yes|no)$', line)
        if not value:
            return False

        self.currentService[prop.lower()] = value.group(1) == 'yes'

        return True

    def _matchAlias(self, line, camelCase):
        match = re.match(r'^- Service: `([\w\._]+)`$', line)
        if not match:
            return False

        serviceName = match.group(1)
        if serviceName not in self.services:
            raise Exception('Missing alias source for service:' + serviceName)

        self.currentService['aliasSource'] = serviceName
        if camelCase:
            aliasedService = self.services[serviceName]
            self.currentService['name'] = self._restoreCamelCase( \
                    self.currentService['name'], aliasedService['name'].split('.'))
            self.currentService['name'] = self._restoreCamelCase( \
                    self.currentService['name'], aliasedService['class'].split('\\'))
        return True
