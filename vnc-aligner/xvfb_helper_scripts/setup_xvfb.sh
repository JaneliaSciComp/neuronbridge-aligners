if [[ $FB_MODE =~ "xvfb" ]]; then
    echo "initialize virtual framebuffer"
    START_PORT=`shuf -i 5000-6000 -n 1`
    XVFB_WORKING_DIR=${WORKING_DIR}/xvfb_temp
    mkdir -p ${XVFB_WORKING_DIR}
    source ${XVFB_HELPER_SCRIPTS_DIR}/init_xvfb.sh ${START_PORT} ${XVFB_WORKING_DIR}
    function exitXvfb {
        echo "Exit XVFB Mode"
        cleanXvfb; 
    }
else
    # dummy screenSnapshot function
    function screenSnapshot {
        echo "No op screenSnapshot"
    }
    
    # dummy exitXvfb function
    function exitXvfb {
        echo "Nothing to do for exiting Xvfb"
    }
fi
