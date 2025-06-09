namespace Tuner {

    /**
     * Layout type of {@link PanelPage}
     */
    public enum LayoutType {
        /**
         * Default type. Child panel pages are ignored.
         */
        INTERNAL,
        /**
         * Child panel pages will be added to parent.
         */
        SUBPAGES,
        /**
         * Uses custom content instead of panel pages.
         */
        CUSTOM;
    }
}
