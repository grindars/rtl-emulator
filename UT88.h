#ifndef __UT88__H__
#define __UT88__H__

#include <pthread.h>
#include <stdint.h>
#include <list>

class VUT88;

class IHardware {
public:
    virtual ~IHardware() {}

    virtual void paintFrame(const uint8_t *data) = 0;
};

class UT88 {
public:
    enum {
        FrameWidth = 704,
        FrameHeight = 524,

        VisibleXStart = 16,
        VisibleXEnd = 655,

        VisibleYStart = 10,
        VisibleYEnd = 489,

        VisibleWidth = VisibleXEnd - VisibleXStart + 1,
        VisibleHeight = VisibleYEnd - VisibleYStart + 1
    };

    enum VideoState {
        VideoArea,
        HPulse,
        VPulse,
        SyncLost,
        SyncLostEOF
    };

    enum KeyboardState {
        Idle,
        WaitRise,
        WaitFall,
        Gap
    };

    UT88(IHardware *hardware);
    ~UT88();

    void start();
    void stop();
    void wait();
    bool isRunning() const;

    void writeKeyboardRow(uint8_t row, uint8_t value);
    void writeKeyboardModifier(uint8_t modifier);

protected:
    void run();

private:
    static void *runThunk(void *arg);
    void videoFSM();
    void keyboardFSM();
    void writeKeyboardEvent(uint16_t event);

    pthread_t m_thread;
    volatile bool m_stop;
    VUT88 *m_vut88;
    VideoState m_videoState;
    int m_videoX, m_videoY;
    uint8_t *m_vram;
    IHardware *m_hardware;
    pthread_mutex_t m_keyboardMutex;
    std::list<uint16_t> m_eventQueue;
    KeyboardState m_keyboardState;
};

#endif

