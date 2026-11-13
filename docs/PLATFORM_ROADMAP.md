# 平台路线

## Windows

当前状态：开发与验证目标。

- Flutter Windows runner 已生成。
- 原生文件夹选择器通过 PowerShell WinForms 调用。
- 外链通过 PowerShell `Start-Process` 打开。
- Windows ICO 包含 16 到 256 像素的圆角矩形树形图标。
- 运行数据固定在 `<Release目录>/userdata`，发布说明要求解压到可写目录。
- `.github/workflows/windows-release.yml` 在推送 `v*` 标签时构建并上传 Windows ZIP。
- 目标环境为 Windows 10/11，需安装 Git 与 Visual Studio C++ 桌面工具链。

## Linux

当前状态：目录保留，未开发，未验证。

后续工作：

- 文件选择器替代方案；
- `xdg-open` 外链行为验证；
- GTK 窗口标题、最小尺寸和缩放验证；
- AppImage/Flatpak/deb 打包策略；
- 文件模式位与符号链接的完整测试。
- 将预留的 `linux/icons/hicolor/256x256/apps/git_gui_expand.png` 接入桌面包元数据。

## macOS

当前状态：目录保留，未开发，未验证。

- 需要原生文件夹选择面板；
- 需要 `open` 外链行为验证；
- 需要 Apple Silicon/Intel 构建与公证策略；
- 需要沙盒权限对用户仓库访问的支持评估。
- AppIcon 图标集已替换为统一圆角矩形树形图标，但尚未在 macOS 构建验证。

## 共同前置条件

- 跨平台窗口最小尺寸；
- 平台级文件选择器抽象；
- 更完整的路径大小写与 Unicode 测试；
- Git 配置、钩子提示和安全执行策略；
- Windows 已支持 SHA-256 校验、备份、原位替换和错误回滚的自动更新；Linux/macOS
  仍需各自的更新助手、权限和签名验证方案。
