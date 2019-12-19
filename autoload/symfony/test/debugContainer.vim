let s:output = [
  \ 'Public services','===============','','Definitions','-----------',
  \ '','### 2dddee08c27b93eaed1e7c6fcc1abd2b324e0edf3a1aacdd1a0cac97967937d1_1',
  \ '- Class: `DummyClass`',
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
  \ '','']

source ../console.vim
let g:symfonyNvimCamelCaseServiceNames = v:true

let s:services = symfony#console#_parseDebugContainer(0, [ '' ], s:output)

let v:errors = []

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

call assert_match('acme.awesomeFeature.orm.entity', s:services[3].name)

echom join(v:errors, "\n\r")
