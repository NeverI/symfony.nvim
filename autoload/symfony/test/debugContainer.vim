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
  \ '','### acme.awesomefeature.orm.entity','',
  \ '- Class: `Acme\AwesomeFeatureBundle\ORM\entity`',
  \ '','### acme.awesomefeature.alias.service','',
  \ '- Service: `acme.awesomefeature.menuelem.group`',
  \ '','']

source ../console.vim
let g:symfonyNvimCamelCaseServiceNames = v:true

let s:services = symfony#console#_parseDebugContainer(0, [ '' ], s:output)

let v:errors = []

let s:service = has_key(s:services, 'acme.awesome.service') ? s:services['acme.awesome.service'] : v:null
call assert_match('acme.awesome.service', s:service.name)
call assert_match('Acme\\AwesomeBundle\\Service', s:service.class)
call assert_match(v:true, s:service.public)
call assert_match(v:false, s:service.shared)
call assert_match(v:false, s:service.abstract)

let s:service = has_key(s:services, 'acme.awesomefeature.menuelem.group') ? s:services['acme.awesomefeature.menuelem.group'] : v:null
call assert_match('acme.awesomeFeature.menuElem.group', s:service.name)
call assert_match('Acme\\AwesomeFeatureBundle\\MenuElem\\Group', s:service.class)
call assert_match(v:false, s:service.public)
call assert_match(v:true, s:service.shared)
call assert_match(v:true, s:service.abstract)

let s:service = has_key(s:services, 'acme.awesomefeature.elemdescriptor.entity') ? s:services['acme.awesomefeature.elemdescriptor.entity'] : v:null
call assert_match('acme.awesomeFeature.elemDescriptor.entity', s:service.name)
call assert_match('Acme\\AwesomeFeatureBundle\\MenuElemDescriptor\\GroupEntity', s:service.class)

let s:service = has_key(s:services, 'acme.awesomefeature.orm.entity') ? s:services['acme.awesomefeature.orm.entity'] : v:null
call assert_match('acme.awesomeFeature.orm.entity', s:service.name)

let s:service = has_key(s:services, 'acme.awesomefeature.alias.service') ? s:services['acme.awesomefeature.alias.service'] : v:null
call assert_match('acme.awesomeFeature.alias.service', s:service.name)
call assert_match('acme.awesomefeature.menuelem.group', s:service.aliasSource)

echom join(v:errors, "\n\r")
