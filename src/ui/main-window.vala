[GtkTemplate (ui = "/org/altlinux/Tuner/main-window.ui")]
public class MainWindow : Adw.ApplicationWindow {
    
    public MainWindow(Gtk.Application app) {
        Object(application: app);
    }
}
