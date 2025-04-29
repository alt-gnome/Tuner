namespace Tuner {

    /**
     * Empty action row that support binding with settings
     */
    public class ActionRow : Adw.ActionRow, Modifier {
        public Settings? settings { get; set; }
        public SettingsSchema? schema { get; set; }
        public string? schema_id { get; set; }
        public string? key { get; set; }

        public bool is_valid_setting { get; set; }
        public bool is_default { get; set; }

        construct {
            setup();
        }
    }
}
