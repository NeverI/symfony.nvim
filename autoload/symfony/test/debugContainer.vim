let s:output = ['Public services','===============','','Definitions','-----------','','### acme.awesome.service','','- Class: `Acme\AwesomeBundle\Service`','- Scope: `container`','- Public: yes','- Synthetic: no','- Lazy: no','- Shared: no','- Synchronized: no','- Abstract: no','- Autowired: no','','### acme.awesome.menu','','- Class: `Acme\AwesomeBundle\Menu\Group`','- Scope: `container`','- Public: yes','- Synthetic: no','- Lazy: no','- Shared: yes','- Synchronized: no','- Abstract: no','- Autowired: no','- Tag: `application.menu.group`','    - Group: application.menu','','']

source ../../symfony.vim
source ../console.vim

call symfony#init('/tmp/')
call symfony#console#_parseDebugContainer(0, [ '' ], s:output)

let v:errors = []
call assert_match('acme.awesome.service', symfony#get().services[0].name)
call assert_match('acme.awesome.menu', symfony#get().services[1].name)

echom join(v:errors, "\n\r")
