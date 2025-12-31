FROM dumbwareio/dumbpad:latest

# Needs root at build time to adjust perms in the image
USER root
RUN chown -R 99:100 /app

# Non-root for runtime
USER 99:100