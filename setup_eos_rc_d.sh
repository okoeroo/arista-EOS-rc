#!/bin/sh

EOS_RC="eos.rc"
EOS_RC_PATH="${EOS_RC_PATH:=/mnt/flash}"
EOS_RC_D="eos.rc.d"

EOS_RC_D_SHELL="/bin/sh"


function is_rc_eos_d_configued() {
    if [ ! -e "${EOS_RC_PATH}/${EOS_RC}" ]; then
        echo "Error: file \"${EOS_RC_PATH}/${EOS_RC}\" doesn't exist"
        return 1
    fi

    OUTPUT=$(grep "${EOS_RC_PATH}/${EOS_RC_D}" "${EOS_RC_PATH}/${EOS_RC}")
    if [ "" == "${OUTPUT}" ]; then
        return 1
    else
        #echo "Found ${EOS_RC_PATH}/${EOS_RC_D} in ${EOS_RC_PATH}/${EOS_RC}"
        return 0
    fi
}


function create_basic_eos_rc() {
echo "Creating a new and basic ${EOS_RC_PATH}/${EOS_RC}"

if [ -e "${EOS_RC_PATH}/${EOS_RC}" ]; then
    mv ${EOS_RC_PATH}/${EOS_RC} ${EOS_RC_PATH}/${EOS_RC}.`date +%Y%m%d%H%M%s`
fi

cat > "${EOS_RC_PATH}/${EOS_RC}" << EOF
#!/bin/sh

### Basic ${EOS_RC} file, which will execute at each reboot and will execute
### the scripts in ./${EOS_RC_D}.
###
### Auto-generated file by Oscar Koeroo <okoeroo@nikhef.nl>

find "${EOS_RC_PATH}/${EOS_RC_D}" -exec ${EOS_RC_D_SHELL} {} \;

EOF
}

function add_eos_rc_d() {
echo "Adding ${EOS_RC_D} to ${EOS_RC}"

if [ -e "${EOS_RC_PATH}/${EOS_RC}" ]; then
    cp ${EOS_RC_PATH}/${EOS_RC} ${EOS_RC_PATH}/${EOS_RC}.`date +%Y%m%d%H%M%s`
fi

cat >> "${EOS_RC_PATH}/${EOS_RC}" << EOF

### Adding ${EOS_RC_D} constructs to ${EOS_RC} to execute
### the scripts in ./${EOS_RC_D}.
###
### Auto-generated file by Oscar Koeroo <okoeroo@nikhef.nl>

find "${EOS_RC_PATH}/${EOS_RC_D}" -exec ${EOS_RC_D_SHELL} {} \;

EOF
}

function make_eos_rc_work() {
    # Check if the EOS_RC is there
    if [ ! -e "${EOS_RC_PATH}/${EOS_RC}" ]; then
        # No ${EOS_RC_PATH}/${EOS_RC} found, need to add it
        echo "No ${EOS_RC_PATH}/${EOS_RC} found"
        create_basic_eos_rc
    else
        echo "Found: ${EOS_RC_PATH}/${EOS_RC}"
    fi

    # Check if the EOS_RC_D is in the EOS_RC configured
    is_rc_eos_d_configued
    RC=$?
    if [ "1" == "${RC}" ]; then
        # No EOS_RC_D found in EOS_RC, need to add it
        add_eos_rc_d
    else
        echo "Already configured to work with the eos.rc.d/"
    fi

    # If it doesn't exist yet, add a ${EOS_RC_PATH}/${EOS_RC_D} directory
    if [ ! -d "${EOS_RC_PATH}/${EOS_RC_D}" ]; then
        echo "Creating directory: ${EOS_RC_PATH}/${EOS_RC_D}"
        mkdir -p "${EOS_RC_PATH}/${EOS_RC_D}"
    else
        echo "Directory ${EOS_RC_PATH}/${EOS_RC_D} already exists"
    fi
}


########## MAIN ##########

make_eos_rc_work
