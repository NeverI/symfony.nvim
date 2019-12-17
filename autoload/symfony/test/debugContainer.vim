let s:output = ['Public services','===============','','Definitions','-----------','','### acme.awesome.service','','- Class: `Acme\AwesomeBundle\Service`','- Scope: `container`','- Public: yes','- Synthetic: no','- Lazy: no','- Shared: no','- Synchronized: no','- Abstract: no','- Autowired: no','','### acme.awesomefeature.menuelem.group','','- Class: `Acme\AwesomeFeatureBundle\MenuElem\Group`','- Scope: `container`','- Public: no','- Synthetic: no','- Lazy: no','- Shared: yes','- Synchronized: no','- Abstract: yes','- Autowired: no','- Tag: `application.menu.group`','    - Group: application.menu','','']

source ../../symfony.vim
source ../console.vim

call symfony#init('/tmp/')
call symfony#console#_parseDebugContainer(0, [ '' ], s:output)

let v:errors = []
call assert_match('acme.awesome.service', symfony#get().services[0].name)
call assert_match('Acme\\AwesomeBundle\\Service', symfony#get().services[0].class)
call assert_match(v:true, symfony#get().services[0].public)
call assert_match(v:false, symfony#get().services[0].shared)
call assert_match(v:false, symfony#get().services[0].abstract)

call assert_match('acme.awesomefeature.menuelem.group', symfony#get().services[1].name)
call assert_match('Acme\\AwesomeFeatureBundle\\MenuElem\\Group', symfony#get().services[1].class)
call assert_match(v:false, symfony#get().services[1].public)
call assert_match(v:true, symfony#get().services[1].shared)
call assert_match(v:true, symfony#get().services[1].abstract)

echom join(v:errors, "\n\r")
