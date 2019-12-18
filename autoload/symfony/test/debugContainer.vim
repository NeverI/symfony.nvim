let s:output = [
  \ 'Public services','===============','','Definitions','-----------',
  \ '','### acme.awesome.service','',
  \ '- Class: `Acme\AwesomeBundle\Service`',
  \ '- Scope: `container`',
  \ '- Public: yes',
  \ '- Synthetic: no',
  \ '- Lazy: no',
  \ '- Shared: no',
  \ '- Synchronized: no',
  \ '- Abstract: no',
  \ '- Autowired: no',
  \ '','### acme.awesomefeature.menuelem.group','',
  \ '- Class: `Acme\AwesomeFeatureBundle\MenuElem\Group`',
  \ '- Scope: `container`',
  \ '- Public: no',
  \ '- Synthetic: no',
  \ '- Lazy: no',
  \ '- Shared: yes',
  \ '- Synchronized: no',
  \ '- Abstract: yes',
  \ '- Autowired: no',
  \ '- Tag: `application.menu.group`',
  \ '    - Group: application.menu',
  \ '','### acme.awesomefeature.elemdescriptor.entity','',
  \ '- Class: `Acme\AwesomeFeatureBundle\MenuElemDescriptor\GroupEntity`',
  \ '','']

source ../../symfony.vim
source ../console.vim
let g:symfonyNvimCamelCaseServiceNames = v:true

call symfony#init('/tmp/')
call symfony#console#_parseDebugContainer(0, [ '' ], s:output)

let v:errors = []

let s:services = symfony#getServices()

call assert_match('acme.awesome.service', s:services[0].name)
call assert_match('Acme\\AwesomeBundle\\Service', s:services[0].class)
call assert_match(v:true, s:services[0].public)
call assert_match(v:false, s:services[0].shared)
call assert_match(v:false, s:services[0].abstract)

call assert_match('acme.awesomeFeature.menuElem.group', s:services[1].name)
call assert_match('Acme\\AwesomeFeatureBundle\\MenuElem\\Group', s:services[1].class)
call assert_match(v:false, s:services[1].public)
call assert_match(v:true, s:services[1].shared)
call assert_match(v:true, s:services[1].abstract)

call assert_match('acme.awesomeFeature.elemDescriptor.entity', s:services[2].name)
call assert_match('Acme\\AwesomeFeatureBundle\\MenuElemDescriptor\\GroupEntity', s:services[2].class)

echom join(v:errors, "\n\r")
