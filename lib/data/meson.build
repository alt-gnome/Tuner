subdir('ui')

lib_resources = gnome.compile_resources(
    'lib-resources',
    'gresource.xml',
    source_dir: meson.current_build_dir(),
    dependencies: custom_target(
        'lib-blueprints',
        input: lib_blueprints,
        output: '.',
        command: [ find_program('blueprint-compiler'), 'batch-compile', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@' ],
    )
)
