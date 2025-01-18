#!/bin/sh

#  embedframework.sh
#  AffordIQ
#
#  Created by Sultangazy Bukharbay on 16/02/2021.
#  Copyright © 2021 BlackArrow Financial Solutions Limited. All rights reserved.

set echo off

if [[ -z ${SCRIPT_INPUT_FILE_0} || -z ${SCRIPT_OUTPUT_FILE_0} ]]; then
    echo "This Xcode Run Script build phase must be configured with Input & Output Files"
    exit 1
fi

echo "Embed ${SCRIPT_INPUT_FILE_0}"
if [[ $CONFIGURATION == 'Debug' ]]; then
    FRAMEWORK_SOURCE=${SCRIPT_INPUT_FILE_0}
    FRAMEWORK_DESTINATION=${SCRIPT_OUTPUT_FILE_0}
    DESTINATION_FOLDER=`dirname ${FRAMEWORK_DESTINATION}`

    mkdir -p ${DESTINATION_FOLDER}
    cp -Rv ${FRAMEWORK_SOURCE} ${FRAMEWORK_DESTINATION}

    CODE_SIGN_IDENTITY_FOR_ITEMS="${EXPANDED_CODE_SIGN_IDENTITY_NAME}"
    if [ "${CODE_SIGN_IDENTITY_FOR_ITEMS}" = "" ] ; then
        CODE_SIGN_IDENTITY_FOR_ITEMS="${CODE_SIGN_IDENTITY}"
    fi

    BINARY_NAME=`basename ${FRAMEWORK_DESTINATION} .framework`
    codesign --force --sign "${CODE_SIGN_IDENTITY_FOR_ITEMS}" ${FRAMEWORK_DESTINATION}/${BINARY_NAME}
    echo " ✅ Embedded successfully"
else
    echo " ℹ️ Non Debug build detected - do not embed"
fi
