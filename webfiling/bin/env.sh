# Specify JVM options
JVM_OPTS="${IG_JVM_ARGS}"

echo "args: ${IG_JVM_ARGS}"

export ROOT_LOG_LEVEL=${ROOT_LOG_LEVEL}

# Specify the DH key size for stronger ephemeral DH keys, and to protect against weak keys
JSSE_OPTS="-Djdk.tls.ephemeralDHKeySize=2048"

# Wrap them up into the JAVA_OPTS environment variable
export JAVA_OPTS="${JAVA_OPTS} ${JVM_OPTS} -DROOT_LOG_LEVEL=${ROOT_LOG_LEVEL:-WARN}"

echo "EWF IG - ${JAVA_OPTS}"
