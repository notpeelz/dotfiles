" Preserve existing doge settings.
let b:doge_patterns = get(b:, 'doge_patterns', {})
let b:doge_supported_doc_standards = get(b:, 'doge_supported_doc_standards', [])
if index(b:doge_supported_doc_standards, 'rustdoc_custom') < 0
  call add(b:doge_supported_doc_standards, 'rustdoc_custom')
endif

" Set the new doc standard as default.
let b:doge_doc_standard = 'rustdoc_custom'

" Ensure we do not overwrite an existing doc standard.
if !has_key(b:doge_patterns, 'rustdoc_custom')
  let b:doge_patterns['rustdoc_custom'] = [
        \  {
        \    'nodeTypes': ['function_item'],
        \    'parameters': {
        \      'format': '* `{name}` !description',
        \    },
        \    'template': [
        \      '/// !description',
        \      '%(parameters|///)%',
        \      '%(parameters|/// # Arguments)%',
        \      '%(parameters|///)%',
        \      '%(parameters|/// {parameters})%',
        \      '%(unsafe|///)%',
        \      '%(unsafe|/// # Safety)%',
        \      '%(unsafe|///)%',
        \      '%(unsafe|/// !description)%',
        \      '%(errors|///)%',
        \      '%(errors|/// # Errors)%',
        \      '%(errors|///)%',
        \      '%(errors|/// !description)%',
        \    ],
        \  },
        \]
endif
