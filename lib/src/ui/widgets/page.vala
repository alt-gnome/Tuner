namespace Tuner {

    public class Page : Item, Gtk.Buildable {
        public string title { get; set; default = ""; }
        public string icon_name { get; set; }
        public string category { get; set; }
        public string tag { get; set; }
        public int priority { get; set; }
        public string description { get; set; }
        public bool subpage { get; set; }
        public Adw.NavigationPage? custom_content { get; set; }
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

        public void merge(Page page) {
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
            if (child is Item) {
                base.add_child(builder, child, type);
            } else if (child is Adw.NavigationPage && type == "custom") {
                custom_content = (Adw.NavigationPage) child;
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
