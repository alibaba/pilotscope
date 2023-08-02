run

```
pip install . -e
```

to install pilotscope

install stats_tiny dataset for test:

after create a database named stats_tiny in postgres, run

```
psql stats_tiny -U postgres < tests/stats_tiny.sql
```