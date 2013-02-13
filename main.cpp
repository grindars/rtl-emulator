#include <SDL.h>
#include <semaphore.h>
#include <stdio.h>

#include "UT88.h"
#include "keymap.h"

#define MOD_SHIFT   4
#define MOD_CTRL    2
#define MOD_CYR     1

static SDL_Surface *primary;
static sem_t frame_sem;
static int prevmod = 0, overriding_key = 0;

class SDLHardware: public IHardware {
public:
    virtual void paintFrame(const unsigned char *data) {
        if(sem_trywait(&frame_sem) == 0) {
            unsigned char *copy = new unsigned char[UT88::VisibleWidth * UT88::VisibleHeight];
            memcpy(copy, data, UT88::VisibleWidth * UT88::VisibleHeight);

            SDL_Event event;
            event.type = SDL_USEREVENT;
            event.user.code = 1;
            event.user.data1 = copy;
            SDL_PushEvent(&event);
        }
    }
};

static void paintFrame(const unsigned char *data) {
    SDL_LockSurface(primary);

    const unsigned char *ptr = data;
    unsigned short *dptr = (unsigned short *)primary->pixels;

    for(unsigned int line = 0; line < UT88::VisibleHeight; line++) {
        for(unsigned int col = 0; col < UT88::VisibleWidth; col++) {
            *dptr = ((*ptr & 0xE0) << 8) |
                    ((*ptr & 0x1C) << 6) |
                    ((*ptr & 0x03) << 3);

            ptr++;
            dptr++;
        }
    }

    SDL_UnlockSurface(primary);
    SDL_UpdateRect(primary, 0, 0, 0, 0);
}

static int is_mod(int key) {
    switch(key) {
        case SDLK_RCTRL:
        case SDLK_LCTRL:
        case SDLK_RSHIFT:
        case SDLK_LSHIFT:
        case SDLK_CAPSLOCK:
            return 1;

        default:
            return 0;
    }
}

static void key_event(unsigned int key, int down, UT88 *ut88);

static void set_mod(int mod, UT88 *ut88) {
    int count = 0, i;
    Uint8 *keys = SDL_GetKeyState(&count);

    for(i = 0; i < count; i++)
        if(!is_mod(i) && keys[i] && i != overriding_key)
            key_event(i, 0, ut88);

    ut88->writeKeyboardModifier(~mod);

    prevmod = mod;

    for(i = 0; i < count; i++)
        if(!is_mod(i) && keys[i] && i != overriding_key)
            key_event(i, 1, ut88);

}

static unsigned char rows[8];

static void keydown(int row, int column, UT88 *ut88) {
    rows[column] &= ~(1 << row);
    ut88->writeKeyboardRow(column, rows[column]);
}

static void keyup(int row, int column, UT88 *ut88) {
    rows[column] |= (1 << row);
    ut88->writeKeyboardRow(column, rows[column]);
}

static void key_event(unsigned int key, int down, UT88 *ut88) {

    static int pre_override = 0;

    if(key == SDLK_SEMICOLON && (
        (down && (prevmod & MOD_SHIFT) && overriding_key == 0 && !(prevmod & MOD_CYR)) ||
        (!down && overriding_key == SDLK_SEMICOLON))) {

        if(down) {
            overriding_key = key;
            pre_override = prevmod;
            set_mod(prevmod & ~MOD_SHIFT, ut88);
            keydown(3, 1, ut88);
        } else {
            keyup(3, 1, ut88);
            set_mod(pre_override, ut88);
            pre_override = 0;
            overriding_key = 0;
        }

        } else if(key == SDLK_EQUALS && (
            (down && !(prevmod & MOD_SHIFT) && overriding_key == 0) ||
            (!down && overriding_key == SDLK_EQUALS))) {

            if(down) {
                overriding_key = key;
                pre_override = prevmod;
                set_mod(prevmod | MOD_SHIFT, ut88);
                keydown(6, 1, ut88);
            } else {
                keyup(6, 1, ut88);
                set_mod(pre_override, ut88);
                pre_override = 0;
                overriding_key = 0;
            }

            } else if(is_mod(key)) {
                int mod = 0;
                SDLMod sdl = SDL_GetModState();

                if(sdl & KMOD_SHIFT)
                    mod |= MOD_SHIFT;

                if(sdl & KMOD_CTRL)
                    mod |= MOD_CTRL;

                if(sdl & KMOD_CAPS)
                    mod |= MOD_CYR;

                set_mod(mod, ut88);
            } else {
                int column, row, table;

                if(prevmod & MOD_SHIFT)
                    table = 1;
                else
                    table = 0;

                if(prevmod & MOD_CYR)
                    table += 2;

                for(column = 0; column < 8; column++)
                    for(row = 0; row < 7; row++)
                        if(key_map[table][column][row] == key) {
                            if(down)
                                keydown(row, column, ut88);
                            else
                                keyup(row, column, ut88);

                                break;
                        }
            }
}

int main(void) {
    sem_init(&frame_sem, 0, 4);

    if(SDL_Init(SDL_INIT_VIDEO) == -1) {
        fprintf(stderr, "SDL initialization failed: %s\n", SDL_GetError());

        return -1;
    }


    primary = SDL_SetVideoMode(UT88::VisibleWidth,
                               UT88::VisibleHeight,
                               16,
                               SDL_SWSURFACE);

    if(primary == NULL) {
        fprintf(stderr, "Video mode setting failed: %s\n", SDL_GetError());

        SDL_Quit();

        return -1;
    }

    UT88 ut88(new SDLHardware);
    ut88.start();
    printf("machine is running\n");

    ut88.writeKeyboardModifier(0xFF);
    for(unsigned int i = 0; i < 8; i++) {
        rows[i] = 0x7F;

        ut88.writeKeyboardRow(i, 0x7F);
    }

    SDL_Event ev;
    int run = 1;
    while(run && SDL_WaitEvent(&ev)) {
        switch(ev.type) {
            case SDL_QUIT:
                run = 0;

                break;

            case SDL_USEREVENT:
                switch(ev.user.code) {
                    case 1:
                    {
                        unsigned char *frame_data = (unsigned char *) ev.user.data1;

                        paintFrame(frame_data);

                        delete[] frame_data;
                        sem_post(&frame_sem);

                        break;
                    }
                }

                break;

                case SDL_KEYDOWN:
                    key_event(ev.key.keysym.sym, 1, &ut88);

                    break;

                case SDL_KEYUP:
                    key_event(ev.key.keysym.sym, 0, &ut88);

                    break;

        }
    }

    printf("stopping machine\n");
    ut88.stop();
    ut88.wait();

    SDL_Quit();

    return 0;
}