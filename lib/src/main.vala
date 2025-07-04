namespace Tuner {
    private static ToastFunc? toast_func;
    private static SetPageFunc? set_page_func;
    private static PushSubpageFunc? push_subpage_func;
    private static bool initialized = false;

    public static void init(ToastFunc? toast_func, SetPageFunc? set_page_func, PushSubpageFunc? push_subpage_func) {
        if (initialized) return;

        Tuner.toast_func = toast_func;
        Tuner.set_page_func = set_page_func;
        Tuner.push_subpage_func = push_subpage_func;

        initialized = true;
    }

    public static bool toast(string text) {
        return toast_func != null ? toast_func(text) : false;
    }

    public static bool set_page(Adw.NavigationPage? page, bool show = true) {
        return set_page_func != null ? set_page_func(page, show) : false;
    }

    public static bool push_subpage(Adw.NavigationPage page) {
        return push_subpage_func != null ? push_subpage_func(page) : false;
    }

    public delegate bool ToastFunc(string text);
    public delegate bool SetPageFunc(Adw.NavigationPage? page, bool show);
    public delegate bool PushSubpageFunc(Adw.NavigationPage page);
}
