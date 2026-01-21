# Bind to any IPv4 address.
bind_socket = "*v4:11334";

# Allow unauthenticated requests for read-only actions.
password = null;
secure_ip = null;

{% if env.CONTROLLER_PASSWORD %}
# Set password for priviledged actions.
enable_password = "{= env.CONTROLLER_PASSWORD|pbkdf =}";
{% endif %}
