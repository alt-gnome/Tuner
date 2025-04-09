deps = [
    dependency('libadwaita-1'),
    dependency('libpeas-2')
]

sources = files(
    'app.vala',
) + configure_file(
    input: 'build.vala.in',
    output: 'build.vala',
    configuration: config
)

subdir('addins')
subdir('ui')
subdir('widgets')

install_data(
    'deps.in',
    
    rename: output + '.deps',
    install_dir: get_option('datadir') / 'vala' / 'vapi'
)

lib = library(
    output,

    resources,
    sources,
    dependencies: deps,
    install: true,
    install_dir: [true, true, true]
)

pkg.generate(
    name: meson.project_name(),
    description: 'Tuner app plugin library',
    
    libraries: lib,
    version: meson.project_version(),
    subdirs: output,
    filebase: output,
    requires: [ 'libadwaita-1', 'libpeas-2' ]
)

lib_dep = declare_dependency(
    link_with: lib,
    include_directories: include_directories('.')
)

executable(
    output,
    
    files('main.vala'),
    dependencies: deps + lib_dep,
    install: true,
)
