1、ik分词
```
bin/elasticsearch-plugin install file:///usr/local/elasticsearch/elasticsearch-analysis-ik-7.1.1.zip
-> Downloading file:///usr/local/elasticsearch/elasticsearch-analysis-ik-7.1.1.zip
[=================================================] 100%   
Exception in thread "main" java.io.EOFException: Unexpected end of ZLIB input stream
	at java.base/java.util.zip.InflaterInputStream.fill(InflaterInputStream.java:245)
	at java.base/java.util.zip.InflaterInputStream.read(InflaterInputStream.java:159)
	at java.base/java.util.zip.ZipInputStream.read(ZipInputStream.java:195)
	at java.base/java.io.FilterInputStream.read(FilterInputStream.java:107)
	at org.elasticsearch.plugins.InstallPluginCommand.unzip(InstallPluginCommand.java:652)
	at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:230)
	at org.elasticsearch.plugins.InstallPluginCommand.execute(InstallPluginCommand.java:216)
	at org.elasticsearch.cli.EnvironmentAwareCommand.execute(EnvironmentAwareCommand.java:86)
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124)
	at org.elasticsearch.cli.MultiCommand.execute(MultiCommand.java:77)
	at org.elasticsearch.cli.Command.mainWithoutErrorHandling(Command.java:124)
	at org.elasticsearch.cli.Command.main(Command.java:90)
	at org.elasticsearch.plugins.PluginCli.main(PluginCli.java:47)
```