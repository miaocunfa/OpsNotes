---
title: "Mongo数据导出"
date: "2020-05-27"
categories:
    - "技术"
tags:
    - "Mongo"
    - "数据导出"
toc: false
original: true
---

## mongoexport

``` bash
➜  ./mongoexport --help
Usage:
  mongoexport <options>

Export data from MongoDB in CSV or JSON format.

See http://docs.mongodb.org/manual/reference/program/mongoexport/ for more information.

general options:
      --help                                      print usage
      --version                                   print the tool version and exit

verbosity options:
  -v, --verbose=<level>                           more detailed log output (include multiple times for more verbosity, e.g. -vvvvv, or specify a numeric value, e.g.
                                                  --verbose=N)
      --quiet                                     hide all log output

connection options:
  -h, --host=<hostname>                           mongodb host to connect to (setname/host1,host2 for replica sets)
      --port=<port>                               server port (can also use --host hostname:port)

authentication options:
  -u, --username=<username>                       username for authentication
  -p, --password=<password>                       password for authentication
      --authenticationDatabase=<database-name>    database that holds the user's credentials
      --authenticationMechanism=<mechanism>       authentication mechanism to use

namespace options:
  -d, --db=<database-name>                        database to use
  -c, --collection=<collection-name>              collection to use

uri options:
      --uri=mongodb-uri                           mongodb uri connection string

output options:
  -f, --fields=<field>[,<field>]*                 comma separated list of field names (required for exporting CSV) e.g. -f "name,age"
      --fieldFile=<filename>                      file with field names - 1 per line
      --type=<type>                               the output format, either json or csv (defaults to 'json') (default: json)
  -o, --out=<filename>                            output file; if not specified, stdout is used
      --jsonArray                                 output to a JSON array rather than one object per line
      --pretty                                    output JSON formatted to be human-readable
      --noHeaderLine                              export CSV data without a list of field names at the first line

querying options:
  -q, --query=<json>                              query filter, as a JSON string, e.g., '{x:{$gt:1}}'
      --queryFile=<filename>                      path to a file containing a query filter (JSON)
  -k, --slaveOk                                   allow secondary reads if available (default true) (default: false)
      --readPreference=<string>|<json>            specify either a preference name or a preference json object
      --forceTableScan                            force a table scan (do not use $snapshot)
      --skip=<count>                              number of documents to skip
      --limit=<count>                             limit the number of documents to export
      --sort=<json>                               sort order, as a JSON string, e.g. '{x:1}'
      --assertExists                              if specified, export fails if the collection does not exist (default: false)
```

## 数据导出

``` bash
    -d：   数据库名
    -c：   collection名
    -o：   输出的文件名
--type：   输出的格式，默认为json
    -f：   输出的字段，如果-type为csv，则需要加上-f "字段名"

➜  ./mongoexport -d info -c collection1 -o /home/miaocunfa/info_collection1.json
➜  cd /home/miaocunfa/
➜  chown miaocunfa:miaocunfa info_collection1.json
```

> 参考文章：  
> 1、<https://www.jianshu.com/p/7ccad7b8ee18>
>