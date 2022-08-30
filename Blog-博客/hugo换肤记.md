---
title: "Hugo 换肤记"
date: "2021-01-21"
categories:
    - "技术"
tags:
    - "Hugo"
    - "Blog"
toc: false
original: true
draft: false
---

## 更新记录

| 时间       | 内容                         |
| ---------- | ---------------------------- |
| 2021-01-21 | 更新主题 && 初稿 && 查找资料 |
| 2021-01-25 | 完善文章                     |
| 2021-01-27 | 微信图标                     |
| 2021-01-29 | TOC目录                      |

## 主题

最近搜到了 [cleanwhite](https://themes.gohugo.io/hugo-theme-cleanwhite/) 这个主题, 这个主题移植自 Hexo 的 hux 主题。

简洁大气，非常的适合做Blog，由此又起了换主题的心思。

## 运行起来

``` zsh
# 克隆主题源码 至themes
➜  git clone https://github.com/zhaohuabing/hugo-theme-cleanwhite.git themes/cleanwhite

# 拷贝示例config
➜  cp themes/cleanwhite/exampleSite/config.toml /root/blog/

# 生成静态页
➜  cd /root/blog/ && ./hugo -b http://fage.io
```

## 未完成目标

关于博客有哪些是我需要的功能

- 文章目录          （刚需）
- TOP按钮           （刚需）
- 站内搜索          （刚需）
- 文章列表 && 分类   （重要）
- Kindle 笔记
- gitbook 笔记
- K8s 知识图谱 + 站内导航
- 留言              （次要功能）

## TOC 改造

cleanwhite 虽然有目录 (Table of Contents) 功能，但他的目录是在文章顶部，既不美观也不方便，我需要的是侧边栏的目录，文章结构一目了然，可以随时点击跳转，阅读的便利性无可替代。

### 移除原样式

目录控制代码在 `themes/cleanwhite/layouts/_default/single.html` 中

``` html
# 移除原 TOC 样式
<!--
                {{ if not (eq (.Param "showtoc") false) }}
                <header>
                    <h2>TOC</h2>
                </header>
                {{.TableOfContents}}
                {{ end }}
-->
```

### 新样式

在 `themes/cleanwhite/layouts/_default/single.html` 中做如下修改
引入目录模板

``` html
{{ if .Site.Params.toc }}
    {{ partial "toc.html" . }}               <!-- 目录 -->
{{ end }}
```

### 目录模板

在 `themes/cleanwhite/layouts/partials/` 目录中新建 `toc.html` 模板

``` zsh
<!-- toc.html -->
<!-- ignore empty links with + -->
{{ $headers := findRE "<h[1-4].*?>(.|\n])+?</h[1-4]>" .Content }}
<!-- at least one header to link to -->
{{ if ge (len $headers) 1 }}
    {{ $h1_n := len (findRE "(.|\n])+?" .Content) }}
    {{ $re := (cond (eq $h1_n 0) "<h[2-4]" "<h[1-4]") }}
    {{ $renum := (cond (eq $h1_n 0) "[2-4]" "[1-4]") }}

    <div class="side-catalog">
        <hr class="hidden-sm hidden-xs">
        <h5>
            <a class="catalog-toggle" href="#">CATALOG</a>
        </h5>
        <ul class="catalog-body">
            {{ range $headers }}
                {{ $header := . }}
                {{ range first 1 (findRE $re $header 1) }}
                    {{ range findRE $renum . 1 }}
                        {{ $next_heading := (cond (eq $h1_n 0) (sub (int .) 1 ) (int . ) ) }}
                        {{ $anchorId := (replaceRE ".* id=\"(.*?)\".*" "$1" $header ) }}  <!-- 标题ID -->
                            <li class="h{{ $next_heading }}_nav" >
                                <a href="#{{ $anchorId }}" rel="nofollow">
                                    {{ $header | plainify | htmlUnescape }}
                                </a>
                            </li>
                    {{ end }}
                {{ end }}
            {{ end }}
        </ul>
    </div>
{{ end }}
```

## 微信图标不显示

底部图标 修改 `themes/cleanwhite/layouts/partials/footer.html` 文件
关于图标 修改 `themes/cleanwhite/layouts/partials/sidebar.html` 文件

``` zsh
        <!-- Huabing: add wechat QR code link -->
        {{ with .Site.Params.social.wechat }}
        <li>
            <a target="_blank" href="{{ . | relURL }}">
            <span class="fa-stack fa-lg">
                <i class="fas fa-circle fa-stack-2x"></i>
                <i class="fab fa-weixin fa-stack-1x fa-inverse"></i>  # 将 fa-wechat 改为 fa-weixin
                </span>
            </a>
        </li>
        {{ end }}
```

> 参考文章  
>
> - [Hugo theme - cleanwhite](https://themes.gohugo.io/hugo-theme-cleanwhite/)  
> - [赵化冰的博客](https://zhaohuabing.com/) && [源码地址](https://github.com/zhaohuabing/hugo-theme-cleanwhite)  
> - [黄玄的博客](https://huangxuan.me/) && [源码地址](https://github.com/Huxpro/huxpro.github.io)  
> - [Hugo 官方文档](https://www.gohugo.org/doc/)  
> - [Hugo TOC语法](https://www.gohugo.org/doc/extras/toc/)  
> - [Hugo + Even + GithubPages + Google Domains搭建个人博客（二）](https://tinocheng.app/post/%E6%90%AD%E5%BB%BA%E4%B8%AA%E4%BA%BA%E5%8D%9A%E5%AE%A22/)  
> - [Blog 养成记](https://orianna-zzo.github.io/series/blog%E5%85%BB%E6%88%90%E8%AE%B0/)  
> - [Hexo-NexT 主题个性化定制](https://st1020.top/hexo-next-theme-customization/)  
> - [Hugo 添加文章目录 toc](https://www.ariesme.com/posts/2019/add_toc_for_hugo/)  
> - [github - issues - 微信图标不显示](https://github.com/zhaohuabing/hugo-theme-cleanwhite/issues/96)  
>