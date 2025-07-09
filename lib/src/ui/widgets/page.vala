using Gee;

namespace Tuner {

    /**
     * Toplevel item for all content.
     *
     * Can contain {@link Tuner.Page} and {@link Group}.
     * {@link Tuner.Page}s annotated with 'subpage' will be counted
     * as subpages, added to subpages_model, and subpage property
     * will be set in that pages.
     *
     * If this has parent adding internal Pages is not allowed
     *
     * Note: Can't be Template class!
     */
    public class Page : Item, Gtk.Buildable {
        public string title { get; set; default = ""; }
        public string icon_name { get; set; }
        public string category { get; set; }
        public string tag { get; set; }
        public int priority { get; set; }
        public string description { get; set; }
        public bool subpage { get; set; }
        public Adw.NavigationPage? custom_content { get; set; }
        public Gtk.Widget? title_widget { get; set; }
        public ArrayList<Gtk.Widget>? start_widgets { get; set; }
        public ArrayList<Gtk.Widget>? end_widgets { get; set; }
        public ArrayList<Gtk.Widget>? top_widgets { get; set; }
        public ArrayList<Gtk.Widget>? bottom_widgets { get; set; }
        public ListStore? subpages_model { get; set; }
        public bool has_subpages {
            get {
                return subpages_model != null;
            }
        }

        public void add_subpage(Page page) {
            register_subpage(page);

            if (!childs.contains(page))
                page.insert_after(this, null);
        }

        public void add_top_bar(Gtk.Widget widget) {
            if (top_widgets == null)
                top_widgets = new ArrayList<Gtk.Widget>();

            top_widgets.add(widget);
        }

        public void add_bottom_bar(Gtk.Widget widget) {
            if (bottom_widgets == null)
                bottom_widgets = new ArrayList<Gtk.Widget>();

            bottom_widgets.add(widget);
        }

        public void pack_start(Gtk.Widget widget) {
            if (start_widgets == null)
                start_widgets = new ArrayList<Gtk.Widget>();

            start_widgets.add(widget);
        }

        public void pack_end(Gtk.Widget widget) {
            if (end_widgets == null)
                end_widgets = new ArrayList<Gtk.Widget>();

            end_widgets.add(widget);
        }

        public void merge(Page page) {
            if (title_widget == null)
                title_widget = page.title_widget;

            if (page.start_widgets != null)
                foreach (var widget in page.start_widgets)
                    pack_start(widget);

            if (page.end_widgets != null)
                foreach (var widget in page.end_widgets)
                    pack_end(widget);

            if (page.top_widgets != null)
                foreach (var widget in page.top_widgets)
                    add_top_bar(widget);

            if (page.bottom_widgets != null)
                foreach (var widget in page.bottom_widgets)
                    add_bottom_bar(widget);

            foreach (var page_child in page.childs) {
                if (page_child is Group) {
                    var group = (Group) page_child;

                    if (group.id != null && group.id != "") {
                        var matched_group = (Group) childs.first_match(it => {
                            var pred_group = it as Group;
                            return pred_group != null && pred_group.id == group.id;
                        });

                        if (matched_group != null) {
                            matched_group.merge(group);
                            continue;
                        }
                    }

                    group.insert_after(this, null);
                } else if (page_child is Page) {
                    var subpage = (Page) page_child;

                    if (subpage.tag != null && subpage.tag != "") {
                        var matched_subpage = (Page) childs.first_match(it => {
                            var pred_subpage = it as Page;
                            return pred_subpage != null && pred_subpage.tag == subpage.tag;
                        });

                        if (matched_subpage != null) {
                            matched_subpage.merge(subpage);
                            continue;
                        }
                    }

                    if (subpage.subpage)
                        add_subpage(subpage);
                    else
                        subpage.insert_after(this, null);
                }
            }
        }

        public override bool accepts(Item item, string? type) {
            var page = item as Page;
            if (page != null) {
                if (parent == null || subpage) {
                    if (type == "subpage")
                        register_subpage(page);

                    return true;
                } else {
                    warning("Subpages can only be on a top-level page or a subpage!");
                    return false;
                }
            }

            return item is Group;
        }

        private void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (child is Gtk.Widget && type == "title") {
                title_widget = (Gtk.Widget) child;
            } else if (child is Gtk.Widget && type == "start") {
                pack_start((Gtk.Widget) child);
            } else if (child is Gtk.Widget && type == "end") {
                pack_end((Gtk.Widget) child);
            } else if (child is Gtk.Widget && type == "top") {
                add_top_bar((Gtk.Widget) child);
            } else if (child is Gtk.Widget && type == "bottom") {
                add_bottom_bar((Gtk.Widget) child);
            } else if (child is Adw.NavigationPage && type == "custom") {
                custom_content = (Adw.NavigationPage) child;
            } else {
                base.add_child(builder, child, type);
            }
        }

        private void register_subpage(Page page) {
            if (subpages_model == null)
                subpages_model = new ListStore(typeof(Page));

            page.subpage = true;
            subpages_model.append(page);
        }
    }
}
