static const char norm_fg[] = "#e4dcd2";
static const char norm_bg[] = "#0a1116";
static const char norm_border[] = "#9f9a93";

static const char sel_fg[] = "#e4dcd2";
static const char sel_bg[] = "#7B8479";
static const char sel_border[] = "#e4dcd2";

static const char urg_fg[] = "#e4dcd2";
static const char urg_bg[] = "#906F65";
static const char urg_border[] = "#906F65";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
