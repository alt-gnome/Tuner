using Gee;

namespace Tuner {

    public class PageList : ArrayList<Page> {

        public PageList() {
            var disabled_plugins = App.settings.get_strv("disabled-plugins");

            App.addins.foreach((s, info, obj) => {
                var addin = obj as Addin;

                if (!(info.module_name in disabled_plugins)) {
                    addin.activate();

                    // Merging should be done before creating UI
                    foreach (var page in addin.get_page_list()) {
                        if (page.id != null && page.id != "") {
                            var matched_page = first_match(it => it.id == page.id);
                            if (matched_page != null) {
                                matched_page.merge(page);
                                continue;
                            }
                        }
                        add(page);
                    }
                }
            });
        }

        public Item? get_element_by_path(string item_path) {
            var path = item_path.split(".");
            ArrayList<Item> items = this;

            foreach (var part in path) {
                Item? current_item = null;

                foreach (var item in items) {
                    if (item.id == part) {
                        current_item = item;
                        break;
                    }
                }

                if (current_item == null) {
                    return null;
                }

                if (part != path[path.length - 1]) {
                    items = current_item.childs;
                } else {
                    return current_item;
                }
            }

            return null;
        }

        public ArrayList<Widget> find_widgets_with_path() {
            var list = new ArrayList<Widget>();

            foreach (var page in this) {
                page.visit_children(item => {
                    if ((item is Group || item is Page) && item.id != null && item.id != "") {
                        return VisitResult.RECURSE;
                    }

                    var widget = item as Widget;

                    if (widget != null && widget.id != null && widget.id != "") {
                        list.add(widget);
                    }

                    return VisitResult.CONTINUE;
                });
            }

            return list;
        }
    }
}
