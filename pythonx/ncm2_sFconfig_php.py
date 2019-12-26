# -*- coding: utf-8 -*-

import vim
from ncm2 import Ncm2Source, getLogger, Popen
import re

import subprocess
import json

logger = getLogger(__name__)

class Source(Ncm2Source):
    def __init__(self, nvim):
        super(Source, self).__init__(nvim)
        self.completionTimeout = self.nvim.vars['ncm2_phpactor_timeout'] or 5

    def on_complete(self, context):
        result, errs = self._getPhpActorRpc() \
            .communicate(
                self._getRpcRequest(context),
                timeout=self.completionTimeout
            )

        result = result.decode()

        if not result:
            return

        result = json.loads(result)

        matches = []
        for item in self._getSuggestions(result):
            matches.append(item['short_description'])

        self.complete(context, context['startccol'], matches)

    def _getPhpActorRpc(self):
        command = [
            self.nvim.vars['phpactorPhpBin'],
            self.nvim.vars['phpactorbinpath'],
            'rpc',
            '--working-dir=' + self.nvim.vars['phpactorInitialCwd']
        ]

        return Popen(
            args=command,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL
        )

    def _getRpcRequest(self, context):
        text = '<?php namespace NvimSymfony; use '
        request = json.dumps({
            'action': 'complete',
            'parameters': {
                'type': 'php',
                'source': text + context['base'],
                'offset': len(text) + (context['ccol'] - context['startccol'])
            }
        })

        return self.get_src(request, context).encode()

    def _getSuggestions(self, result):
        return result \
            .get('parameters', {}) \
            .get('value', {}) \
            .get('suggestions', []) \

source = Source(vim)
on_complete = source.on_complete
