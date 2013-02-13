#include <stdio.h>
#include <stdlib.h>
#include <VUT88.h>

#include "UT88.h"

UT88::UT88(IHardware *hardware) : m_thread(pthread_self()), m_stop(false),
    m_hardware(hardware) {

    pthread_mutex_init(&m_keyboardMutex, NULL);
}

UT88::~UT88() {
    if(isRunning()) {
        fputs("UT88::~UT88: destroyed while thread is still running\n", stderr);

        abort();
    }

    pthread_mutex_destroy(&m_keyboardMutex);

    delete m_hardware;
}

bool UT88::isRunning() const {
    return !pthread_equal(m_thread, pthread_self());
}

void UT88::start() {
    if(isRunning()) {
        fputs("UT88::start: thread is already running\n", stderr);

        abort();
    }

    int ret = pthread_create(&m_thread, NULL, UT88::runThunk, this);
    if(ret != 0) {
        m_thread = pthread_self();

        perror("pthread_create");
        abort();
    }
}

void UT88::stop() {
    if(!isRunning()) {
        fputs("UT88::stop: thread is not running\n", stderr);

        abort();
    }

    m_stop = true;
}

void UT88::wait() {
    if(!isRunning()) {
        fputs("UT88::wait: thread is not running\n", stderr);

        abort();
    }

    int ret = pthread_join(m_thread, NULL);
    if(ret != 0) {
        perror("pthread_join");
        abort();
    }

    m_thread = pthread_self();
}

void *UT88::runThunk(void *arg) {
    static_cast<UT88 *>(arg)->run();

    return NULL;
}

void UT88::run() {
    printf("UT88: startup\n");

    m_videoState = VideoArea;
    m_videoX = 0;
    m_videoY = 0;
    m_vram = new uint8_t[VisibleWidth * VisibleHeight];

    m_vut88 = new VUT88;

    m_vut88->CLK_VIDEO = 0;
    m_vut88->KEY_STB = 0;
    m_vut88->KEY_OP = 0;

    m_vut88->RESET = 1;
    m_vut88->CLK = 1;
    m_vut88->eval();
    m_vut88->CLK = 0;
    m_vut88->eval();
    m_vut88->RESET = 0;
    m_vut88->eval();

    m_keyboardState = Idle;

    unsigned char cycle_counter = 0;
    while(!m_stop) {
        cycle_counter++;

        int cpu_cycle = (cycle_counter & 1) == 0;

        m_vut88->CLK_VIDEO = 1;
        if(cpu_cycle)
            m_vut88->CLK = 1;

        m_vut88->eval();

        m_vut88->CLK_VIDEO = 0;
        if(cpu_cycle)
            m_vut88->CLK = 0;

        m_vut88->eval();

        videoFSM();

        if(cpu_cycle) {
            pthread_mutex_lock(&m_keyboardMutex);

            keyboardFSM();

            pthread_mutex_unlock(&m_keyboardMutex);
        }
    }

    printf("UT88: shutdown\n");

    m_vut88->final();
    delete m_vut88;

    delete[] m_vram;
}

void UT88::videoFSM() {

    uint8_t color = (m_vut88->VGA_R << 5) | (m_vut88->VGA_G << 2) | m_vut88->VGA_B;

    switch(m_videoState) {
        case VideoArea:
            if(m_vut88->VSYNC == 0) {
                if(m_videoY != FrameHeight - 1) {
                    printf("Timings is incorrect, frame height: %d\n", m_videoY);

                    m_videoState = SyncLostEOF;
                } else {
                    m_videoState = VPulse;
                    m_videoX = 0;
                    m_videoY = 0;

                    m_hardware->paintFrame(m_vram);
                }

                break;
            } else if(m_vut88->HSYNC == 0) {
                if(m_videoX != FrameWidth - 1) {
                    printf("Timings is incorrect, line width: %d\n", m_videoX);

                    m_videoState = SyncLostEOF;
                } else {
                    m_videoX = 0;
                    m_videoY++;

                    m_videoState = HPulse;
                }
            } else {
                if(m_videoX >= VisibleXStart && m_videoX <= VisibleXEnd &&
                   m_videoY >= VisibleYStart && m_videoY <= VisibleYEnd) {

                    m_vram[(m_videoX - VisibleXStart) + (m_videoY - VisibleYStart) * VisibleWidth] = color;
                }

                m_videoX++;
            }

            break;

        case HPulse:
            if(m_vut88->HSYNC == 1)
                m_videoState = VideoArea;

            break;

        case VPulse:
            if(m_vut88->VSYNC == 1)
                m_videoState = VideoArea;

            break;

        case SyncLost:
            if(m_vut88->VSYNC == 0) {
                m_videoX = 0;
                m_videoY = 0;

                m_videoState = VPulse;
            }

            break;

        case SyncLostEOF:
            if(m_vut88->VSYNC == 1)
                m_videoState = SyncLost;

            break;
    }
}

void UT88::writeKeyboardRow(uint8_t row, uint8_t value) {
    writeKeyboardEvent((row << 8) | value);
}

void UT88::writeKeyboardModifier(uint8_t modifier) {
    writeKeyboardEvent((1 << 11) | modifier);
}

void UT88::writeKeyboardEvent(uint16_t event) {
    pthread_mutex_lock(&m_keyboardMutex);
    m_eventQueue.push_back(event);
    pthread_mutex_unlock(&m_keyboardMutex);
}

void UT88::keyboardFSM() {
    switch(m_keyboardState) {
        case Idle:
            if(m_eventQueue.size() > 0) {
                uint16_t value = m_eventQueue.front();
                m_eventQueue.pop_front();

                m_vut88->KEY_OP = value;
                m_vut88->KEY_STB = 1;

                m_keyboardState = WaitRise;
            }

            break;

        case WaitRise:
            if(m_vut88->KEY_BUSY) {
                m_keyboardState = WaitFall;
                fflush(stdout);
            }

            break;

        case WaitFall:
            if(!m_vut88->KEY_BUSY) {
                m_vut88->KEY_OP = 0;
                m_vut88->KEY_STB = 0;

                m_keyboardState = Gap;
            }

            break;

        case Gap:
            m_keyboardState = Idle;

            break;
    }
}
