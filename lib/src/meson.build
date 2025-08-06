deps = [
    dependency('libadwaita-1'),
    dependency('libpeas-2'),
    dependency('gee-0.8')
]

subdir('addins')
subdir('bindings')
subdir('ui')
subdir('utils')

lib_sources += files(
    'main.vala'
)

install_data(
    'deps.in',

    rename: lib_output + '.deps',
    install_dir: get_option('datadir') / 'vala' / 'vapi'
)

lib = library(
    lib_output,

    lib_resources,
    lib_sources,
    dependencies: deps,
    soversion: soversion,
    vala_gir: gir_output + '.gir',
    install: true,
    install_dir: [ true, true, true, true ]
)

pkg.generate(
    name: name,
    description: 'Tuner app plugin library',

    libraries: lib,
    version: version,
    subdirs: lib_output,
    filebase: lib_output,
    requires: deps
)

custom_target(
    'typelib',

    command: [
        find_program('g-ir-compiler'),

        '--shared-library=' + lib.full_path().split('/')[-1],
        '--output=@OUTPUT@',
        meson.current_build_dir() / (gir_output + '.gir')
    ],
    output: gir_output + '.typelib',
    depends: lib,
    install: true,
    install_dir: get_option('libdir') / 'girepository-1.0'
)

lib_dep = declare_dependency(
    link_with: lib,
    dependencies: deps,
    include_directories: include_directories('.')
)
