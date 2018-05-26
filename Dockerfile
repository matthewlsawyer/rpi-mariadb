FROM resin/rpi-raspbian

# Add necessary groups
RUN groupadd -r mysql && useradd -r -g mysql mysql

# Set debconf keys to make APT a little quieter
RUN { \
        echo mariadb-server mysql-server/root_password password 'unused'; \
        echo mariadb-server mysql-server/root_password_again password 'unused'; \
    } | debconf-set-selections \
    # Get mysql
    && apt-get -q update \
    && apt-get install -qy mariadb-server \
    # Comment out any "user" entries in the MySQL config (`entrypoint.sh` will handle users)
    && sed -ri 's/^user\s/#&/' /etc/mysql/my.cnf /etc/mysql/conf.d/* \
    # Purge and re-create /var/lib/mysql with appropriate ownership
    && rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld \
    && chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
    # Ensure that /var/run/mysqld (used for socket and lock files) is writable regardless of the UID
    && chmod 777 /var/run/mysqld \
    # Comment out a few problematic configuration values
    && sed -Ei 's/^(bind-address|log)/#&/' /etc/mysql/my.cnf \
    # Don't reverse lookup hostnames, they are usually another container
    && echo 'skip-host-cache\nskip-name-resolve' | awk '{ print } $1 == "[mysqld]" && c == 0 { c = 1; system("cat") }' /etc/mysql/my.cnf > /tmp/my.cnf \
    && mv /tmp/my.cnf /etc/mysql/my.cnf \
    # Clean out apt lists
    && rm -rf /var/lib/apt/lists/*

# Volume for DB data
VOLUME /var/lib/mysql

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]