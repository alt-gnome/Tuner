valadoc = find_program('valadoc')

valadoc_cmd = [
    valadoc,

    '--package-name=' + lib_output,
    '--package-version=' + version,
    '--force',
    '--pkg=gee-0.8',
    '--pkg=libadwaita-1',
    '--pkg=libpeas-2',
    '--doclet=html',
    '--directory=@OUTPUT@',
    '@INPUT@'
]

custom_target(
    'valadoc',

    command: valadoc_cmd,
    input: lib_sources,
    output: 'valadoc',
    depends: lib,
    install: true,
    install_dir: get_option('datadir') / 'doc' / output
)
