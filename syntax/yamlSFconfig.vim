if exists("b:current_syntax")
    finish
endif

runtime! syntax/yaml.vim

syntax keyword yamlSFconfigKeyword parameters services events tags class arguments calls parent
highlight link yamlSFconfigKeyword Label

syntax match yamlSFconfigParameterDef "\v^\s\s[a-zA-Z._]+:"
highlight link yamlSFconfigParameterDef Typedef

syntax match yamlSFconfigServiceDef "\v^\s\s[a-zA-Z._]+:$"
highlight link yamlSFconfigServiceDef Type

syntax match yamlSFconfigConstant "\v[A-Z_]{2,}"
highlight link yamlSFconfigConstant Constant

syntax region yamlSFconfigParameter start="\v\%" end="\v\%"
highlight link yamlSFconfigParameter Define

syn region yamlSFconfigFold start="^\s\s[a-z]" end="^$" transparent fold

let b:current_syntax = "yamlSFconfig"
