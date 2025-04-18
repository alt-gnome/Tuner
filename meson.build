project(
    'Tuner',

    ['c', 'vala'],
    version: '0.1',
    meson_version: '>= 1.0',
)

add_global_arguments([
	'-Wno-unused',
	'-Wno-discarded-qualifiers'
], language: 'c')

add_project_arguments (
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

pkg = import('pkgconfig')
gnome = import('gnome')
i18n = import('i18n')

id = 'org.altlinux.Tuner'
name = meson.project_name()
version = meson.project_version()
output = name.to_lower()

config = configuration_data()
config.set('ID', id)
config.set('VERSION', meson.project_version())
config.set('GETTEXT_PACKAGE', meson.project_name())
config.set('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config.set('DATADIR', get_option('prefix') / get_option('datadir') / 'tuner')
config.set('LIBDIR', get_option('prefix') / get_option('libdir'))

subdir('data')
subdir('lib')
subdir('src')
subdir('po')

gnome.post_install(
    gtk_update_icon_cache: true,
    update_desktop_database: true
)
