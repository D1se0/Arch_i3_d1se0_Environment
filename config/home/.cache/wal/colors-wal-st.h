const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0a1116", /* black   */
  [1] = "#906F65", /* red     */
  [2] = "#7B8479", /* green   */
  [3] = "#8C877A", /* yellow  */
  [4] = "#D38B77", /* blue    */
  [5] = "#7C8A82", /* magenta */
  [6] = "#A39F90", /* cyan    */
  [7] = "#e4dcd2", /* white   */

  /* 8 bright colors */
  [8]  = "#9f9a93",  /* black   */
  [9]  = "#906F65",  /* red     */
  [10] = "#7B8479", /* green   */
  [11] = "#8C877A", /* yellow  */
  [12] = "#D38B77", /* blue    */
  [13] = "#7C8A82", /* magenta */
  [14] = "#A39F90", /* cyan    */
  [15] = "#e4dcd2", /* white   */

  /* special colors */
  [256] = "#0a1116", /* background */
  [257] = "#e4dcd2", /* foreground */
  [258] = "#e4dcd2",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
