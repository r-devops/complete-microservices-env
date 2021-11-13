sudo yum -y install https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm

sudo yum -y install epel-release yum-utils
sudo yum-config-manager --enable pgdg12
sudo yum install postgresql12-server postgresql12 -y
sudo /usr/pgsql-12/bin/postgresql-12-setup initdb

sudo systemctl enable --now postgresql-12

sed -i -e "/listen_addresses/ c listen_addresses = '*' " /var/lib/pgsql/12/data/postgresql.conf
sed -i -e '/0.0.0.0/ d' /var/lib/pgsql/12/data/pg_hba.conf
sed -i -e '$ a host all all 0.0.0.0/0 md5' /var/lib/pgsql/12/data/pg_hba.conf
systemctl restart  --now postgresql-12

su - postgres -c psql<<EOF
create role readonly;
EOF

su - postgres -c psql<<EOF
CREATE USER admin WITH PASSWORD 'admin123';
CREATE DATABASE booking;
CREATE DATABASE financial;
EOF