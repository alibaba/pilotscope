cd plugins/

tar -xf 1.4.0.tar.gz && cd hypopg-1.4.0 && make && make install && cd ../

tar -xf REL13_1_3_9.tar.gz && cd pg_hint_plan-REL13_1_3_9/ && make && make install && cd ../../

cd contrib/pg_buffercache && make && make install && cd ../..