use inc::Module::Install;
name 'CIF';
version '1.5';
DIR => ['libcif-dbi', 'libcif'];
cpanfile;

postamble <<EOS
initdb: 
\tcd libcif-dbi && make initdb

dropdb:
\tcd libcif-dbi && make dropdb

purgedb:
\tcd libcif-dbi && make purgedb
EOS
;
WriteAll;
