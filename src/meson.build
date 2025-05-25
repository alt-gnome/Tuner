sources = files(
    'app.vala'
) + configure_file(
    input: 'build.vala.in',
    output: 'build.vala',
    configuration: config
)

subdir('ui')

executable(
    output,

    sources,
    resources,
    dependencies: lib_dep,
    install: true
)
