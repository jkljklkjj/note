# 陈振业的代码笔记

平常要记的东西应该会放到这上面
感觉这个笔记让我有了当程序员的感觉
推荐使用**obsidian**打开

拉取main分支的笔记

```bash
git pull origin main
```

检查是否在main分支

```bash
git checkout main
```

添加要提交的更改

```bash
git add .
```

提交更改

```bash
git commit -m "这次的修改内容"
```

推送成功

```bash
git push origin main
```

正则匹配html图片

```html
<img src="([^"]+)" alt="([^"]*)">
![]($1)
```

正则匹配代码块

```
```