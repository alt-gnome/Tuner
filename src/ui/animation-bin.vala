namespace Tuner {

    public class AnimationBin : Gtk.Widget, Gtk.Buildable {
        private Gtk.Widget? _child;
        public Gtk.Widget? child {
            get { return _child; }
            set {
                if (_child == value) return;

                if (_child != null)
                    _child.unparent();

                _child = value;
                _child.set_parent(this);
            }
        }

        private Adw.Animation animation;

        private int target_width = 0;
        private int initial_width = 0;
        private int current_width = 0;

        construct {
            animation = new Adw.TimedAnimation(
                this, 0, 1,
                200,
                new Adw.CallbackAnimationTarget(animation_tick)
            );

            animation.done.connect(() => {
                initial_width = current_width = target_width;
            });
        }

        public void add_child(Gtk.Builder builder, GLib.Object child, string? type) {
            if (child is Gtk.Widget)
                this.child = (Gtk.Widget) child;
        }

        public override void size_allocate(int width, int height, int baseline) {
            if (child != null) {
                child.allocate(width, height, baseline, null);
            }
        }

        public override void measure(Gtk.Orientation orientation, int for_size, out int min, out int nat, out int min_baseline, out int nat_baseline) {
            if (child == null) {
                min = nat = min_baseline = nat_baseline = 0;
                return;
            }

            int child_nat;
            child.measure(orientation, -1, null, out child_nat, null, null);

            if (orientation == Gtk.Orientation.HORIZONTAL) {
                if (current_width == 0)
                    current_width = target_width = child_nat;

                if (target_width != child_nat) {
                    target_width = child_nat;
                    start_animation();
                }

                min = nat = current_width;
            } else {
                min = nat = child_nat;
            }

            min_baseline = nat_baseline = -1;
        }

        private void animation_tick(double value) {
            current_width = (int) Adw.lerp(initial_width, target_width, value);
            queue_resize();
        }

        private void start_animation() {
            initial_width = current_width;

            if (animation.state != Adw.AnimationState.FINISHED)
                animation.reset();

            animation.play();
        }
    }
}
