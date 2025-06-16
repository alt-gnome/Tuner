icons_dir = join_paths(get_option('datadir'), 'icons', 'hicolor')
scalable_dir = join_paths(icons_dir, 'scalable', 'apps')
symbolic_dir = join_paths(icons_dir, 'symbolic', 'apps')

install_data(
    'icons' / 'app' / 'color.svg',
    rename: id + '.svg',
    install_dir: scalable_dir
)

install_data(
    'icons' / 'app' / 'symbolic.svg',
    rename: id + '-symbolic.svg',
    install_dir: symbolic_dir
)

desktop_file = i18n.merge_file(
    input: 'desktop.in',
    output: id + '.desktop',
    po_dir: meson.project_source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
    test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
    input: 'id.metainfo.xml.in',
    output: id + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

appstreamcli = find_program('appstreamcli', required: false)
if appstreamcli.found()
    test(
        'Validate appstream file',
        appstreamcli,
        args: ['validate', appstream_file]
    )
endif

subdir('ui')

resources = gnome.compile_resources(
    'resources',
    'gresource.xml',
    source_dir: meson.current_build_dir(),
    dependencies: custom_target(
        'blueprints',
        input: blueprints,
        output: '.',
        command: [ find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@' ]
    )
)

install_data(
    'id.gschema.xml',
    rename: id + '.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas'
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
    test(
        'Validate schema file',
        compile_schemas,
        args: ['--strict', '--dry-run', meson.current_source_dir()]
    )
endif
