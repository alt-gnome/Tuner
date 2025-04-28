valadoc = find_program('valadoc')

doc_cmd_base = [
    valadoc,
    
    '--package-name=' + name,
    '--package-version=' + meson.project_version(),
    '--target-glib=2.58',
    '--force',
    '--pkg=gee-0.8',
    '--pkg=libadwaita-1',
    '--pkg=libpeas-2',
    '--directory=@OUTPUT@',
    '@INPUT@'
]

valadoc_cmd = [doc_cmd_base, '--doclet=html']

custom_target(
    'valadoc',
    
    command: valadoc_cmd,
    input: lib_sources,
    output: 'valadoc',
    depends: lib,
    install: true,
    install_dir: get_option('datadir') / 'doc' / name)
