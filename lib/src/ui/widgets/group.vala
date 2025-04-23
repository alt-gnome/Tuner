namespace Tuner {

    /**
     * Widget allows to use Content addins
     */
    public class Group : Adw.PreferencesGroup {
        public int priority { get; set; }

        public void add_content(GroupContent content) {
            foreach (var child in content.childs)
                add(child);
        }
    }
}
