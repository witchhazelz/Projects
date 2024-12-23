#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
#include <time.h>

#if defined(SDL2) || defined(SDL) || defined(__EMSCRIPTEN__)
#  include "sdl/pocadv.h"
#else
#  include <windows.h>
#  include "gdi/gdi.h"
#endif

#include "chip8.h"
#include "bmp.h"

/* number of instructions to execute per second */
static int speed = 1200;

/* foreground color */
static int fg_color = 0xAAAAFF;

/* background color */
static int bg_color = 0x000055;

/* is the interpreter running? Set to 0 to enter "debug" mode */
static int running = 1;

static Bitmap *chip8_screen;
static Bitmap *hud;

/* key mappings */
static unsigned int Key_Mapping[16] = {
#if defined(SDL) || defined(SDL2)
    KCODEA(x,X),
    KCODE(1),
    KCODE(2),
    KCODE(3),
    KCODEA(q,Q),
    KCODEA(w,W),
    KCODEA(e,E),
    KCODEA(a,A),
    KCODEA(s,S),
    KCODEA(d,D),
    KCODEA(z,Z),
    KCODEA(c,C),
    KCODE(4),
    KCODEA(r,R),
    KCODEA(f,F),
    KCODEA(v,V)
#else
    0x58, /* '0' -> 'x' */
    0x31, /* '1' -> '1' */
    0x32, /* '2' -> '2' */
    0x33, /* '3' -> '3' */
    0x51, /* '4' -> 'q' */
    0x57, /* '5' -> 'w' */
    0x45, /* '6' -> 'e' */
    0x41, /* '7' -> 'a' */
    0x53, /* '8' -> 's' */
    0x44, /* '9' -> 'd' */
    0x5A, /* 'A' -> 'z' */
    0x43, /* 'B' -> 'c' */
    0x34, /* 'C' -> '4' */
    0x52, /* 'D' -> 'r' */
    0x46, /* 'E' -> 'f' */
    0x56, /* 'F' -> 'v' */
#endif
};

static void draw_screen();
static void usage();

static void draw_screen() {
    int w, h;
    c8_resolution(&w, &h);

    assert(w <= bm_width(chip8_screen));
    assert(h <= bm_height(chip8_screen));

    for (int y = 0; y < h; y++) {
        for (int x = 0; x < w; x++) {
            unsigned int color = c8_get_pixel(x, y) ? fg_color : bg_color;
            bm_set(chip8_screen, x, y, color);
        }
    }

    bm_blit_ex(screen, 0, 0, bm_width(screen), bm_height(screen), chip8_screen, 0, 0, w, h, 0);
}

static void usage() {
    fprintf(stderr, "Usage: chip8 [options] <chip8_file>\n");
    fprintf(stderr, "Options:\n");
    fprintf(stderr, "  -f fg        : Foreground color\n");
    fprintf(stderr, "  -b bg        : Background color\n");
    fprintf(stderr, "  -s spd       : Specify the speed\n");
    fprintf(stderr, "  -d           : Debug mode\n");
    fprintf(stderr, "  -v           : Increase verbosity\n");
    fprintf(stderr, "  -q quirks    : Sets the quirks mode\n");
    fprintf(stderr, "  -h           : Displays this help\n");
    exit(EXIT_FAILURE);
}

void init_render() {
    chip8_screen = bm_create(128, 64);
    if (!chip8_screen) {
        exit_error("Unable to create CHIP-8 screen bitmap");
    }

    hud = bm_create(128, 24);
    if (!hud) {
        exit_error("Unable to create HUD bitmap");
    }

    rlog("Render initialized.");
}

void deinit_render() {
    bm_free(hud);
    bm_free(chip8_screen);
    rlog("Render deinitialized.");
}

int render(double elapsedSeconds) {
    int key_pressed = 0;

    for (int i = 0; i < 16; i++) {
        int k = Key_Mapping[i];
        if (keys[k]) {
            key_pressed = 1;
            c8_key_down(i);
        } else {
            c8_key_up(i);
        }
    }

    static double timer = 0.0;
    timer += elapsedSeconds;
    while (timer > 1.0 / 60.0) {
        c8_60hz_tick();
        timer -= 1.0 / 60.0;
    }

    if (running) {
        int count = speed * elapsedSeconds;
        for (int i = 0; i < count; i++) {
            if (c8_ended()) {
                return 0;
            } else if (c8_waitkey() && !key_pressed) {
                return 1;
            }

            c8_step();

            if (c8_screen_updated()) {
                draw_screen();
            }
        }
    } else {
        draw_screen();
    }

    return 1;
} ```c