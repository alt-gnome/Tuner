project(
    'Tuner',

    ['c', 'vala'],
    version: '0.3.0',
    meson_version: '>= 1.0',
)

id = 'org.altlinux.Tuner'
name = meson.project_name()
version = meson.project_version()
output = name.to_lower()
soversion = 0

add_global_arguments([
	'-Wno-unused',
	'-Wno-discarded-qualifiers'
], language: 'c')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(output),
    language: 'c'
)

add_project_arguments(
    [ '--vapidir', meson.current_source_dir() / 'vapi' ],
    language: 'vala'
)

pkg = import('pkgconfig')
gnome = import('gnome')
i18n = import('i18n')

config = configuration_data()
config.set('ID', id)
config.set('VERSION', version)
config.set('GETTEXT_PACKAGE', output)
config.set('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config.set('DATADIR', get_option('prefix') / get_option('datadir') / 'tuner')
config.set('LIBDIR', get_option('prefix') / get_option('libdir'))

subdir('lib')

if get_option('app')
    subdir('data')
    subdir('src')
    subdir('po')

    gnome.post_install(
        glib_compile_schemas: true,
        gtk_update_icon_cache: true,
        update_desktop_database: true
    )
endif

if get_option('docs')
    subdir('doc')
endif
