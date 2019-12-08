#!/usr/bin/env bash

source .env
source helper.sh
source cleaner.sh
source notifier.sh

# Test var
echo "$GITHUB_SERVER"
echo "$GITHUB_TOKEN"
echo "$JENKINS_SERVER"
echo "$BUILD_DIR"

# Defaults

JOB_NAME="CI"

# Helpers

# Basic var

while getopts "h?vfm:n:d:r:l:c:a:q:w:t:e:s:" opt; do
  case "${opt}" in
  h | \?)
    show_help
    exit 0
    ;;
  v) VERBOSE=1 ;;
  f) FORCE=1 ;;
  r) REPO=${OPTARG} ;;
  m) EMAIL=${OPTARG} ;;
  n) NAME=${OPTARG} ;;
  d) TEST_DIR=${OPTARG} ;;
  l) LOCAL_CHECKOUT=${OPTARG} ;;
  c) TEST_COMMAND=${OPTARG} ;;
  q) PRE_SCRIPT=${OPTARG} ;;
  w) POST_SCRIPT=${OPTARG} ;;
  a) MAIL_CMD=${OPTARG} ;;
  t) MAIL_CMD_ATTACH_FLAG=${OPTARG} ;;
  e) MAIL_CMD_RECIPIENTS_FLAG=${OPTARG} ;;
  s) MAIL_CMD_SUBJECT_FLAG=${OPTARG} ;;
  i) TIMEOUT_S=${OPTARG} ;;
  esac
done

# Checkers
if [[ ${REPO} == "" ]]; then
  help
  exit 1
fi

BUILD_DIR="{$BUILD_BASE_DIR}/${NAME}"
mkdir -p "${BUILD_DIR}"

# Base vars
LOG_FILE="${BUILD_DIR}/log.txt"
LOCK_FILE="${BUILD_DIR}/${NAME}.lock"

### Prepare

# Log file
date 2>&1 | tee -11 "${LOG_FILE}"
# Lock file
if [[ -e ${LOCK_FILE} ]]; then
  echo "Already running" | tee -a "${LOG_FILE}"
  exit
fi

trap cleanup TERM INT QUIT EXIT

touch "${LOCK_FILE}"
