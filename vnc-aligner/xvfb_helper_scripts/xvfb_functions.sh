#!/bin/bash

# Clean up Xvfb 
function cleanXvfb {
    kill $XVFB_PID
    rm -f ${X_WORK_DIR}/.X${XVFB_PORT}-lock
    rm -f ${X_WORK_DIR}/.X11-unix/X${XVFB_PORT}
    echo "Cleaned up Xvfb"
}

# Take a screenshot using imagemagick
function screenSnapshot {
    # take a screenshot
    echo "Taking a screen snapshot -> ${X_WORK_DIR}/screenshot_${XVFB_PORT}.png"
    DISPLAY=:$XVFB_PORT import -window root ${X_WORK_DIR}/screenshot_${XVFB_PORT}.png
}
