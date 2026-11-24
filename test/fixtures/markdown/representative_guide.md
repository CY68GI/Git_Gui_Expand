# Representative Guide

Paragraph with **strong text**, *emphasis*, ~~strikethrough~~, `inline code`,
an [HTTPS link](https://example.com/docs?mode=safe), and escaped \*asterisks\*.

## Nested lists

- First item
  - Nested **strong** item
  - Nested item with [relative guide](USER_GUIDE.zh-CN.md)
- Second item

1. Ordered item
2. Ordered item with `code`

> Quoted paragraph with **formatted text** and a [heading anchor](#code-block).
>
> - Quoted list item

## Table

| Element | Status |
| --- | --- |
| Headings | Rendered |
| Links | Safe |

---

## Code block

```powershell
git status
git add -A
git commit -m "multi-line code block with a very long sentence that must scroll"
```

![Operation plan](images/operation-plan.png)

<script>alert("must never execute")</script>

[JavaScript](javascript:alert('blocked'))
[Data](data:text/html;base64,PHNjcmlwdD4=)
[File](file:///C:/Windows/System32/drivers/etc/hosts)
[Browser HTTP](http://example.com)
[Local path](C:/Windows/notepad.exe)
[Parent traversal](../secret.md)
