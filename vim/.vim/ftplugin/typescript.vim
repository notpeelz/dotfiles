" Preserve existing doge settings.
let b:doge_patterns = get(b:, 'doge_patterns', {})
let b:doge_supported_doc_standards = get(b:, 'doge_supported_doc_standards', [])
if index(b:doge_supported_doc_standards, 'tsdoc') < 0
  call add(b:doge_supported_doc_standards, 'tsdoc')
endif

" Set the new doc standard as default.
let b:doge_doc_standard = 'tsdoc'

" Ensure we do not overwrite an existing doc standard.
if !has_key(b:doge_patterns, 'tsdoc')
  let b:doge_patterns['tsdoc'] = [
    \ {
    \   'nodeTypes': ['class_declaration', 'class'],
    \   'typeParameters': {
    \     'format': '@typeParam {name|!name} - !description',
    \   },
    \   'template': [
    \     '/**',
    \     ' * !description',
    \     '%(typeParameters| * {typeParameters})%',
    \     ' */',
    \   ],
    \ },
    \ {
    \   'nodeTypes': ['member_expression'],
    \   'parameters': {
    \     'format': '@param %(showType|{{type|!type}})% %(default|[)%{name|!name}%(default|])% - !description',
    \   },
    \   'exceptions': {
    \     'format': '@throws {{name|!name}} - !description',
    \   },
    \   'template': [
    \     '/**',
    \     ' * !description',
    \     ' *',
    \     ' * @function {functionName}#{propertyName}',
    \     '%(typeParameters| * {typeParameters})%',
    \     '%(parameters| * {parameters})%',
    \     '%(exceptions| * {exceptions})%',
    \     '%(returnType| * @returns {{returnType|!type}} !description)%',
    \     ' */',
    \   ],
    \ },
    \ {
    \   'nodeTypes': [
    \     'arrow_function',
    \     'function',
    \     'function_declaration',
    \     'function_signature',
    \     'method_definition',
    \     'generator_function',
    \     'generator_function_declaration',
    \   ],
    \   'parameters': {
    \     'format': '@param %(showType|{{type|!type}})% %(optional|[)%{name|!name}%(optional|])% - !description',
    \   },
    \   'typeParameters': {
    \     'format': '@template {name|!name} - !description',
    \   },
    \   'exceptions': {
    \     'format': '@throws {{name|!name}} - !description',
    \   },
    \   'template': [
    \     '/**',
    \     ' * !description',
    \     ' *',
    \     '%(typeParameters| * {typeParameters})%',
    \     '%(parameters| * {parameters})%',
    \     '%(exceptions| * {exceptions})%',
    \     '%(returnType| * @returns)% %(showReturnType|{{returnType|!type}})% %(returnType|!description)%',
    \     ' */',
    \   ],
    \ },
    \ ]
endif
