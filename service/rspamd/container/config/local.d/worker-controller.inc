# Bind to any IPv4 address.
bind_socket = "*v4:11334";

{% if env.CONTROLLER_PASSWORD %}
# Set password for priviledged actions.
password = "{= env.CONTROLLER_PASSWORD|pbkdf =}";
{% endif %}
