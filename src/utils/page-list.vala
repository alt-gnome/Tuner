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
    }
}
