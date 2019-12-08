function cleanup() {
    rm -rf "${BUILD_DIR}"
    rm -f "${LOCK_FILE}"

    echo "Cleanup is done"
}