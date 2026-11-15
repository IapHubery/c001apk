# c001apk-flutter

A new Flutter project.

## 关于本项目 / Origin
**本项目基于上游两个开源项目改编，沿用 GNU Affero General Public License v3.0 (AGPL-3.0) 发布，详见 LICENSE.md。**

**代码主干血统（lineage）：**
```
bggRGjQaUbCoE/c001apk-flutter  (Flutter 重写，已归档)
        │
        ▼
RzdPai/c001apk                (Kotlin 重写，本项目代码主线)
        │
        ▼
WangMCweijia/c001apk ──fork──> IapHubery/c001apk (本仓库)
```
上游 Kotlin 主线：WangMCweijia/c001apk
上游 : RzdPai/c001apk
上游 Flutter 重写（已归档）：bggRGjQaUbCoE/c001apk-flutter
如上游更新，本项目会视情况进行同步（rebase/merge）。所有上游版权与许可声明均完整保留在 LICENSE.md。

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### 本地项目关联已有 GitHub 仓库
#### 1. 先确认远程仓库地址和分支
在 GitHub 项目页复制仓库地址，例如：
```bash
https://github.com/用户名/仓库名.git
```
确认远程默认分支是 `main` 还是 `master`。

#### 2. 如果本地项目还没有 Git 仓库

在 Android Studio 底部打开 `Terminal`，在项目根目录执行：

```bash
git init
git add .
git commit -m "commit comment"
git remote add origin https://github.com/用户名/仓库名.git
```

**将本地分支重命名为 `main`**：
```bash
git branch -M main
```

**查看当前所在分支**：
```bash
git branch
```

**检查远程：**
```bash
git remote -v
```

#### 3. 拉取远程已有内容并合并
**如果 GitHub 仓库里已经有代码/README/.gitignore，直接 push 会报错，需要先拉取：**
```bash
git pull origin main --allow-unrelated-histories
```

**如果远程分支是 `master`，把 `main` 换成 `master`。
可能会遇到冲突，解决冲突文件后：**

```bash
git add .
git commit -m "commit comment"
```

#### 4. 推送到 GitHub
```bash
git push -u origin main
```

## Credits:
- [pilipala](https://github.com/guozhigq/pilipala)
