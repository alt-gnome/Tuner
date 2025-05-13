namespace Tuner {

    /**
     * Widget allows to use Content addins
     *
     * Content addins can be added using
     * widget id if it was specified.
     */
    public class Group : Adw.PreferencesGroup {
        public int priority { get; set; }

        public void add_content(GroupContent content) {
            foreach (var child in content.childs)
                add(child);
        }
    }
}
