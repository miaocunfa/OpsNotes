---
title: "MongoDB 数据导入 && 导出"
date: "2020-05-27"
categories:
    - "技术"
tags:
    - "Mongo"
    - "数据导出"
    - "数据导入"
toc: false
original: true
---

## 更新记录

| 时间       | 内容            |
| ---------- | --------------- |
| 2020-05-27 | 初稿            |
| 2020-08-07 | 1、添加数据导入 |

## 一、数据导出

### 1.1、mongoexport

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

### 1.2、数据导出

``` bash
    -d：   数据库名
    -c：   collection名
    -o：   输出的文件名
--type：   输出的格式，默认为json
    -f：   输出的字段，如果-type为csv，则需要加上-f "字段名"

➜  ./mongoexport -d info -c collection1 -o /home/miaocunfa/info_collection1.json
➜  cd /home/miaocunfa/
➜  chown miaocunfa:miaocunfa info_collection1.json

./mongoexport -d aihang3 -c info -o ~/aihang3_info.json
2020-08-07T10:04:27.429+0800  connected to: mongodb://localhost/
2020-08-07T10:04:27.437+0800  exported 45 records
```

## 二、数据导入

### 2.1、mongoimport

``` zsh
./mongoimport --help
Usage:
  mongoimport <options> <file>

Import CSV, TSV or JSON data into MongoDB. If no file is provided, mongoimport reads from stdin.

See http://docs.mongodb.org/manual/reference/program/mongoimport/ for more information.

general options:
      --help                                      print usage
      --version                                   print the tool version and exit

verbosity options:
  -v, --verbose=<level>                           more detailed log output (include multiple times for more verbosity, e.g. -vvvvv, or specify a numeric value, e.g. --verbose=N)
      --quiet                                     hide all log output

connection options:
  -h, --host=<hostname>                           mongodb host to connect to (setname/host1,host2 for replica sets)
      --port=<port>                               server port (can also use --host hostname:port)

ssl options:
      --ssl                                       connect to a mongod or mongos that has ssl enabled
      --sslCAFile=<filename>                      the .pem file containing the root certificate chain from the certificate authority
      --sslPEMKeyFile=<filename>                  the .pem file containing the certificate and key
      --sslPEMKeyPassword=<password>              the password to decrypt the sslPEMKeyFile, if necessary
      --sslCRLFile=<filename>                     the .pem file containing the certificate revocation list
      --sslAllowInvalidCertificates               bypass the validation for server certificates
      --sslAllowInvalidHostnames                  bypass the validation for server name
      --sslFIPSMode                               use FIPS mode of the installed openssl library

authentication options:
  -u, --username=<username>                       username for authentication
  -p, --password=<password>                       password for authentication
      --authenticationDatabase=<database-name>    database that holds the user's credentials
      --authenticationMechanism=<mechanism>       authentication mechanism to use

kerberos options:
      --gssapiServiceName=<service-name>          service name to use when authenticating using GSSAPI/Kerberos (default: mongodb)
      --gssapiHostName=<host-name>                hostname to use when authenticating using GSSAPI/Kerberos (default: <remote server's address>)

namespace options:
  -d, --db=<database-name>                        database to use
  -c, --collection=<collection-name>              collection to use

uri options:
      --uri=mongodb-uri                           mongodb uri connection string

input options:
  -f, --fields=<field>[,<field>]*                 comma separated list of fields, e.g. -f name,age
      --fieldFile=<filename>                      file with field names - 1 per line
      --file=<filename>                           file to import from; if not specified, stdin is used
      --headerline                                use first line in input source as the field list (CSV and TSV only)
      --jsonArray                                 treat input source as a JSON array
      --parseGrace=<grace>                        controls behavior when type coercion fails - one of: autoCast, skipField, skipRow, stop (defaults to 'stop') (default: stop)
      --type=<type>                               input format to import: json, csv, or tsv (defaults to 'json') (default: json)
      --columnsHaveTypes                          indicated that the field list (from --fields, --fieldsFile, or --headerline) specifies types; They must be in the form of
                                                  '<colName>.<type>(<arg>)'. The type can be one of: auto, binary, bool, date, date_go, date_ms, date_oracle, double, int32, int64, string.
                                                  For each of the date types, the argument is a datetime layout string. For the binary type, the argument can be one of: base32, base64,
                                                  hex. All other types take an empty argument. Only valid for CSV and TSV imports. e.g. zipcode.string(), thumbnail.binary(base64)
      --legacy                                    use the legacy extended JSON format (defaults to 'false') (default: false)

ingest options:
      --drop                                      drop collection before inserting documents
      --ignoreBlanks                              ignore fields with empty values in CSV and TSV
      --maintainInsertionOrder                    insert the documents in the order of their appearance in the input source. By default the insertions will be performed in an arbitrary
                                                  order. Setting this flag also enables the behavior of --stopOnError and restricts NumInsertionWorkers to 1.
  -j, --numInsertionWorkers=<number>              number of insert operations to run concurrently (defaults to 1) (default: 1)
      --stopOnError                               halt after encountering any error during importing. By default, mongoimport will attempt to continue through document validation and
                                                  DuplicateKey errors, but with this option enabled, the tool will stop instead. A small number of documents may be inserted after
                                                  encountering an error even with this option enabled; use --maintainInsertionOrder to halt immediately after an error
      --mode=[insert|upsert|merge]                insert: insert only. upsert: insert or replace existing documents. merge: insert or modify existing documents. defaults to insert
      --upsertFields=<field>[,<field>]*           comma-separated fields for the query part when --mode is set to upsert or merge
      --writeConcern=<write-concern-specifier>    write concern options e.g. --writeConcern majority, --writeConcern '{w: 3, wtimeout: 500, fsync: true, j: true}'
      --bypassDocumentValidation                  bypass document validation
```

### 2.2、数据导入

``` zsh
./mongoimport -h 192.168.100.226 -p 21000 -d ahtest -c info --file=~/aihang3_info.json
```

> 参考文章：  
> 1、<https://www.jianshu.com/p/7ccad7b8ee18>
>