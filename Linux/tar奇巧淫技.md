---
title: "tar 奇巧淫技"
date: "2020-08-07"
categories:
    - "技术"
tags:
    - "tar"
toc: false
original: false
---

## 更新记录

| 时间       | 内容 |
| ---------- | ---- |
| 2020-08-07 | 初稿 |

``` zsh
tar --help
Usage: tar [OPTION...] [FILE]...
GNU `tar' saves many files together into a single tape or disk archive, and can
restore individual files from the archive.

Examples:
  tar -cf archive.tar foo bar  # Create archive.tar from files foo and bar.
  tar -tvf archive.tar         # List all files in archive.tar verbosely.
  tar -xf archive.tar          # Extract all files from archive.tar.

 Main operation mode:

  -A, --catenate, --concatenate   append tar files to an archive
  -c, --create               create a new archive
  -d, --diff, --compare      find differences between archive and file system
      --delete               delete from the archive (not on mag tapes!)
  -r, --append               append files to the end of an archive
  -t, --list                 list the contents of an archive
      --test-label           test the archive volume label and exit
  -u, --update               only append files newer than copy in archive
  -x, --extract, --get       extract files from an archive

 Operation modifiers:

      --check-device         check device numbers when creating incremental
                             archives (default)
  -g, --listed-incremental=FILE   handle new GNU-format incremental backup
  -G, --incremental          handle old GNU-format incremental backup
      --ignore-failed-read   do not exit with nonzero on unreadable files
      --level=NUMBER         dump level for created listed-incremental archive
  -n, --seek                 archive is seekable
      --no-check-device      do not check device numbers when creating
                             incremental archives
      --no-seek              archive is not seekable
      --occurrence[=NUMBER]  process only the NUMBERth occurrence of each file
                             in the archive; this option is valid only in
                             conjunction with one of the subcommands --delete,
                             --diff, --extract or --list and when a list of
                             files is given either on the command line or via
                             the -T option; NUMBER defaults to 1
      --sparse-version=MAJOR[.MINOR]
                             set version of the sparse format to use (implies
                             --sparse)
  -S, --sparse               handle sparse files efficiently

 Overwrite control:

  -k, --keep-old-files       don't replace existing files when extracting,
                             treat them as errors
      --keep-directory-symlink   preserve existing symlinks to directories when
                             extracting
      --keep-newer-files     don't replace existing files that are newer than
                             their archive copies
      --no-overwrite-dir     preserve metadata of existing directories
      --overwrite            overwrite existing files when extracting
      --overwrite-dir        overwrite metadata of existing directories when
                             extracting (default)
      --recursive-unlink     empty hierarchies prior to extracting directory
      --remove-files         remove files after adding them to the archive
      --skip-old-files       don't replace existing files when extracting,
                             silently skip over them
  -U, --unlink-first         remove each file prior to extracting over it
  -W, --verify               attempt to verify the archive after writing it

 Select output stream:

      --ignore-command-error ignore exit codes of children
      --no-ignore-command-error   treat non-zero exit codes of children as
                             error
  -O, --to-stdout            extract files to standard output
      --to-command=COMMAND   pipe extracted files to another program

 Handling of file attributes:

      --atime-preserve[=METHOD]   preserve access times on dumped files, either
                             by restoring the times after reading
                             (METHOD='replace'; default) or by not setting the
                             times in the first place (METHOD='system')
      --delay-directory-restore   delay setting modification times and
                             permissions of extracted directories until the end
                             of extraction
      --group=NAME           force NAME as group for added files
      --mode=CHANGES         force (symbolic) mode CHANGES for added files
      --mtime=DATE-OR-FILE   set mtime for added files from DATE-OR-FILE
  -m, --touch                don't extract file modified time
      --no-delay-directory-restore
                             cancel the effect of --delay-directory-restore
                             option
      --no-same-owner        extract files as yourself (default for ordinary
                             users)
      --no-same-permissions  apply the user's umask when extracting permissions
                             from the archive (default for ordinary users)
      --numeric-owner        always use numbers for user/group names
      --owner=NAME           force NAME as owner for added files
  -p, --preserve-permissions, --same-permissions
                             extract information about file permissions
                             (default for superuser)
      --preserve             same as both -p and -s
      --same-owner           try extracting files with the same ownership as
                             exists in the archive (default for superuser)
  -s, --preserve-order, --same-order
                             member arguments are listed in the same order as
                             the files in the archive

 Handling of extended file attributes:

      --acls                 Enable the POSIX ACLs support
      --no-acls              Disable the POSIX ACLs support
      --no-selinux           Disable the SELinux context support
      --no-xattrs            Disable extended attributes support
      --selinux              Enable the SELinux context support
      --xattrs               Enable extended attributes support
      --xattrs-exclude=MASK  specify the exclude pattern for xattr keys
      --xattrs-include=MASK  specify the include pattern for xattr keys

 Device selection and switching:

  -f, --file=ARCHIVE         use archive file or device ARCHIVE
      --force-local          archive file is local even if it has a colon
  -F, --info-script=NAME, --new-volume-script=NAME
                             run script at end of each tape (implies -M)
  -L, --tape-length=NUMBER   change tape after writing NUMBER x 1024 bytes
  -M, --multi-volume         create/list/extract multi-volume archive
      --rmt-command=COMMAND  use given rmt COMMAND instead of rmt
      --rsh-command=COMMAND  use remote COMMAND instead of rsh
      --volno-file=FILE      use/update the volume number in FILE

 Device blocking:

  -b, --blocking-factor=BLOCKS   BLOCKS x 512 bytes per record
  -B, --read-full-records    reblock as we read (for 4.2BSD pipes)
  -i, --ignore-zeros         ignore zeroed blocks in archive (means EOF)
      --record-size=NUMBER   NUMBER of bytes per record, multiple of 512

 Archive format selection:

  -H, --format=FORMAT        create archive of the given format

 FORMAT is one of the following:

    gnu                      GNU tar 1.13.x format
    oldgnu                   GNU format as per tar <= 1.12
    pax                      POSIX 1003.1-2001 (pax) format
    posix                    same as pax
    ustar                    POSIX 1003.1-1988 (ustar) format
    v7                       old V7 tar format

      --old-archive, --portability
                             same as --format=v7
      --pax-option=keyword[[:]=value][,keyword[[:]=value]]...
                             control pax keywords
      --posix                same as --format=posix
  -V, --label=TEXT           create archive with volume name TEXT; at
                             list/extract time, use TEXT as a globbing pattern
                             for volume name

 Compression options:

  -a, --auto-compress        use archive suffix to determine the compression
                             program
  -I, --use-compress-program=PROG
                             filter through PROG (must accept -d)
  -j, --bzip2                filter the archive through bzip2
  -J, --xz                   filter the archive through xz
      --lzip                 filter the archive through lzip
      --lzma                 filter the archive through lzma
      --lzop
      --no-auto-compress     do not use archive suffix to determine the
                             compression program
  -z, --gzip, --gunzip, --ungzip   filter the archive through gzip
  -Z, --compress, --uncompress   filter the archive through compress

 Local file selection:

      --add-file=FILE        add given FILE to the archive (useful if its name
                             starts with a dash)
      --backup[=CONTROL]     backup before removal, choose version CONTROL
  -C, --directory=DIR        change to directory DIR
      --exclude=PATTERN      exclude files, given as a PATTERN
      --exclude-backups      exclude backup and lock files
      --exclude-caches       exclude contents of directories containing
                             CACHEDIR.TAG, except for the tag file itself
      --exclude-caches-all   exclude directories containing CACHEDIR.TAG
      --exclude-caches-under exclude everything under directories containing
                             CACHEDIR.TAG
      --exclude-tag=FILE     exclude contents of directories containing FILE,
                             except for FILE itself
      --exclude-tag-all=FILE exclude directories containing FILE
      --exclude-tag-under=FILE   exclude everything under directories
                             containing FILE
      --exclude-vcs          exclude version control system directories
  -h, --dereference          follow symlinks; archive and dump the files they
                             point to
      --hard-dereference     follow hard links; archive and dump the files they
                             refer to
  -K, --starting-file=MEMBER-NAME
                             begin at member MEMBER-NAME when reading the
                             archive
      --newer-mtime=DATE     compare date and time when data changed only
      --no-null              disable the effect of the previous --null option
      --no-recursion         avoid descending automatically in directories
      --no-unquote           do not unquote filenames read with -T
      --null                 -T reads null-terminated names, disable -C
  -N, --newer=DATE-OR-FILE, --after-date=DATE-OR-FILE
                             only store files newer than DATE-OR-FILE
      --one-file-system      stay in local file system when creating archive
  -P, --absolute-names       don't strip leading `/'s from file names
      --recursion            recurse into directories (default)
      --suffix=STRING        backup before removal, override usual suffix ('~'
                             unless overridden by environment variable
                             SIMPLE_BACKUP_SUFFIX)
  -T, --files-from=FILE      get names to extract or create from FILE
      --unquote              unquote filenames read with -T (default)
  -X, --exclude-from=FILE    exclude patterns listed in FILE

 File name transformations:

      --strip-components=NUMBER   strip NUMBER leading components from file
                             names on extraction
      --transform=EXPRESSION, --xform=EXPRESSION
                             use sed replace EXPRESSION to transform file
                             names

 File name matching options (affect both exclude and include patterns):

      --anchored             patterns match file name start
      --ignore-case          ignore case
      --no-anchored          patterns match after any `/' (default for
                             exclusion)
      --no-ignore-case       case sensitive matching (default)
      --no-wildcards         verbatim string matching
      --no-wildcards-match-slash   wildcards do not match `/'
      --wildcards            use wildcards (default)
      --wildcards-match-slash   wildcards match `/' (default for exclusion)

 Informative output:

      --checkpoint[=NUMBER]  display progress messages every NUMBERth record
                             (default 10)
      --checkpoint-action=ACTION   execute ACTION on each checkpoint
      --full-time            print file time to its full resolution
      --index-file=FILE      send verbose output to FILE
  -l, --check-links          print a message if not all links are dumped
      --no-quote-chars=STRING   disable quoting for characters from STRING
      --quote-chars=STRING   additionally quote characters from STRING
      --quoting-style=STYLE  set name quoting style; see below for valid STYLE
                             values
  -R, --block-number         show block number within archive with each message

      --show-defaults        show tar defaults
      --show-omitted-dirs    when listing or extracting, list each directory
                             that does not match search criteria
      --show-transformed-names, --show-stored-names
                             show file or archive names after transformation
      --totals[=SIGNAL]      print total bytes after processing the archive;
                             with an argument - print total bytes when this
                             SIGNAL is delivered; Allowed signals are: SIGHUP,
                             SIGQUIT, SIGINT, SIGUSR1 and SIGUSR2; the names
                             without SIG prefix are also accepted
      --utc                  print file modification times in UTC
  -v, --verbose              verbosely list files processed
      --warning=KEYWORD      warning control
  -w, --interactive, --confirmation
                             ask for confirmation for every action

 Compatibility options:

  -o                         when creating, same as --old-archive; when
                             extracting, same as --no-same-owner

 Other options:

  -?, --help                 give this help list
      --restrict             disable use of some potentially harmful options
      --usage                give a short usage message
      --version              print program version

Mandatory or optional arguments to long options are also mandatory or optional
for any corresponding short options.

The backup suffix is `~', unless set with --suffix or SIMPLE_BACKUP_SUFFIX.
The version control may be set with --backup or VERSION_CONTROL, values are:

  none, off       never make backups
  t, numbered     make numbered backups
  nil, existing   numbered if numbered backups exist, simple otherwise
  never, simple   always make simple backups

Valid arguments for the --quoting-style option are:

  literal
  shell
  shell-always
  c
  c-maybe
  escape
  locale
  clocale

*This* tar defaults to:
--format=gnu -f- -b20 --quoting-style=escape --rmt-command=/etc/rmt
--rsh-command=/usr/bin/ssh

Report bugs to <bug-tar@gnu.org>.
```

## 打包格式

``` zsh
Examples:
  tar -cf archive.tar foo bar  # Create archive.tar from files foo and bar.
  tar -tvf archive.tar         # List all files in archive.tar verbosely.
  tar -xf archive.tar          # Extract all files from archive.tar.
```

## 压缩格式

``` zsh
Compression options:

  -a, --auto-compress        use archive suffix to determine the compression
                             program
  -I, --use-compress-program=PROG
                             filter through PROG (must accept -d)
  -j, --bzip2                filter the archive through bzip2
  -J, --xz                   filter the archive through xz
      --lzip                 filter the archive through lzip
      --lzma                 filter the archive through lzma
      --lzop
      --no-auto-compress     do not use archive suffix to determine the
                             compression program
  -z, --gzip, --gunzip, --ungzip   filter the archive through gzip
  -Z, --compress, --uncompress   filter the archive through compress

# gzip
➜  gzip FileName                     # 压 缩
➜  gunzip FileName.gz                # 解压1
➜  gzip -d FileName.gz               # 解压2

# tar.gz
➜  tar zcvf FileName.tar.gz foo bar  # 压缩
➜  tar zxvf FileName.tar.gz          # 解压

# bzip2
➜  bzip2 -z FileName                 # 压 缩
➜  bzip2 -d FileName.bz2             # 解压1
➜  bunzip2 FileName.bz2              # 解压2
# tar.bz2
➜  tar jcvf FileName.tar.bz2 foo bar # 压缩
➜  tar jxvf FileName.tar.bz2         # 解压

# compress
➜  compress FileName                 # 压缩
➜  uncompress FileName.Z             # 解压
# tar.Z
➜  tar Zcvf FileName.tar.Z foo bar   # 压缩
➜  tar Zxvf FileName.tar.Z           # 解压

# xz
```

## tar包内文件操作 (删除 && 添加)

``` zsh
# 打包
➜  tar -cf ty-loki.tar loki
➜  tar -tvf ty-loki.tar
drwxr-xr-x root/root         0 2020-08-04 16:06 loki/
-rwxr-xr-x root/root  88166400 2020-07-21 17:19 loki/loki-linux-amd64
-rw-r--r-- root/root       792 2020-07-21 17:45 loki/loki-local-config.yaml
-rw------- root/root   1586951 2020-08-04 16:06 loki/nohup.out
-rw-r--r-- root/root         0 2020-08-07 09:34 loki/loki.log

# 删除tar包中的文件
➜  tar -vf ty-loki.tar --delete loki/nohup.out loki/loki.log
➜  tar -tvf ty-loki.tar
drwxr-xr-x root/root         0 2020-08-04 16:06 loki/
-rwxr-xr-x root/root  88166400 2020-07-21 17:19 loki/loki-linux-amd64
-rw-r--r-- root/root       792 2020-07-21 17:45 loki/loki-local-config.yaml

# 往tar包中添加文件
# tar包只能往一个层级添加文件，所以先将其他文件夹下的文件拷过来。
➜  cp /usr/lib/systemd/system/loki.service loki
➜  tar -rvf ty-loki.tar loki/loki.service
loki/loki.service
➜  tar -tvf ty-loki.tar
drwxr-xr-x root/root         0 2020-08-04 16:06 loki/
-rwxr-xr-x root/root  88166400 2020-07-21 17:19 loki/loki-linux-amd64
-rw-r--r-- root/root       792 2020-07-21 17:45 loki/loki-local-config.yaml
-rw-r--r-- root/root       390 2020-08-07 18:54 loki/loki.service
```

## 解压tar包内指定文件

``` zsh

```
