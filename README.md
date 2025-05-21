<p align="center">
  <img alt="branding" width="192" src="./data/icons/app/color.svg">
</p>
<h1 align="center">Tuner</h1>
<h4 align="center">Extensible control center</h4>

Tuner is the home for your additional system settings, components, applications, and whatever else you want!

- Extended control over the interface and functions using plugins.
- The interface is adapted to different device sizes.
- Easy installation from the repository.
- You can create your own plugins without affecting the main program code.
- Easy creation of plugins working with dconf and unlimited plugin functionality thanks to libpeas.

# Building

### Dependencies

- `libadwaita-1`
- `libpeas-2`
- `gee-0.8`
- `valac`

### Meson

```sh
meson setup --prefix=/usr build
meson install -C build
```
