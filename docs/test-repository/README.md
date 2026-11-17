# Git GUI Expand Test Repository

本仓库用于验证 Git GUI Expand 的 Git 图形化功能。

- 主软件项目：<https://github.com/CY68GI/Git_Gui_Expand>
- 测试远程：`git@github.com:CY68GI/Git_Gui_Expand_Test_Repository.git`
- 默认分支：`main`

## 软件截图

| 主页面 | 操作计划 |
| --- | --- |
| <img src="docs/images/start-page.png" width="480" alt="Git GUI Expand 主页面"> | <img src="docs/images/operation-plan.png" width="480" alt="操作计划"> |

| 远端管理 | 外观设置 |
| --- | --- |
| <img src="docs/images/remote-management.png" width="480" alt="远端管理"> | <img src="docs/images/appearance-settings.png" width="480" alt="外观设置"> |

## 已完成的测试

- 打开仓库、读取状态、当前分支和仓库统计
- 文件和文件夹复制、移动、重命名、新增与删除
- 暂存、取消暂存和提交
- 操作计划确认与逐步执行
- 分支创建、切换、重命名、安全删除和强制删除
- Stash 创建、列表、应用、弹出和删除
- Stash 包含未跟踪文件
- Git Clone 与空目录 `git init`
- Remote 查看、添加、修改、删除和多远端管理
- 推送当前分支
- 清空远端全部分支、标签和提交历史
- 清除无 Remote 仓库的 `.git` 元数据
- GitHub/Gitee 双更新源和 SHA-256 验证
- 浅色、深色、系统外观、配色、语言、字体和单位设置
- 普通日志、详细日志、桌面快捷方式和 Launcher 更新

## 完整测试报告

- [主要功能烟雾测试](docs/test-report.md)
- [破坏性完整 Git 测试](docs/full-git-test-report.md)

## 说明

破坏性测试会清空远端历史、强制删除分支和 Stash，并可能清除本地 `.git`。
测试前应确认仓库属于测试用途，且不包含需要保留的数据。
