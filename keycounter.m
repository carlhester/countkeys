#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

static CFMachPortRef eventTap;

static CGEventRef CGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    int *counter = (int *)refcon;

    // This version only counts the meta key, so we don't need to look at other keys
    //if (type == kCGEventKeyDown) {
        // Increment counter on key down event
    //    (*counter)++;
    //} else if (type == kCGEventFlagsChanged) {
    if (type == kCGEventFlagsChanged) {
        // Check if the CMD key was pressed
        CGEventFlags flags = CGEventGetFlags(event);
        if (flags & kCGEventFlagMaskCommand) {
            (*counter)++;
        }
    }

    return event;
}

void StartKeyCounter(int *counter) {
    if (eventTap) return;

    CFRunLoopSourceRef runLoopSource;

    // Listen for both key down and flags changed events
    eventTap = CGEventTapCreate(kCGSessionEventTap, kCGHeadInsertEventTap, 0, (1 << kCGEventKeyDown) | (1 << kCGEventFlagsChanged), CGEventCallback, counter);
    if (!eventTap) {
        printf("Failed to create event tap.\n");
        exit(1);
    }

    runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);

    CFRunLoopRun();
}

void StopKeyCounter() {
    if (!eventTap) return;

    CGEventTapEnable(eventTap, false);
    CFMachPortInvalidate(eventTap);
    CFRelease(eventTap);
    eventTap = NULL;

    CFRunLoopStop(CFRunLoopGetCurrent());
}

