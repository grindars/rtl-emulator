#ifndef __KEYMAP__H__
#define __KEYMAP__H__

static const unsigned int key_map[4][8][7] = {
    // Latin unshifted keyboard layout
    {
        // Column 0
        {
            SDLK_0, SDLK_1, SDLK_2, SDLK_3,
            SDLK_4, SDLK_5, SDLK_6
        },

        // Column 1
        {
            SDLK_7, SDLK_8, SDLK_9, -1,
            SDLK_SEMICOLON, SDLK_COMMA, SDLK_MINUS,
        },

        // Column 2
        {
            SDLK_PERIOD, SDLK_SLASH, -1, SDLK_a,
            SDLK_b, SDLK_c, SDLK_d
        },

        // Column 3
        {
            SDLK_e, SDLK_f, SDLK_g, SDLK_h,
            SDLK_i, SDLK_j, SDLK_k,
        },

        // Column 4
        {
            SDLK_l, SDLK_m, SDLK_n, SDLK_o,
            SDLK_p, SDLK_q, SDLK_r
        },

        // Column 5
        {
            SDLK_s, SDLK_t, SDLK_u, SDLK_v,
            SDLK_w, SDLK_x, SDLK_y,
        },

        // Column 6
        {
            SDLK_z, SDLK_LEFTBRACKET, SDLK_BACKSLASH,
            SDLK_RIGHTBRACKET, -1, -1, SDLK_SPACE
        },

        // Column 7
        {
            SDLK_RIGHT, SDLK_LEFT, SDLK_UP, SDLK_DOWN,
            SDLK_RETURN, SDLK_DELETE, SDLK_HOME
        },
    },

    // Latin shifted keyboard layout
    {
        // Column 0
        {
            -1, SDLK_1, SDLK_QUOTE, SDLK_3,
            SDLK_4, SDLK_5, SDLK_7
        },

        // Column 1
        {
            -1, SDLK_9, SDLK_0, SDLK_8,
            SDLK_EQUALS, SDLK_COMMA, -1
        },

        // Column 2
        {
            SDLK_PERIOD, SDLK_SLASH, SDLK_2, SDLK_a,
            SDLK_b, SDLK_c, SDLK_d
        },

        // Column 3
        {
            SDLK_e, SDLK_f, SDLK_g, SDLK_h,
            SDLK_i, SDLK_j, SDLK_k,
        },

        // Column 4
        {
            SDLK_l, SDLK_m, SDLK_n, SDLK_o,
            SDLK_p, SDLK_q, SDLK_r
        },

        // Column 5
        {
            SDLK_s, SDLK_t, SDLK_u, SDLK_v,
            SDLK_w, SDLK_x, SDLK_y,
        },

        // Column 6
        {
            SDLK_z, -1, -1, -1,
            SDLK_6, SDLK_MINUS, SDLK_SPACE
        },

        // Column 7
        {
            SDLK_RIGHT, SDLK_LEFT, SDLK_UP, SDLK_DOWN,
            SDLK_RETURN, SDLK_DELETE, SDLK_HOME
        },
    },

    // Cyrillic unshifted keyboard layout
    {
        // Column 0
        {
            SDLK_0, SDLK_1, SDLK_2, SDLK_3,
            SDLK_4, SDLK_5, SDLK_6
        },

        // Column 1
        {
            SDLK_7, SDLK_8, SDLK_9, -1,
            -1, SDLK_COMMA, SDLK_MINUS,
        },

        // Column 2
        {
            SDLK_PERIOD, SDLK_SLASH, -1, SDLK_f,
            SDLK_COMMA, SDLK_w, SDLK_l
        },

        // Column 3
        {
            SDLK_t, SDLK_a, SDLK_u, SDLK_LEFTBRACKET,
            SDLK_b, SDLK_q, SDLK_r,
        },

        // Column 4
        {
            SDLK_k, SDLK_v, SDLK_y, SDLK_j,
            SDLK_g, SDLK_z, SDLK_h
        },

        // Column 5
        {
            SDLK_c, SDLK_n, SDLK_e, SDLK_SEMICOLON,
            SDLK_d, SDLK_m, SDLK_s,
        },

        // Column 6
        {
            SDLK_p, SDLK_i, SDLK_QUOTE,
            SDLK_o, SDLK_x, -1, SDLK_SPACE
        },

        // Column 7
        {
            SDLK_RIGHT, SDLK_LEFT, SDLK_UP, SDLK_DOWN,
            SDLK_RETURN, SDLK_DELETE, SDLK_HOME
        },
    },

    // Cyrillic shifted keyboard layout
    {
        // Column 0
        {
            -1, SDLK_1, -1, SDLK_3,
            SDLK_4, SDLK_5, SDLK_7
        },

        // Column 1
        {
            -1, SDLK_9, SDLK_0, SDLK_8,
            SDLK_EQUALS, SDLK_COMMA, -1
        },

        // Column 2
        {
            SDLK_PERIOD, SDLK_SLASH, -1, SDLK_f,
            SDLK_COMMA, SDLK_w, SDLK_l
        },

        // Column 3
        {
            SDLK_t, SDLK_a, SDLK_u, SDLK_LEFTBRACKET,
            SDLK_b, SDLK_q, SDLK_r,
        },

        // Column 4
        {
            SDLK_k, SDLK_v, SDLK_y, SDLK_j,
            SDLK_g, SDLK_z, SDLK_h
        },

        // Column 5
        {
            SDLK_c, SDLK_n, SDLK_e, SDLK_SEMICOLON,
            SDLK_d, SDLK_m, SDLK_s,
        },

        // Column 6
        {
            SDLK_p, SDLK_i, SDLK_QUOTE,
            SDLK_o, SDLK_x, -1, SDLK_SPACE
        },

        // Column 7
        {
            SDLK_RIGHT, SDLK_LEFT, SDLK_UP, SDLK_DOWN,
            SDLK_RETURN, SDLK_DELETE, SDLK_HOME
        },
    }
};

#endif
