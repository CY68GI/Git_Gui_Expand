import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/settings_models.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const Locale english = Locale('en');
  static const Locale simplifiedChinese = Locale('zh', 'CN');
  static const Locale traditionalChinese = Locale.fromSubtags(
    languageCode: 'zh',
    scriptCode: 'Hant',
  );

  static const List<Locale> supportedLocales = [
    english,
    simplifiedChinese,
    traditionalChinese,
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(simplifiedChinese);
  }

  String get languageCode {
    if (locale.languageCode == 'en') return 'en';
    if (locale.languageCode == 'zh' &&
        (locale.scriptCode == 'Hant' ||
            const {'TW', 'HK', 'MO'}.contains(locale.countryCode))) {
      return 'zh_Hant';
    }
    return 'zh';
  }

  String tr(String source, [Map<String, Object?> values = const {}]) {
    final dictionary = _translations[languageCode] ?? const {};
    final exact = dictionary[source];
    String result;
    if (exact != null) {
      result = exact;
    } else {
      final runtime = _runtimeTranslations[languageCode]?[source];
      if (runtime != null) {
        result = runtime;
      } else {
        result =
            _translateDynamic(source) ??
            (languageCode == 'zh_Hant' ? _traditionalize(source) : source);
      }
    }
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return result;
  }

  String? _translateDynamic(String source) {
    if (languageCode == 'zh') {
      return null;
    }
    final english = languageCode == 'en';

    var match = RegExp(r'^Git GUI Expand v(.+) 启动；软件目录=(.+)$')
        .firstMatch(source);
    if (match != null) {
      return english
          ? 'Git GUI Expand v${match.group(1)} started; software directory='
                '${match.group(2)}'
          : 'Git GUI Expand v${match.group(1)} 啟動；軟體目錄='
                '${match.group(2)}';
    }

    match = RegExp(r'^设备外观变化：(.+)；当前模式=(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Device appearance changed: ${match.group(1)}; current mode='
                '${match.group(2)}'
          : '裝置外觀變更：${match.group(1)}；目前模式=${match.group(2)}';
    }

    match = RegExp(r'^请求打开仓库：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Requested to open repository: ${match.group(1)}'
          : '要求開啟儲存庫：${match.group(1)}';
    }

    match = RegExp(r'^用户选择仓库：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'User selected repository: ${match.group(1)}'
          : '使用者選擇儲存庫：${match.group(1)}';
    }

    match = RegExp(r'^仓库已打开：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Repository opened: ${match.group(1)}'
          : '儲存庫已開啟：${match.group(1)}';
    }

    match = RegExp(r'^打开仓库：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Open repository: ${match.group(1)}'
          : '開啟儲存庫：${match.group(1)}';
    }

    match = RegExp(r'^关闭仓库：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Close repository: ${match.group(1)}'
          : '關閉儲存庫：${match.group(1)}';
    }

    match = RegExp(r'^(left|right) 返回上一级$').firstMatch(source);
    if (match != null) {
      return english
          ? '${match.group(1)} explorer returned to parent folder'
          : '${match.group(1)} 資源面板返回上一層';
    }

    match = RegExp(r'^(left|right) 仅选中 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? '${match.group(1)} explorer selected only ${match.group(2)}'
          : '${match.group(1)} 資源面板僅選取 ${match.group(2)}';
    }

    match = RegExp(r'^(left|right) 全选 (\d+) 项$').firstMatch(source);
    if (match != null) {
      return english
          ? '${match.group(1)} explorer selected ${match.group(2)} items'
          : '${match.group(1)} 資源面板全選 ${match.group(2)} 項';
    }

    match = RegExp(r'^清空 (\d+) 项剪贴板内容$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Cleared ${match.group(1)} clipboard items'
          : '清除 ${match.group(1)} 項剪貼簿內容';
    }

    match = RegExp(r'^清空执行计划：(\d+) 步，未执行任何操作$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Cleared ${match.group(1)} planned steps; nothing was executed'
          : '清除 ${match.group(1)} 個計畫步驟；未執行任何操作';
    }

    match = RegExp(r'^执行计划完成：共 (\d+) 步$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Operation plan completed: ${match.group(1)} steps'
          : '操作計畫完成：共 ${match.group(1)} 步';
    }

    match = RegExp(r'^(left|right) 目录加载完成：(\d+) 项$').firstMatch(source);
    if (match != null) {
      return english
          ? '${match.group(1)} folder loaded: ${match.group(2)} items'
          : '${match.group(1)} 資料夾載入完成：${match.group(2)} 項';
    }

    match = RegExp(r'^开始统计仓库大小：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Calculating repository size: ${match.group(1)}'
          : '開始統計儲存庫大小：${match.group(1)}';
    }

    match = RegExp(r'^打开项目目录：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Open project folder: ${match.group(1)}'
          : '開啟專案目錄：${match.group(1)}';
    }

    match = RegExp(r'^在文件资源管理器中定位文件：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Reveal file in File Explorer: ${match.group(1)}'
          : '在檔案總管中定位檔案：${match.group(1)}';
    }

    match = RegExp(r'^使用默认打开方式打开文件：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Open file with default app: ${match.group(1)}'
          : '使用預設應用程式開啟檔案：${match.group(1)}';
    }

    match = RegExp(r'^新增远端 (.+) -> (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Add remote ${match.group(1)} -> ${match.group(2)}'
          : '新增遠端 ${match.group(1)} -> ${match.group(2)}';
    }

    match = RegExp(r'^更新远端 (.+) -> (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Update remote ${match.group(1)} -> ${match.group(2)}'
          : '更新遠端 ${match.group(1)} -> ${match.group(2)}';
    }

    match = RegExp(r'^删除远端 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Remove remote ${match.group(1)}'
          : '刪除遠端 ${match.group(1)}';
    }

    match = RegExp(r'^已推送 (.+) 到远端 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Pushed ${match.group(1)} to remote ${match.group(2)}'
          : '已推送 ${match.group(1)} 到遠端 ${match.group(2)}';
    }

    match = RegExp(r'^删除 (\d+) 项：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Deleting ${match.group(1)} items: ${match.group(2)}'
          : '刪除 ${match.group(1)} 項：${match.group(2)}';
    }

    match = RegExp(r'^删除完成：(\d+) 项$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Delete completed: ${match.group(1)} items'
          : '刪除完成：${match.group(1)} 項';
    }

    match = RegExp(r'^GitHub 更新接口 HTTP (\d+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'GitHub update API returned HTTP ${match.group(1)}'
          : 'GitHub 更新介面傳回 HTTP ${match.group(1)}';
    }

    match = RegExp(r'^更新检查完成：(\S+) latest=(.*)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Update check completed: ${match.group(1)} latest=${match.group(2)}'
          : '更新檢查完成：${match.group(1)} latest=${match.group(2)}';
    }

    match = RegExp(r'^检查更新异常：(.+)$', dotAll: true).firstMatch(source);
    if (match != null) {
      return english
          ? 'Update check error: ${match.group(1)}'
          : '檢查更新異常：${match.group(1)}';
    }

    match = RegExp(
      r'^从 Release 页面解析 SHA-256 失败：(.+)$',
      dotAll: true,
    ).firstMatch(source);
    if (match != null) {
      return english
          ? 'Failed to parse SHA-256 from Release page: ${match.group(1)}'
          : '從 Release 頁面解析 SHA-256 失敗：${match.group(1)}';
    }

    match = RegExp(r'^打开外部 HTTPS 链接：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Open external HTTPS link: ${match.group(1)}'
          : '開啟外部 HTTPS 連結：${match.group(1)}';
    }

    match = RegExp(r'^已创建桌面快捷方式：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Created desktop shortcut: ${match.group(1)}'
          : '已建立桌面捷徑：${match.group(1)}';
    }

    match = RegExp(r'^找不到可创建快捷方式的程序：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Could not find an executable for the shortcut: ${match.group(1)}'
          : '找不到可建立捷徑的程式：${match.group(1)}';
    }

    match = RegExp(r'^创建桌面快捷方式失败：(.+)$', dotAll: true).firstMatch(source);
    if (match != null) {
      return english
          ? 'Could not create desktop shortcut: ${match.group(1)}'
          : '建立桌面捷徑失敗：${match.group(1)}';
    }

    match = RegExp(r'^(移动|复制) (\d+) 项到 (.+)$').firstMatch(source);
    if (match != null) {
      final isMove = match.group(1) == '移动';
      final action = english
          ? (isMove ? 'Move' : 'Copy')
          : (isMove ? '移動' : '複製');
      return english
          ? '$action ${match.group(2)} items to ${match.group(3)}'
          : '$action ${match.group(2)} 項到 ${match.group(3)}';
    }

    match = RegExp(r'^(\d+) 个项目将使用 Git 从当前目录(移动|复制)到 (.+)。$')
        .firstMatch(source);
    if (match != null) {
      final isMove = match.group(2) == '移动';
      return english
          ? '${match.group(1)} items will be ${isMove ? 'moved' : 'copied'} '
                'with Git from the current folder to ${match.group(3)}.'
          : '${match.group(1)} 個項目將使用 Git 從目前資料夾'
                '${isMove ? '移動' : '複製'}到 ${match.group(3)}。';
    }

    match = RegExp(r'^已(移动|复制) (\d+) 项$').firstMatch(source);
    if (match != null) {
      final isMove = match.group(1) == '移动';
      final action = english
          ? (isMove ? 'Moved' : 'Copied')
          : (isMove ? '已移動' : '已複製');
      return english
          ? '$action ${match.group(2)} items'
          : '$action ${match.group(2)} 項';
    }

    match = RegExp(r'^重命名 (.+)$').firstMatch(source);
    if (match != null) {
      return english ? 'Rename ${match.group(1)}' : '重新命名 ${match.group(1)}';
    }

    match = RegExp(r'^将 (.+) 的新名称设为 (.+)。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Set the new name of ${match.group(1)} to ${match.group(2)}.'
          : '將 ${match.group(1)} 的新名稱設為 ${match.group(2)}。';
    }

    match = RegExp(r'^已重命名为 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Renamed to ${match.group(1)}'
          : '已重新命名為 ${match.group(1)}';
    }

    match = RegExp(r'^删除 (\d+) 个项目$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Delete ${match.group(1)} items'
          : '刪除 ${match.group(1)} 個項目';
    }

    match = RegExp(r'^将永久删除：(.+)。已跟踪内容使用 git rm，未跟踪或忽略内容使用 git clean。$')
        .firstMatch(source);
    if (match != null) {
      return english
          ? 'Permanently delete: ${match.group(1)}. Tracked items use git rm; '
                'untracked or ignored items use git clean.'
          : '將永久刪除：${match.group(1)}。已追蹤內容使用 git rm，'
                '未追蹤或忽略內容使用 git clean。';
    }

    match = RegExp(r'^已删除 (\d+) 项$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Deleted ${match.group(1)} items'
          : '已刪除 ${match.group(1)} 項';
    }

    match = RegExp(
      r'^项目 (.+)，目标分支 (.+)。将备份并删除原 (\d+) 个分支、(\d+) 个标签，然后只保留一个空提交：“(.+)”。本地文件内容不变，但本地索引会重置为空，刷新后文件显示为未跟踪。受保护分支或服务器不支持原子推送时，整个操作会失败。$',
    ).firstMatch(source);
    if (match != null) {
      return english
          ? 'Project ${match.group(1)}, target branch ${match.group(2)}. '
                'Back up and remove ${match.group(3)} branches and '
                '${match.group(4)} tags, then retain only one empty commit: '
                '"${match.group(5)}". Local files remain, but the index is '
                'reset and files become untracked. Protected branches or '
                'servers without atomic push will reject the operation.'
          : '專案 ${match.group(1)}，目標分支 ${match.group(2)}。'
                '將備份並刪除原 ${match.group(3)} 個分支、'
                '${match.group(4)} 個標籤，然後只保留一個空提交：'
                '「${match.group(5)}」。本機檔案內容不變，但本機索引會重設為空，'
                '重新整理後檔案顯示為未追蹤。受保護分支或伺服器不支援原子推送時，'
                '整個操作會失敗。';
    }

    match = RegExp(r'^推送 (.+)$').firstMatch(source);
    if (match != null) {
      return english ? 'Push ${match.group(1)}' : '推送 ${match.group(1)}';
    }

    match = RegExp(
      r'^将当前分支 (.+) 推送到 upstream；如果没有 upstream，会使用 origin 或首个远端并设置 upstream。$',
    ).firstMatch(source);
    if (match != null) {
      return english
          ? 'Push ${match.group(1)} to upstream. If upstream is not configured, '
                'use origin or the first remote and set upstream.'
          : '將目前分支 ${match.group(1)} 推送到 upstream；如果沒有 upstream，'
                '會使用 origin 或首個遠端並設定 upstream。';
    }

    match = RegExp(r'^已推送 (.+)$').firstMatch(source);
    if (match != null) {
      return english ? 'Pushed ${match.group(1)}' : '已推送 ${match.group(1)}';
    }

    match = RegExp(r'^(添加|更新)远端 (.+)$').firstMatch(source);
    if (match != null) {
      final isUpdate = match.group(1) == '更新';
      return english
          ? '${isUpdate ? 'Update' : 'Add'} remote ${match.group(2)}'
          : '${isUpdate ? '更新' : '新增'}遠端 ${match.group(2)}';
    }

    match = RegExp(r'^(新增远端地址|把远端地址改为) (.+)。$').firstMatch(source);
    if (match != null) {
      final isUpdate = match.group(1) == '把远端地址改为';
      return english
          ? '${isUpdate ? 'Change the remote URL to' : 'Add remote URL'} '
                '${match.group(2)}.'
          : '${isUpdate ? '將遠端網址改為' : '新增遠端網址'} ${match.group(2)}。';
    }

    match = RegExp(r'^远端 (.+) 已(更新|添加|删除)$').firstMatch(source);
    if (match != null) {
      final action = match.group(2)!;
      if (english) {
        final translated = switch (action) {
          '更新' => 'updated',
          '添加' => 'added',
          _ => 'removed',
        };
        return 'Remote ${match.group(1)} $translated';
      }
      final translated = switch (action) {
        '更新' => '已更新',
        '添加' => '已新增',
        _ => '已刪除',
      };
      return '遠端 ${match.group(1)} $translated';
    }

    match = RegExp(r'^删除本地远端配置 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Remove local remote ${match.group(1)}'
          : '刪除本機遠端設定 ${match.group(1)}';
    }

    match = RegExp(r'^推送到远端 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Push to remote ${match.group(1)}'
          : '推送到遠端 ${match.group(1)}';
    }

    match = RegExp(r'^把当前分支 (.+) 推送到 (.+)。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Push the current branch ${match.group(1)} to ${match.group(2)}.'
          : '將目前分支 ${match.group(1)} 推送到 ${match.group(2)}。';
    }

    match = RegExp(r'^已推送到 (.+)$').firstMatch(source);
    if (match != null) {
      return english ? 'Pushed to ${match.group(1)}' : '已推送到 ${match.group(1)}';
    }

    match = RegExp(r'^推送到全部 (\d+) 个远端$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Push to all ${match.group(1)} remotes'
          : '推送到全部 ${match.group(1)} 個遠端';
    }

    match = RegExp(r'^依次推送当前分支到：(.+)。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Push the current branch in order to: ${match.group(1)}.'
          : '依序推送目前分支到：${match.group(1)}。';
    }

    match = RegExp(r'^已推送到全部 (\d+) 个远端$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Pushed to all ${match.group(1)} remotes'
          : '已推送到全部 ${match.group(1)} 個遠端';
    }

    match = RegExp(
      r'^成功 (\d+) 个，失败 (\d+) 个。\n(.+)$',
      dotAll: true,
    ).firstMatch(source);
    if (match != null) {
      return english
          ? '${match.group(1)} succeeded and ${match.group(2)} failed.\n'
                '${match.group(3)}'
          : '成功 ${match.group(1)} 個，失敗 ${match.group(2)} 個。\n'
                '${match.group(3)}';
    }

    match = RegExp(r'^远端 (.+) 当前没有分支或标签。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Remote ${match.group(1)} has no branches or tags.'
          : '遠端 ${match.group(1)} 目前沒有分支或標籤。';
    }

    match = RegExp(r'^远端 (.+) 有 (\d+) 个分支、(\d+) 个标签。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Remote ${match.group(1)} has ${match.group(2)} branches and '
                '${match.group(3)} tags.'
          : '遠端 ${match.group(1)} 有 ${match.group(2)} 個分支、'
                '${match.group(3)} 個標籤。';
    }

    match = RegExp(r'^清空远端历史 (.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Clear remote history ${match.group(1)}'
          : '清除遠端歷史 ${match.group(1)}';
    }

    match = RegExp(r'^已加入执行计划：(.+)。尚未执行任何 Git 变更。$').firstMatch(source);
    if (match != null) {
      final title = tr(match.group(1)!);
      return english
          ? 'Added to the operation plan: $title. No Git changes have run.'
          : '已加入執行計畫：$title。尚未執行任何 Git 變更。';
    }

    match = RegExp(r'^已移除：(.+)$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Removed: ${tr(match.group(1)!)}'
          : '已移除：${tr(match.group(1)!)}';
    }

    match = RegExp(r'^已清空 (\d+) 步待执行操作$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Cleared ${match.group(1)} pending steps'
          : '已清除 ${match.group(1)} 個待執行步驟';
    }

    match = RegExp(r'^提交说明：(.+)。执行时先运行 git add -A，再运行 git commit。$')
        .firstMatch(source);
    if (match != null) {
      return english
          ? 'Commit message: ${match.group(1)}. Run git add -A, then git commit.'
          : '提交說明：${match.group(1)}。執行時先執行 git add -A，'
                '再執行 git commit。';
    }

    match = RegExp(
      r'^已清空远端 (.+) 的历史。(.+) 现指向空提交 ([a-fA-F0-9]+)；本地索引已重置为空，文件已保留并显示为未跟踪。$',
    ).firstMatch(source);
    if (match != null) {
      return english
          ? 'Cleared the history of remote ${match.group(1)}. Branch '
                '${match.group(2)} now points to empty commit '
                '${match.group(3)}; the local index is empty and files remain '
                'as untracked.'
          : '已清除遠端 ${match.group(1)} 的歷史。分支 ${match.group(2)} '
                '目前指向空提交 ${match.group(3)}；本機索引已重設為空，'
                '檔案保留並顯示為未追蹤。';
    }

    match = RegExp(r'^已按顺序执行全部 (\d+) 步操作。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Executed all ${match.group(1)} steps in order.'
          : '已依序執行全部 ${match.group(1)} 步操作。';
    }

    match = RegExp(
      r'^第 (\d+) 步“(.+)”失败：(.+)\n后续步骤尚未执行，失败步骤已保留在计划中。$',
      dotAll: true,
    ).firstMatch(source);
    if (match != null) {
      final title = tr(match.group(2)!);
      final reason = tr(match.group(3)!);
      return english
          ? 'Step ${match.group(1)} "$title" failed: $reason\n'
                'Later steps were not executed; the failed step remains in the plan.'
          : '第 ${match.group(1)} 步「$title」失敗：$reason\n'
                '後續步驟尚未執行，失敗步驟已保留在計畫中。';
    }

    match = RegExp(r'^请准确输入 (.+) 以确认危险操作。$').firstMatch(source);
    if (match != null) {
      return english
          ? 'Enter ${match.group(1)} exactly to confirm the dangerous operation.'
          : '請準確輸入 ${match.group(1)} 以確認危險操作。';
    }

    match = RegExp(r'^执行计划异常：(.+)$', dotAll: true).firstMatch(source);
    if (match != null) {
      return english
          ? 'Operation plan error: ${match.group(1)}'
          : '執行計畫異常：${match.group(1)}';
    }

    return null;
  }

  static const Map<String, Map<String, String>> _runtimeTranslations = {
    'en': {
      '当前操作尚未完成。': 'The current operation has not finished.',
      '已从历史记录移除': 'Removed from history',
      '请先勾选文件或文件夹。': 'Select files or folders first.',
      '剪贴板为空。': 'The file clipboard is empty.',
      '已清空剪贴板。': 'File clipboard cleared.',
      '操作计划正在执行，暂时不能修改。':
          'The operation plan is running and cannot be changed yet.',
      '待执行操作不存在。': 'The pending operation no longer exists.',
      '操作计划正在执行，暂时不能清空。':
          'The operation plan is running and cannot be cleared yet.',
      '当前没有待执行操作。': 'There are no pending operations.',
      '当前没有打开的仓库。': 'No repository is open.',
      '清空远端必须单独执行。请先移除或执行当前计划中的其他步骤。': 'Remote clearing must run alone. Remove or execute the other steps first.',
      '提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。': 'The commit is at the end of the plan. Remove it before adding more file changes.',
      '重命名时请只勾选一个文件或文件夹。': 'Select exactly one file or folder to rename.',
      '名称不能为空。': 'The name cannot be empty.',
      '项目没有配置远端仓库。': 'No remote repository is configured.',
      '暂存全部更改': 'Stage all changes',
      '执行 git add -A，把当前全部更改加入 Git 索引。':
          'Run git add -A to add all current changes to the Git index.',
      '取消暂存全部更改': 'Unstage all changes',
      '把 Git 索引恢复到 HEAD，但保留工作区文件内容。':
          'Restore the Git index to HEAD while keeping workspace files.',
      '请填写提交说明。': 'Enter a commit message.',
      '没有可提交的更改。': 'There are no changes to commit.',
      '执行计划中已经有提交步骤。': 'The operation plan already contains a commit step.',
      '提交全部更改': 'Commit all changes',
      '提交成功': 'Commit successful',
      '已暂存全部更改': 'All changes staged',
      '已取消暂存全部更改': 'All changes unstaged',
      '设置已保存': 'Settings saved',
      '设置已更新': 'Settings updated',
      '远端列表已刷新': 'Remotes refreshed',
      '执行计划为空。': 'The operation plan is empty.',
      '请勾选危险操作确认项后再执行。':
          'Select the dangerous-operation confirmation before executing.',
      '桌面快捷方式': 'Desktop shortcut',
      '在当前用户桌面创建 Git GUI Expand 快捷方式，并通过稳定 Launcher 启动。': 'Create a Git GUI Expand shortcut on the current user desktop and launch through the stable Launcher.',
      '正在创建快捷方式…': 'Creating shortcut…',
      '一键发送到桌面': 'Send shortcut to desktop',
      '选择显示模式和配色方案；界面图标会跟随当前配色方案变化。': 'Choose the display mode and color scheme. Interface icons follow the selected scheme.',
      '显示模式': 'Display mode',
      '配色方案': 'Color scheme',
      '配色方案会应用到按钮、选择状态、边框、图标和强调文字。': 'The color scheme applies to buttons, selected states, borders, icons, and emphasis text.',
      '经典绿': 'Emerald',
      '海洋蓝': 'Ocean',
      '星夜紫': 'Violet',
      '琥珀金': 'Amber',
      '玫瑰红': 'Rose',
      '创建桌面快捷方式目前仅支持 Windows。':
          'Desktop shortcuts are currently supported only on Windows.',
      '创建桌面快捷方式失败。': 'Could not create the desktop shortcut.',
      '打开请求被拒绝：当前有操作正在执行':
          'Open request rejected because another operation is running',
      '刷新仓库视图': 'Refresh repository view',
      '刷新远端': 'Refresh remotes',
      '用户取消文件夹选择': 'User cancelled folder selection',
      '请求打开仓库文件夹选择器': 'Request repository folder picker',
      '打开设置对话框': 'Open settings dialog',
      '打开发布更新与更新日志对话框': 'Open updates and release notes dialog',
      '打开操作日志查看器': 'Open application log viewer',
      '打开使用指南': 'Open user guide',
      '打开远端仓库管理': 'Open remote repository manager',
      '清空剪贴板请求：已经为空': 'Clear clipboard requested; already empty',
      '开始检查 GitHub Release 更新': 'Checking for GitHub Release updates',
      'GitHub 暂无公开 Release': 'No public GitHub Release is available',
      '检查更新失败：无法连接 GitHub': 'Update check failed: cannot connect to GitHub',
      '检查更新失败：HTTP 异常': 'Update check failed: HTTP error',
      'Release 页面未找到 ZIP SHA-256':
          'No ZIP SHA-256 was found on the Release page',
      '取消暂存完成': 'Unstage completed',
      '三语界面、桌面快捷方式与全新解压修复':
          'Trilingual UI, desktop shortcut, and clean-extract repair',
      '设置支持 English、简体中文和繁體中文；跟随系统时只显示操作系统实际语言。': 'Settings supports English, Simplified Chinese, and Traditional Chinese; Follow system shows only the actual operating-system language.',
      'README、使用指南、更新日志和普通/详细日志支持三种语言。': 'README, user guides, update notes, and normal/detailed logs support all three languages.',
      '全新解压包缺少版本标记时，Launcher 可自动恢复有效版本目录并直接启动。': 'When a clean extraction lacks a version marker, the Launcher recovers a valid version directory and starts automatically.',
      '设置关于页新增一键发送桌面快捷方式，优先指向稳定 Launcher。': 'Settings now creates a desktop shortcut in one click, preferring the stable Launcher.',
      '更新成功后只保留当前版本与更新前版本，失败或回滚时不会清理版本目录。': 'Successful updates retain only the current and immediately previous versions; failed or rolled-back updates do not prune.',
      'MIT 许可证、自动清理旧版本与外观配色':
          'MIT license, automatic old-version cleanup, and appearance colors',
      '项目正式采用 MIT License，并在三份 README 中增加项目徽章。': 'The project now uses the MIT License and includes badges in all three READMEs.',
      'Launcher 每次成功启动都会保留当前版本和上一已安装版本，删除其余旧版本。': 'Every successful Launcher startup keeps the current and immediately previous installed version and removes all older versions.',
      '“外观模式”改名为“外观设置”，新增五种可选配色方案。': 'Appearance was renamed to Appearance settings and now offers five color schemes.',
      '按钮、选择状态、边框、图标和强调文字会随配色方案变化。': 'Buttons, selected states, borders, icons, and emphasis text follow the selected color scheme.',
      '只保留最新版、全局配色与 Git 功能清单':
          'Latest-version-only updates, global colors, and Git coverage',
      '每次成功启动后只保留当前版本，删除其他版本和下载的更新包。': 'Every successful startup keeps only the current version and removes other versions and downloaded update packages.',
      '配色方案统一应用到界面表面、图标、状态徽标、按钮和提示。': 'Color schemes now apply consistently to surfaces, icons, status badges, buttons, and messages.',
      '三份 README 增加 Git 功能覆盖表，明确已完成和未完成功能。': 'All three READMEs now include a Git feature matrix showing completed and pending capabilities.',
    },
    'zh_Hant': {
      '当前操作尚未完成。': '目前操作尚未完成。',
      '已从历史记录移除': '已從歷史記錄移除',
      '请先勾选文件或文件夹。': '請先勾選檔案或資料夾。',
      '剪贴板为空。': '剪貼簿為空。',
      '已清空剪贴板。': '已清空剪貼簿。',
      '操作计划正在执行，暂时不能修改。': '操作計畫正在執行，暫時無法修改。',
      '待执行操作不存在。': '待執行操作不存在。',
      '操作计划正在执行，暂时不能清空。': '操作計畫正在執行，暫時無法清除。',
      '当前没有待执行操作。': '目前沒有待執行操作。',
      '当前没有打开的仓库。': '目前沒有開啟的儲存庫。',
      '清空远端必须单独执行。请先移除或执行当前计划中的其他步骤。': '清除遠端必須單獨執行。請先移除或執行目前計畫中的其他步驟。',
      '提交步骤已加入计划末尾。若要继续修改文件，请先移除提交步骤。': '提交步驟已加入計畫末尾。若要繼續修改檔案，請先移除提交步驟。',
      '重命名时请只勾选一个文件或文件夹。': '重新命名時請只勾選一個檔案或資料夾。',
      '名称不能为空。': '名稱不能為空。',
      '项目没有配置远端仓库。': '專案沒有設定遠端儲存庫。',
      '暂存全部更改': '暫存全部變更',
      '执行 git add -A，把当前全部更改加入 Git 索引。': '執行 git add -A，把目前全部變更加入 Git 索引。',
      '取消暂存全部更改': '取消暫存全部變更',
      '把 Git 索引恢复到 HEAD，但保留工作区文件内容。': '把 Git 索引恢復到 HEAD，但保留工作區檔案內容。',
      '请填写提交说明。': '請填寫提交說明。',
      '没有可提交的更改。': '沒有可提交的變更。',
      '执行计划中已经有提交步骤。': '執行計畫中已經有提交步驟。',
      '提交全部更改': '提交全部變更',
      '提交成功': '提交成功',
      '已暂存全部更改': '已暫存全部變更',
      '已取消暂存全部更改': '已取消暫存全部變更',
      '设置已保存': '設定已儲存',
      '设置已更新': '設定已更新',
      '远端列表已刷新': '遠端清單已重新整理',
      '执行计划为空。': '執行計畫為空。',
      '请勾选危险操作确认项后再执行。': '請勾選危險操作確認項後再執行。',
      '桌面快捷方式': '桌面捷徑',
      '在当前用户桌面创建 Git GUI Expand 快捷方式，并通过稳定 Launcher 启动。':
          '在目前使用者桌面建立 Git GUI Expand 捷徑，並透過穩定 Launcher 啟動。',
      '正在创建快捷方式…': '正在建立捷徑…',
      '一键发送到桌面': '一鍵傳送到桌面',
      '选择显示模式和配色方案；界面图标会跟随当前配色方案变化。': '選擇顯示模式和配色方案；介面圖示會跟隨目前配色方案變化。',
      '显示模式': '顯示模式',
      '配色方案': '配色方案',
      '配色方案会应用到按钮、选择状态、边框、图标和强调文字。': '配色方案會套用到按鈕、選取狀態、邊框、圖示和強調文字。',
      '经典绿': '經典綠',
      '海洋蓝': '海洋藍',
      '星夜紫': '星夜紫',
      '琥珀金': '琥珀金',
      '玫瑰红': '玫瑰紅',
      '创建桌面快捷方式目前仅支持 Windows。': '建立桌面捷徑目前僅支援 Windows。',
      '创建桌面快捷方式失败。': '建立桌面捷徑失敗。',
      '打开请求被拒绝：当前有操作正在执行': '開啟要求被拒絕：目前有其他操作正在執行',
      '刷新仓库视图': '重新整理儲存庫檢視',
      '刷新远端': '重新整理遠端',
      '用户取消文件夹选择': '使用者取消資料夾選擇',
      '请求打开仓库文件夹选择器': '要求開啟儲存庫資料夾選擇器',
      '打开设置对话框': '開啟設定對話框',
      '打开发布更新与更新日志对话框': '開啟更新與發布日誌對話框',
      '打开操作日志查看器': '開啟操作日誌檢視器',
      '打开使用指南': '開啟使用指南',
      '打开远端仓库管理': '開啟遠端儲存庫管理',
      '清空剪贴板请求：已经为空': '清除剪貼簿要求：已經為空',
      '开始检查 GitHub Release 更新': '開始檢查 GitHub Release 更新',
      'GitHub 暂无公开 Release': 'GitHub 目前沒有公開 Release',
      '检查更新失败：无法连接 GitHub': '檢查更新失敗：無法連線 GitHub',
      '检查更新失败：HTTP 异常': '檢查更新失敗：HTTP 異常',
      'Release 页面未找到 ZIP SHA-256': 'Release 頁面找不到 ZIP SHA-256',
      '取消暂存完成': '取消暫存完成',
      '三语界面、桌面快捷方式与全新解压修复': '三語介面、桌面捷徑與全新解壓縮修復',
      '设置支持 English、简体中文和繁體中文；跟随系统时只显示操作系统实际语言。':
          '設定支援 English、简体中文 和繁體中文；跟隨系統時只顯示作業系統實際語言。',
      'README、使用指南、更新日志和普通/详细日志支持三种语言。': 'README、使用指南、更新日誌和普通/詳細日誌支援三種語言。',
      '全新解压包缺少版本标记时，Launcher 可自动恢复有效版本目录并直接启动。':
          '全新解壓縮包缺少版本標記時，Launcher 可自動恢復有效版本目錄並直接啟動。',
      '设置关于页新增一键发送桌面快捷方式，优先指向稳定 Launcher。': '設定關於頁新增一鍵傳送桌面捷徑，優先指向穩定 Launcher。',
      '更新成功后只保留当前版本与更新前版本，失败或回滚时不会清理版本目录。':
          '更新成功後只保留目前版本與更新前版本，失敗或回滾時不會清理版本目錄。',
      'MIT 许可证、自动清理旧版本与外观配色': 'MIT 授權、自動清理舊版本與外觀配色',
      '项目正式采用 MIT License，并在三份 README 中增加项目徽章。':
          '專案正式採用 MIT License，並在三份 README 中增加專案徽章。',
      'Launcher 每次成功启动都会保留当前版本和上一已安装版本，删除其余旧版本。':
          'Launcher 每次成功啟動都會保留目前版本和上一個已安裝版本，刪除其餘舊版本。',
      '“外观模式”改名为“外观设置”，新增五种可选配色方案。': '「外觀模式」改名為「外觀設定」，新增五種可選配色方案。',
      '按钮、选择状态、边框、图标和强调文字会随配色方案变化。': '按鈕、選取狀態、邊框、圖示和強調文字會跟隨配色方案變化。',
      '只保留最新版、全局配色与 Git 功能清单': '只保留最新版、全域配色與 Git 功能清單',
      '每次成功启动后只保留当前版本，删除其他版本和下载的更新包。': '每次成功啟動後只保留目前版本，刪除其他版本和下載的更新包。',
      '配色方案统一应用到界面表面、图标、状态徽标、按钮和提示。': '配色方案統一套用到介面表面、圖示、狀態徽章、按鈕和提示。',
      '三份 README 增加 Git 功能覆盖表，明确已完成和未完成功能。':
          '三份 README 增加 Git 功能覆蓋表，明確列出已完成和未完成功能。',
      '可在本窗口中选中并复制文字。完整指南保存在 {path}。': '可在此視窗中選取並複製文字。完整指南保存在 {path}。',
    },
  };

  static Locale resolveLocale(Locale locale) {
    if (locale.languageCode == 'en') return english;
    if (locale.languageCode == 'zh') {
      if (locale.scriptCode == 'Hant' ||
          const {'TW', 'HK', 'MO'}.contains(locale.countryCode)) {
        return traditionalChinese;
      }
      return simplifiedChinese;
    }
    return english;
  }

  static Locale resolveLocaleList(List<Locale>? locales) {
    if (locales != null) {
      for (final locale in locales) {
        if (locale.languageCode == 'en' || locale.languageCode == 'zh') {
          return resolveLocale(locale);
        }
      }
    }
    return english;
  }

  static Locale localeForPreference(AppLanguagePreference preference) {
    return switch (preference) {
      AppLanguagePreference.system => resolveLocale(
        WidgetsBinding.instance.platformDispatcher.locale,
      ),
      AppLanguagePreference.english => english,
      AppLanguagePreference.simplifiedChinese => simplifiedChinese,
      AppLanguagePreference.traditionalChinese => traditionalChinese,
    };
  }

  static String languageOptionLabel(
    AppLanguagePreference preference, {
    Locale? systemLocale,
  }) {
    return switch (preference) {
      AppLanguagePreference.system => _followSystemLabel(
        resolveLocale(
          systemLocale ?? WidgetsBinding.instance.platformDispatcher.locale,
        ),
      ),
      AppLanguagePreference.english => 'English',
      AppLanguagePreference.simplifiedChinese => '简体中文',
      AppLanguagePreference.traditionalChinese => '繁體中文',
    };
  }

  static String languageOptionDescription(
    AppLanguagePreference preference, {
    Locale? systemLocale,
  }) {
    return switch (preference) {
      AppLanguagePreference.system => _followSystemDescription(
        resolveLocale(
          systemLocale ?? WidgetsBinding.instance.platformDispatcher.locale,
        ),
      ),
      AppLanguagePreference.english =>
        'Use English for the application interface.',
      AppLanguagePreference.simplifiedChinese => '使用简体中文显示软件界面。',
      AppLanguagePreference.traditionalChinese => '使用繁體中文顯示軟體介面。',
    };
  }

  static String _followSystemLabel(Locale locale) {
    return switch (locale.languageCode == 'en'
        ? 'en'
        : locale.scriptCode == 'Hant' ||
              const {'TW', 'HK', 'MO'}.contains(locale.countryCode)
        ? 'zh_Hant'
        : 'zh') {
      'en' => 'Follow system',
      'zh_Hant' => '跟隨系統',
      _ => '跟随系统',
    };
  }

  static String _followSystemDescription(Locale locale) {
    return switch (locale.languageCode == 'en'
        ? 'en'
        : locale.scriptCode == 'Hant' ||
              const {'TW', 'HK', 'MO'}.contains(locale.countryCode)
        ? 'zh_Hant'
        : 'zh') {
      'en' => 'Use the language selected in the operating system.',
      'zh_Hant' => '使用作業系統設定的語言。',
      _ => '使用操作系统设置的语言。',
    };
  }

  static void validateTranslations() {
    final sourceKeys = _translations['zh']!.keys.toSet();
    assert(
      _translations['en']!.keys.toSet().containsAll(sourceKeys),
      'English localization is missing keys.',
    );
    assert(
      _translations['zh_Hant']!.keys.toSet().containsAll(sourceKeys),
      'Traditional Chinese localization is missing keys.',
    );
  }

  static String _traditionalize(String source) {
    var result = source;
    const replacements = {
      '数据库': '資料庫',
      '文件夹': '資料夾',
      '文件': '檔案',
      '软件': '軟體',
      '网络': '網路',
      '日志': '日誌',
      '设置': '設定',
      '默认': '預設',
      '系统': '系統',
      '应用': '應用程式',
      '打开': '開啟',
      '关闭': '關閉',
      '删除': '刪除',
      '复制': '複製',
      '仓库': '儲存庫',
      '远端': '遠端',
      '当前': '目前',
      '选择': '選擇',
      '检查': '檢查',
      '发布': '發布',
      '页面': '頁面',
      '说明': '說明',
      '历史记录': '歷史記錄',
      '项目': '專案',
      '本地': '本機',
      '错误': '錯誤',
      '确认': '確認',
      '预览': '預覽',
      '管理': '管理',
      '编辑': '編輯',
      '进行': '進行',
      '创建': '建立',
      '已经': '已經',
      '这里': '這裡',
    };
    for (final entry in replacements.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  static const Map<String, Map<String, String>> _translations = {
    'en': {
      '设置': 'Settings',
      '关闭': 'Close',
      '取消': 'Cancel',
      '保存设置': 'Save settings',
      '删除': 'Delete',
      '重命名': 'Rename',
      '语言': 'Language',
      '字体': 'Font',
      '外观设置': 'Appearance settings',
      '单位设置': 'Units',
      '关于': 'About',
      '设置将在点击保存后应用到整个软件': 'Changes apply after saving.',
      '关于信息不会修改设置': 'About information does not change settings.',
      '语言设置': 'Language',
      '界面语言': 'Interface language',
      '选择软件显示语言。默认跟随操作系统语言。': 'Choose the interface language. By default it follows the operating system.',
      '跟随系统': 'Follow system',
      '语言更改会在保存设置后立即生效。':
          'The language change takes effect immediately after saving.',
      '字体搜索': 'Search fonts',
      '搜索字体名称或用途，例如 Inter、思源、中文':
          'Search font name or purpose, e.g. Inter or Noto',
      '找到 {count} 个选项': '{count} options found',
      '输入名称可快速筛选': 'Type a name to filter',
      '软件内置 UI 字体': 'Bundled UI fonts',
      '系统自带': 'System fonts',
      '系统默认（自动适配）': 'System default (automatic)',
      '跟随当前操作系统，不固定字体族': 'Follow the operating system without a fixed family',
      '系统已安装字体': 'Installed system font',
      '没有匹配的内置字体': 'No bundled font matches',
      '没有匹配的系统字体': 'No system font matches',
      '内置': 'Bundled',
      '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。': 'Bundled fonts come from Google Fonts under the SIL Open Font License.',
      '字体预览': 'Font preview',
      '保存后会应用到菜单、资源面板、对话框和提交说明。': 'The saved font applies to menus, explorers, dialogs and commit notes.',
      '字体大小': 'Font size',
      '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。':
          'Three safe sizes prevent layouts from becoming too small or large.',
      '允许范围：{min}%–{max}%': 'Allowed range: {min}%–{max}%',
      '此页还有下方内容': 'More content below',
      '向下滚动可查看字体预览和字体大小设置。':
          'Scroll down for font preview and font-size settings.',
      '跟随系统会根据设备当前的深色或浅色外观自动切换。':
          'Follow system switches with the device light or dark appearance.',
      '浅色': 'Light',
      '深色': 'Dark',
      '大小单位': 'Size units',
      '二进制（IEC）': 'Binary (IEC)',
      '十进制（SI）': 'Decimal (SI)',
      '基础单位': 'Base unit',
      'Byte（字节，B）': 'Byte (B)',
      'bit（比特，b）': 'bit (b)',
      '单位预览': 'Unit preview',
      '小文件': 'Small file',
      '中文件': 'Medium file',
      '大文件': 'Large file',
      '设置数据目录': 'Settings data directory',
      '版本 v{version}': 'Version v{version}',
      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。':
          'Browse, move, copy, delete, commit and push through the Git CLI.',
      '打开仓库': 'Open repository',
      '致谢': 'Acknowledgements',
      '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。': 'Thanks to DeepSeek AI and ChatGPT Codex for creating and improving this project.',
      '本项目使用 MIT License 开源许可证。':
          'This project is licensed under the MIT License.',
      '打开': 'Open',
      '项目目录': 'Project folder',
      '更新': 'Updates',
      '操作日志': 'Logs',
      '指南': 'Guide',
      'Git 仓库': 'Git repository',
      '无分支': 'No branch',
      '项目大小': 'Project size',
      '文件': 'Files',
      '待提交': 'Pending',
      '剪切': 'Cut',
      '复制': 'Copy',
      '粘贴': 'Paste',
      '粘贴到左侧': 'Paste to left',
      '粘贴到右侧': 'Paste to right',
      '勾选文件后可剪切或复制': 'Select files to cut or copy',
      '已选择 {count} 项': '{count} selected',
      '待执行 {count}': '{count} pending',
      '查看、移除或确认执行所有待处理操作': 'Review, remove or execute pending operations',
      '双击文件夹进入 · 点击面板切换粘贴目标':
          'Double-click a folder; click a pane to choose the paste target',
      '刷新仓库 (Ctrl+R)': 'Refresh repository (Ctrl+R)',
      '待移动 {count} 项': '{count} pending moves',
      '待复制 {count} 项': '{count} pending copies',
      '左侧资源': 'Left explorer',
      '右侧资源': 'Right explorer',
      '粘贴目标': 'Paste target',
      '上一级': 'Parent folder',
      '刷新': 'Refresh',
      '清除选择': 'Clear selection',
      '名称': 'Name',
      '大小': 'Size',
      '状态': 'Status',
      '无法读取目录': 'Unable to read folder',
      '这里没有文件': 'No files here',
      '切换目录或刷新以查看仓库内容。':
          'Open another folder or refresh to view repository contents.',
      '用文件资源打开': 'Show in File Explorer',
      '用默认打开方式打开': 'Open with default app',
      '无法打开文件：{error}': 'Unable to open file: {error}',
      '{count} 项': '{count} items',
      '双击文件夹进入': 'Double-click a folder to open',
      '文件夹': 'Folder',
      '未跟踪': 'Untracked',
      '未知': 'Unknown',
      '提交工作区': 'Commit workspace',
      '{count} 项变更': '{count} changes',
      '{count} 项已暂存': '{count} staged',
      '查看和管理全部远端仓库': 'View and manage all remotes',
      '远端 {count}': 'Remotes {count}',
      '推送当前分支 (Ctrl+Shift+U)': 'Push current branch (Ctrl+Shift+U)',
      '推送': 'Push',
      '文件变更尚未执行，请在待执行操作计划中确认': 'File changes are pending in the operation plan',
      '工作区干净，没有待提交的更改': 'Working tree clean',
      '填写本次提交说明…': 'Enter a commit message…',
      '提交说明': 'Commit message',
      '暂存全部': 'Stage all',
      '取消暂存': 'Unstage',
      '加入提交计划': 'Add commit to plan',
      '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。': 'Commits are deferred. Confirm the plan before git add -A and git commit run.',
      '把 Git 文件操作，\n变成一次直观的移动。':
          'Turn Git file operations\ninto an intuitive workspace.',
      '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。': 'Browse one repository in two panes. Select, cut, paste and rename. Every change runs through Git.',
      '正在读取仓库…': 'Opening repository…',
      '打开 Git 仓库': 'Open Git repository',
      '请选择已经执行过 git init 的文件夹根目录':
          'Choose a folder already initialized with git init',
      '最近打开': 'Recently opened',
      '{count} 个 Git 仓库': '{count} Git repositories',
      '仅保存验证成功的仓库根目录': 'Only verified repository roots are saved',
      '从历史记录移除': 'Remove from history',
      '双栏批量操作': 'Dual-pane operations',
      '独立浏览，跨栏移动': 'Browse independently and move across panes',
      'Git 原生变更': 'Native Git changes',
      '精确大小视图': 'Precise size view',
      'IEC / SI，可切换 bit': 'IEC / SI, optional bits',
      '今天 {time}': 'Today {time}',
      '待执行操作计划': 'Pending operation plan',
      '当前没有待执行步骤': 'No pending steps',
      '共 {count} 步；确认前仓库不会发生任何改变':
          '{count} steps; the repository is unchanged until confirmation',
      '完成': 'Done',
      '确认并逐步执行': 'Confirm and execute',
      '正在执行…': 'Executing…',
      '正在逐步执行': 'Executing step by step',
      '清空计划': 'Clear plan',
      '正在执行第 {step} 步：{title}': 'Step {step}: {title}',
      '危险操作确认': 'Confirm dangerous operations',
      '此计划包含 {count} 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。': 'This plan includes {count} dangerous steps. File deletion cannot be undone here; remote reset keeps only one empty commit.',
      '我已检查上述操作，确认后立即按顺序执行':
          'I reviewed these operations and want to execute them in order',
      '请先勾选“我已检查危险操作”。': 'Select the dangerous-operation confirmation first.',
      '没有待执行操作': 'No pending operations',
      '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。': 'Choose actions in the explorer, commit area or remote manager. They appear here first.',
      '输入项目全称/分支“{confirmation}”以确认':
          'Enter project/branch "{confirmation}" to confirm',
      '执行完成': 'Execution complete',
      '执行未全部完成': 'Execution incomplete',
      '打开设置对话框': 'Open settings',
      '打开使用指南': 'Open user guide',
      '放弃待执行操作计划？': 'Discard the pending operation plan?',
      '返回': 'Back',
      '放弃计划并继续': 'Discard plan and continue',
      '当前没有打开的项目。': 'No project is open.',
      '无法打开项目目录：{error}': 'Unable to open project folder: {error}',
      '仓库视图已刷新': 'Repository view refreshed',
      '将删除 {count} 个项目加入计划': 'Add deletion of {count} items to the plan',
      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。': 'Files are not deleted yet. Confirm the operation plan before git rm or git clean runs.',
      '以及其他 {count} 项': 'and {count} more',
      '加入删除计划': 'Add deletion to plan',
      '将推送 {branch} 加入计划': 'Add push of {branch} to the plan',
      '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。': 'Nothing is pushed yet. The plan will run git push and configure upstream when needed.',
      '加入推送计划': 'Add push to plan',
      '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。': 'This action is added to the plan. git mv runs only after confirmation.',
      '新名称': 'New name',
      '加入执行计划': 'Add to plan',
      'git mv · index · commit': 'git mv · index · commit',
      '查看日志': 'View logs',
      '详细原因已写入操作日志。':
          'The detailed reason has been written to the application log.',
      '准备执行': 'Preparing to execute',
      '当前 v{version}': 'Current v{version}',
      '更新与发布日志': 'Updates and release notes',
      '当前版本亮点': 'Current release highlights',
      '线上发布说明': 'Online release notes',
      '正在自动更新': 'Updating automatically',
      '正在检查更新': 'Checking for updates',
      '更新中': 'Updating',
      '检查中': 'Checking',
      '检查更新': 'Check for updates',
      '发现新版本 v{version}': 'Version v{version} is available',
      '已经是最新版本': 'You are up to date',
      '暂时无法获取线上版本': 'Unable to retrieve the online version',
      '正在安装…': 'Installing…',
      '立即更新并重启': 'Update and restart now',
      '正在准备更新…': 'Preparing update…',
      '打开发布页': 'Open release page',
      '自动更新会从 GitHub 下载 Windows x64 ZIP 并校验 SHA-256，解压到 versions/<版本>。应用退出后由 GitGuiExpandLauncher 切换版本并自动重启；新版本启动失败时会回滚。根目录 userdata 和正在运行的版本不会被覆盖。': 'Automatic updates download the Windows x64 ZIP from GitHub, verify SHA-256 and extract it into versions/<version>. The Launcher switches versions after exit and rolls back if startup fails. userdata is preserved.',
      '软件操作日志': 'Application logs',
      '刷新日志': 'Refresh logs',
      '打开目录': 'Open folder',
      '普通日志': 'Normal log',
      '详细日志': 'Detailed log',
      '还没有普通日志。执行打开仓库、文件操作或提交后会记录关键事件。': 'No normal log yet. Opening a repository and Git actions create key events.',
      '还没有详细日志。详细日志会记录选择、导航和每一条 Git 命令。': 'No detailed log yet. Selection, navigation and every Git command are recorded here.',
      '无法打开日志目录：{error}': 'Unable to open logs folder: {error}',
      'Git GUI Expand 使用指南': 'Git GUI Expand User Guide',
      '重点：所有 Git 修改先进入执行计划，确认后才运行': 'Important: Git changes are planned first and run only after confirmation',
      '关闭使用指南': 'Close user guide',
      '无法读取使用指南：{error}': 'Unable to read user guide: {error}',
      '可在本窗口中选中并复制文字。完整指南保存在 {path}。':
          'Text can be selected and copied here. The full guide is in {path}.',
      '我知道了': 'Got it',
      '默认使用内置的 Noto Sans SC / 思源黑体，也可搜索系统字体或其他内置字体。': 'By default the bundled Noto Sans SC font is used. Search bundled or system fonts.',
      '清除搜索': 'Clear search',
      'Git GUI Expand · 文件提交': 'Git GUI Expand · File commit',
      '剪切、复制、重命名、推送与提交   0123456789':
          'Cut, copy, rename, push and commit   0123456789',
      '当前选择：{theme}': 'Current selection: {theme}',
      '控制项目大小和每个文件大小的显示方式。':
          'Control how project and individual file sizes are displayed.',
      '容量单位制': 'Size unit system',
      '二进制使用 1024 进位，十进制使用 1000 进位。':
          'Binary uses 1024 steps; decimal uses 1000.',
      'IEC 二进制': 'IEC binary',
      'SI 十进制': 'SI decimal',
      'Byte 显示 B、KiB 或 KB；bit 会先乘以 8。':
          'Byte displays B, KiB or KB; bit is multiplied by 8 first.',
      'Byte（B）': 'Byte (B)',
      'bit（b）': 'bit (b)',
      'Windows 优先的 Flutter Git 图形化文件工作区。':
          'A Windows-first Flutter graphical file workspace for Git.',
      '远端仓库': 'Remotes',
      '当前分支：{branch}': 'Current branch: {branch}',
      '无': 'None',
      '全部推送': 'Push all',
      '刷新远端': 'Refresh remotes',
      '尚未配置远端仓库。请在右侧添加 GitHub、Gitee、GitLab 或其他 Git 远端。': 'No remotes configured. Add GitHub, Gitee, GitLab or another Git remote.',
      '添加远端': 'Add remote',
      '编辑远端': 'Edit remote',
      '支持 GitHub、Gitee、GitLab、Bitbucket 和任意标准 Git 远端。所有修改会先加入待执行计划。远端右侧红色垃圾桶用于清空该远端全部分支和标签。': 'Supports GitHub, Gitee, GitLab, Bitbucket and standard Git remotes. Changes are planned first.',
      '远端名称': 'Remote name',
      '例如 origin、gitee、gitlab': 'For example origin, gitee or gitlab',
      '远端 URL': 'Remote URL',
      'https://... 或 git@host:owner/repo.git':
          'https://... or git@host:owner/repo.git',
      '加入添加计划': 'Add to add plan',
      '加入修改计划': 'Add to update plan',
      '取消编辑': 'Cancel editing',
      '编辑 URL': 'Edit URL',
      '移除本地远端配置': 'Remove local remote configuration',
      '清空远端全部分支和标签（危险）': 'Clear all remote branches and tags (dangerous)',
      '正在读取远端 {remote} 的分支和标签…': 'Reading branches and tags from {remote}…',
      '清空远端历史 {remote}？': 'Clear remote history for {remote}?',
      '这是不可撤销的高风险操作。软件会先备份远端引用，然后把 {branch} 强制替换为一个不含文件的空根提交，删除其他分支和标签，并把本地同名分支与索引同步到该空提交。本地文件不会删除，刷新后会显示为未跟踪。': 'This dangerous action cannot be undone. The remote is backed up, {branch} is replaced with an empty root commit, other refs are deleted, and the local branch/index are synchronized without deleting files.',
      '项目：{project}\n目标分支：{branch}\n空提交说明：{message}\n计划执行确认：{confirmation}': 'Project: {project}\nTarget branch: {branch}\nEmpty commit: {message}\nPlan confirmation: {confirmation}',
      '{platform} 的默认分支通常受保护。如果服务器拒绝强制更新或删除，整个原子操作不会删除任何引用；需要先在托管平台临时解除默认分支保护。': '{platform} usually protects the default branch. Remove protection temporarily if force update or deletion is rejected.',
      '远端当前没有分支或标签，将直接创建第一个空提交。': 'The remote has no branches or tags. The first empty commit will be created.',
      '加入清空计划': 'Add clear to plan',
      '将推送到 {remote} 加入计划': 'Add push to {remote} to the plan',
      '现在不会联网推送。执行计划时，将当前分支 {branch} 推送到 {platform}。\n{url}': 'Nothing is pushed yet. The plan pushes {branch} to {platform}.\n{url}',
      '将全部推送加入计划': 'Add push-all to the plan',
      '执行计划时，当前分支 {branch} 将依次推送到：\n{remotes}':
          'The plan pushes {branch} to:\n{remotes}',
      '加入全部推送计划': 'Add push-all plan',
      '将移除远端配置 {remote} 加入计划': 'Add removal of remote {remote} to the plan',
      '执行计划时只删除本地 Git remote 配置，不会删除远端平台上的仓库。':
          'Only the local Git remote configuration is removed.',
      '加入移除计划': 'Add removal to plan',
      '从计划移除': 'Remove from plan',
      '第 {step} 步：{title}': 'Step {step}: {title}',
      '请输入远端项目全称/分支“{confirmation}”进行二次确认。':
          'Enter project/branch "{confirmation}" to confirm again.',
      '当前分支': 'Current branch',
      '打开另一个仓库': 'opening another repository',
      '关闭仓库': 'closing the repository',
      '当前有 {count} 步操作尚未执行。{action}会清除这些计划，仓库不会发生这些变更。': '{count} planned steps have not run. {action} will discard them; no repository changes will occur.',
      '请先勾选要重命名的项目。': 'Select an item to rename.',
      '重命名时只能勾选一个项目。': 'Select exactly one item to rename.',
      '请先勾选要删除的项目。': 'Select items to delete.',
      '已选 {count} 项': '{count} selected',
      'IEC · 1024 进制 · bit': 'IEC · base 1024 · bit',
      'SI · 1000 进制 · bit': 'SI · base 1000 · bit',
      'IEC · 1024 进制 · Byte': 'IEC · base 1024 · Byte',
      'SI · 1000 进制 · Byte': 'SI · base 1000 · Byte',
      '专为数字界面设计的开源无衬线字体，适合工具栏和高密度正文。': 'An open-source sans-serif designed for digital interfaces and dense text.',
      '覆盖简体中文的现代界面字体，中英文混排清晰、字形稳定。': 'A modern UI font for Simplified Chinese with clear mixed-language text.',
      '为产品界面和企业信息设计，数字与英文阅读性突出。': 'Designed for product interfaces and business information with strong numeral readability.',
    },
    'zh': {
      '设置': '设置',
      '关闭': '关闭',
      '取消': '取消',
      '保存设置': '保存设置',
      '删除': '删除',
      '重命名': '重命名',
      '语言': '语言',
      '字体': '字体',
      '外观设置': '外观设置',
      '单位设置': '单位设置',
      '关于': '关于',
      '设置将在点击保存后应用到整个软件': '设置将在点击保存后应用到整个软件',
      '关于信息不会修改设置': '关于信息不会修改设置',
      '语言设置': '语言设置',
      '界面语言': '界面语言',
      '选择软件显示语言。默认跟随操作系统语言。': '选择软件显示语言。默认跟随操作系统语言。',
      '跟随系统': '跟随系统',
      '语言更改会在保存设置后立即生效。': '语言更改会在保存设置后立即生效。',
      '字体搜索': '字体搜索',
      '搜索字体名称或用途，例如 Inter、思源、中文': '搜索字体名称或用途，例如 Inter、思源、中文',
      '找到 {count} 个选项': '找到 {count} 个选项',
      '输入名称可快速筛选': '输入名称可快速筛选',
      '软件内置 UI 字体': '软件内置 UI 字体',
      '系统自带': '系统自带',
      '系统默认（自动适配）': '系统默认（自动适配）',
      '跟随当前操作系统，不固定字体族': '跟随当前操作系统，不固定字体族',
      '系统已安装字体': '系统已安装字体',
      '没有匹配的内置字体': '没有匹配的内置字体',
      '没有匹配的系统字体': '没有匹配的系统字体',
      '内置': '内置',
      '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。':
          '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。',
      '字体预览': '字体预览',
      '保存后会应用到菜单、资源面板、对话框和提交说明。': '保存后会应用到菜单、资源面板、对话框和提交说明。',
      '字体大小': '字体大小',
      '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。': '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。',
      '允许范围：{min}%–{max}%': '允许范围：{min}%–{max}%',
      '此页还有下方内容': '此页还有下方内容',
      '向下滚动可查看字体预览和字体大小设置。': '向下滚动可查看字体预览和字体大小设置。',
      '跟随系统会根据设备当前的深色或浅色外观自动切换。': '跟随系统会根据设备当前的深色或浅色外观自动切换。',
      '浅色': '浅色',
      '深色': '深色',
      '大小单位': '大小单位',
      '二进制（IEC）': '二进制（IEC）',
      '十进制（SI）': '十进制（SI）',
      '基础单位': '基础单位',
      'Byte（字节，B）': 'Byte（字节，B）',
      'bit（比特，b）': 'bit（比特，b）',
      '单位预览': '单位预览',
      '小文件': '小文件',
      '中文件': '中文件',
      '大文件': '大文件',
      '设置数据目录': '设置数据目录',
      '版本 v{version}': '版本 v{version}',
      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。': '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。',
      '打开仓库': '打开仓库',
      '致谢': '致谢',
      '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。':
          '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。',
      '本项目使用 MIT License 开源许可证。': '本项目使用 MIT License 开源许可证。',
      '打开': '打开',
      '项目目录': '项目目录',
      '更新': '更新',
      '操作日志': '操作日志',
      '指南': '指南',
      'Git 仓库': 'Git 仓库',
      '无分支': '无分支',
      '项目大小': '项目大小',
      '文件': '文件',
      '待提交': '待提交',
      '剪切': '剪切',
      '复制': '复制',
      '粘贴': '粘贴',
      '粘贴到左侧': '粘贴到左侧',
      '粘贴到右侧': '粘贴到右侧',
      '勾选文件后可剪切或复制': '勾选文件后可剪切或复制',
      '已选择 {count} 项': '已选择 {count} 项',
      '待执行 {count}': '待执行 {count}',
      '查看、移除或确认执行所有待处理操作': '查看、移除或确认执行所有待处理操作',
      '双击文件夹进入 · 点击面板切换粘贴目标': '双击文件夹进入 · 点击面板切换粘贴目标',
      '刷新仓库 (Ctrl+R)': '刷新仓库 (Ctrl+R)',
      '待移动 {count} 项': '待移动 {count} 项',
      '待复制 {count} 项': '待复制 {count} 项',
      '左侧资源': '左侧资源',
      '右侧资源': '右侧资源',
      '粘贴目标': '粘贴目标',
      '上一级': '上一级',
      '刷新': '刷新',
      '清除选择': '清除选择',
      '名称': '名称',
      '大小': '大小',
      '状态': '状态',
      '无法读取目录': '无法读取目录',
      '这里没有文件': '这里没有文件',
      '切换目录或刷新以查看仓库内容。': '切换目录或刷新以查看仓库内容。',
      '用文件资源打开': '用文件资源打开',
      '用默认打开方式打开': '用默认打开方式打开',
      '无法打开文件：{error}': '无法打开文件：{error}',
      '{count} 项': '{count} 项',
      '双击文件夹进入': '双击文件夹进入',
      '文件夹': '文件夹',
      '未跟踪': '未跟踪',
      '未知': '未知',
      '提交工作区': '提交工作区',
      '{count} 项变更': '{count} 项变更',
      '{count} 项已暂存': '{count} 项已暂存',
      '查看和管理全部远端仓库': '查看和管理全部远端仓库',
      '远端 {count}': '远端 {count}',
      '推送当前分支 (Ctrl+Shift+U)': '推送当前分支 (Ctrl+Shift+U)',
      '推送': '推送',
      '文件变更尚未执行，请在待执行操作计划中确认': '文件变更尚未执行，请在待执行操作计划中确认',
      '工作区干净，没有待提交的更改': '工作区干净，没有待提交的更改',
      '填写本次提交说明…': '填写本次提交说明…',
      '提交说明': '提交说明',
      '暂存全部': '暂存全部',
      '取消暂存': '取消暂存',
      '加入提交计划': '加入提交计划',
      '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。':
          '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。',
      '把 Git 文件操作，\n变成一次直观的移动。': '把 Git 文件操作，\n变成一次直观的移动。',
      '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。':
          '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。',
      '正在读取仓库…': '正在读取仓库…',
      '打开 Git 仓库': '打开 Git 仓库',
      '请选择已经执行过 git init 的文件夹根目录': '请选择已经执行过 git init 的文件夹根目录',
      '最近打开': '最近打开',
      '{count} 个 Git 仓库': '{count} 个 Git 仓库',
      '仅保存验证成功的仓库根目录': '仅保存验证成功的仓库根目录',
      '从历史记录移除': '从历史记录移除',
      '双栏批量操作': '双栏批量操作',
      '独立浏览，跨栏移动': '独立浏览，跨栏移动',
      'Git 原生变更': 'Git 原生变更',
      '精确大小视图': '精确大小视图',
      'IEC / SI，可切换 bit': 'IEC / SI，可切换 bit',
      '今天 {time}': '今天 {time}',
      '待执行操作计划': '待执行操作计划',
      '当前没有待执行步骤': '当前没有待执行步骤',
      '共 {count} 步；确认前仓库不会发生任何改变': '共 {count} 步；确认前仓库不会发生任何改变',
      '完成': '完成',
      '确认并逐步执行': '确认并逐步执行',
      '正在执行…': '正在执行…',
      '正在逐步执行': '正在逐步执行',
      '清空计划': '清空计划',
      '正在执行第 {step} 步：{title}': '正在执行第 {step} 步：{title}',
      '危险操作确认': '危险操作确认',
      '此计划包含 {count} 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。':
          '此计划包含 {count} 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。',
      '我已检查上述操作，确认后立即按顺序执行': '我已检查上述操作，确认后立即按顺序执行',
      '请先勾选“我已检查危险操作”。': '请先勾选“我已检查危险操作”。',
      '没有待执行操作': '没有待执行操作',
      '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。': '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。',
      '输入项目全称/分支“{confirmation}”以确认': '输入项目全称/分支“{confirmation}”以确认',
      '执行完成': '执行完成',
      '执行未全部完成': '执行未全部完成',
      '打开设置对话框': '打开设置对话框',
      '打开使用指南': '打开使用指南',
      '放弃待执行操作计划？': '放弃待执行操作计划？',
      '放弃计划并继续': '放弃计划并继续',
      '当前没有打开的项目。': '当前没有打开的项目。',
      '无法打开项目目录：{error}': '无法打开项目目录：{error}',
      '仓库视图已刷新': '仓库视图已刷新',
      '将删除 {count} 个项目加入计划': '将删除 {count} 个项目加入计划',
      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。':
          '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。',
      '以及其他 {count} 项': '以及其他 {count} 项',
      '加入删除计划': '加入删除计划',
      '将推送 {branch} 加入计划': '将推送 {branch} 加入计划',
      '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。': '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。',
      '加入推送计划': '加入推送计划',
      '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。':
          '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。',
      '新名称': '新名称',
      '加入执行计划': '加入执行计划',
    },
    'zh_Hant': {
      '设置': '設定',
      '关闭': '關閉',
      '取消': '取消',
      '保存设置': '儲存設定',
      '返回': '返回',
      '删除': '刪除',
      '重命名': '重新命名',
      '语言': '語言',
      '字体': '字型',
      '外观设置': '外觀設定',
      '单位设置': '單位設定',
      '关于': '關於',
      '设置将在点击保存后应用到整个软件': '設定將在點擊儲存後套用到整個軟體',
      '关于信息不会修改设置': '關於資訊不會修改設定',
      '语言设置': '語言設定',
      '界面语言': '介面語言',
      '选择软件显示语言。默认跟随操作系统语言。': '選擇軟體顯示語言。預設跟隨作業系統語言。',
      '跟随系统': '跟隨系統',
      '语言更改会在保存设置后立即生效。': '語言變更會在儲存設定後立即生效。',
      '字体搜索': '字型搜尋',
      '搜索字体名称或用途，例如 Inter、思源、中文': '搜尋字型名稱或用途，例如 Inter、思源、中文',
      '找到 {count} 个选项': '找到 {count} 個選項',
      '输入名称可快速筛选': '輸入名稱可快速篩選',
      '软件内置 UI 字体': '軟體內建 UI 字型',
      '系统自带': '系統內建',
      '系统默认（自动适配）': '系統預設（自動適配）',
      '跟随当前操作系统，不固定字体族': '跟隨目前作業系統，不固定字型家族',
      '系统已安装字体': '系統已安裝字型',
      '没有匹配的内置字体': '沒有符合的內建字型',
      '没有匹配的系统字体': '沒有符合的系統字型',
      '内置': '內建',
      '内置字体均来自 Google Fonts，使用 SIL Open Font License 并随程序分发。':
          '內建字型來自 Google Fonts，使用 SIL Open Font License 並隨程式散布。',
      '字体预览': '字型預覽',
      '保存后会应用到菜单、资源面板、对话框和提交说明。': '儲存後會套用到選單、資源面板、對話框和提交說明。',
      '字体大小': '字型大小',
      '仅在安全范围内提供三档，避免出现过小或过大字号导致界面布局异常。': '僅在安全範圍內提供三檔，避免字級過小或過大造成版面異常。',
      '允许范围：{min}%–{max}%': '允許範圍：{min}%–{max}%',
      '此页还有下方内容': '此頁還有下方內容',
      '向下滚动可查看字体预览和字体大小设置。': '向下捲動可查看字型預覽和字型大小設定。',
      '跟随系统会根据设备当前的深色或浅色外观自动切换。': '跟隨系統會依裝置目前的深色或淺色外觀自動切換。',
      '浅色': '淺色',
      '深色': '深色',
      '大小单位': '大小單位',
      '二进制（IEC）': '二進位（IEC）',
      '十进制（SI）': '十進位（SI）',
      '基础单位': '基礎單位',
      'Byte（字节，B）': 'Byte（位元組，B）',
      'bit（比特，b）': 'bit（位元，b）',
      '单位预览': '單位預覽',
      '小文件': '小檔案',
      '中文件': '中檔案',
      '大文件': '大檔案',
      '设置数据目录': '設定資料目錄',
      '版本 v{version}': '版本 v{version}',
      '通过 Git CLI 完成双栏浏览、移动、复制、删除、提交与推送。': '透過 Git CLI 完成雙欄瀏覽、移動、複製、刪除、提交與推送。',
      '打开仓库': '開啟儲存庫',
      '致谢': '致謝',
      '感谢 DeepSeek 人工智能和 ChatGPT Codex，两者合力创建、编写、修改此项目。':
          '感謝 DeepSeek 人工智慧和 ChatGPT Codex，兩者合力建立、編寫、修改此專案。',
      '本项目使用 MIT License 开源许可证。': '本專案使用 MIT License 開源授權條款。',
      '打开': '開啟',
      '项目目录': '專案目錄',
      '更新': '更新',
      '操作日志': '操作日誌',
      '指南': '指南',
      'Git 仓库': 'Git 儲存庫',
      '无分支': '無分支',
      '项目大小': '專案大小',
      '文件': '檔案',
      '待提交': '待提交',
      '剪切': '剪下',
      '复制': '複製',
      '粘贴': '貼上',
      '粘贴到左侧': '貼上到左側',
      '粘贴到右侧': '貼上到右側',
      '勾选文件后可剪切或复制': '勾選檔案後可剪下或複製',
      '已选择 {count} 项': '已選擇 {count} 項',
      '待执行 {count}': '待執行 {count}',
      '查看、移除或确认执行所有待处理操作': '查看、移除或確認執行所有待處理操作',
      '双击文件夹进入 · 点击面板切换粘贴目标': '雙擊資料夾進入 · 點擊面板切換貼上目標',
      '刷新仓库 (Ctrl+R)': '重新整理儲存庫 (Ctrl+R)',
      '待移动 {count} 项': '待移動 {count} 項',
      '待复制 {count} 项': '待複製 {count} 項',
      '左侧资源': '左側資源',
      '右侧资源': '右側資源',
      '粘贴目标': '貼上目標',
      '上一级': '上一層',
      '刷新': '重新整理',
      '清除选择': '清除選取',
      '名称': '名稱',
      '大小': '大小',
      '状态': '狀態',
      '无法读取目录': '無法讀取目錄',
      '这里没有文件': '這裡沒有檔案',
      '切换目录或刷新以查看仓库内容。': '切換目錄或重新整理以查看儲存庫內容。',
      '用文件资源打开': '在檔案總管中顯示',
      '用默认打开方式打开': '使用預設應用程式開啟',
      '无法打开文件：{error}': '無法開啟檔案：{error}',
      '{count} 项': '{count} 項',
      '双击文件夹进入': '雙擊資料夾進入',
      '文件夹': '資料夾',
      '未跟踪': '未追蹤',
      '未知': '未知',
      '提交工作区': '提交工作區',
      '{count} 项变更': '{count} 項變更',
      '{count} 项已暂存': '{count} 項已暫存',
      '查看和管理全部远端仓库': '查看和管理全部遠端儲存庫',
      '远端 {count}': '遠端 {count}',
      '推送当前分支 (Ctrl+Shift+U)': '推送目前分支 (Ctrl+Shift+U)',
      '推送': '推送',
      '文件变更尚未执行，请在待执行操作计划中确认': '檔案變更尚未執行，請在待執行操作計畫中確認',
      '工作区干净，没有待提交的更改': '工作區乾淨，沒有待提交的變更',
      '填写本次提交说明…': '填寫本次提交說明…',
      '提交说明': '提交說明',
      '暂存全部': '暫存全部',
      '取消暂存': '取消暫存',
      '加入提交计划': '加入提交計畫',
      '提交不会立即执行。请在待执行操作计划中确认后，再运行 git add -A 和 git commit。':
          '提交不會立即執行。請在待執行操作計畫中確認後，再執行 git add -A 和 git commit。',
      '把 Git 文件操作，\n变成一次直观的移动。': '把 Git 檔案操作，\n變成一次直覺的移動。',
      '左右双栏浏览同一仓库，勾选、剪切、粘贴和重命名。\n每一步文件变更都通过 Git，最后填写说明直接提交。':
          '左右雙欄瀏覽同一儲存庫，勾選、剪下、貼上和重新命名。\n每一步檔案變更都透過 Git，最後填寫說明直接提交。',
      '正在读取仓库…': '正在讀取儲存庫…',
      '打开 Git 仓库': '開啟 Git 儲存庫',
      '请选择已经执行过 git init 的文件夹根目录': '請選擇已經執行過 git init 的資料夾根目錄',
      '最近打开': '最近開啟',
      '{count} 个 Git 仓库': '{count} 個 Git 儲存庫',
      '仅保存验证成功的仓库根目录': '僅儲存驗證成功的儲存庫根目錄',
      '从历史记录移除': '從歷史記錄移除',
      '双栏批量操作': '雙欄批次操作',
      '独立浏览，跨栏移动': '獨立瀏覽，跨欄移動',
      'Git 原生变更': 'Git 原生變更',
      '精确大小视图': '精確大小檢視',
      'IEC / SI，可切换 bit': 'IEC / SI，可切換 bit',
      '今天 {time}': '今天 {time}',
      '待执行操作计划': '待執行操作計畫',
      '当前没有待执行步骤': '目前沒有待執行步驟',
      '共 {count} 步；确认前仓库不会发生任何改变': '共 {count} 步；確認前儲存庫不會發生任何改變',
      '完成': '完成',
      '确认并逐步执行': '確認並逐步執行',
      '正在执行…': '正在執行…',
      '正在逐步执行': '正在逐步執行',
      '清空计划': '清空計畫',
      '正在执行第 {step} 步：{title}': '正在執行第 {step} 步：{title}',
      '危险操作确认': '危險操作確認',
      '此计划包含 {count} 个危险步骤。文件删除无法通过本软件撤销；清空远端会替换全部分支历史，只保留一个空提交并删除其它分支和标签。':
          '此計畫包含 {count} 個危險步驟。檔案刪除無法透過本軟體復原；清空遠端會取代全部分支歷史，只保留一個空提交並刪除其它分支和標籤。',
      '我已检查上述操作，确认后立即按顺序执行': '我已檢查上述操作，確認後立即依序執行',
      '请先勾选“我已检查危险操作”。': '請先勾選「我已檢查危險操作」。',
      '没有待执行操作': '沒有待執行操作',
      '先在文件区、提交区或远端管理中选择操作；所有操作会先进入这里。': '先在檔案區、提交區或遠端管理中選擇操作；所有操作會先進入這裡。',
      '输入项目全称/分支“{confirmation}”以确认': '輸入專案全稱/分支「{confirmation}」以確認',
      '执行完成': '執行完成',
      '执行未全部完成': '執行未全部完成',
      '打开设置对话框': '開啟設定對話框',
      '打开使用指南': '開啟使用指南',
      '放弃待执行操作计划？': '放棄待執行操作計畫？',
      '放弃计划并继续': '放棄計畫並繼續',
      '当前没有打开的项目。': '目前沒有開啟的專案。',
      '无法打开项目目录：{error}': '無法開啟專案目錄：{error}',
      '仓库视图已刷新': '儲存庫檢視已重新整理',
      '将删除 {count} 个项目加入计划': '將刪除 {count} 個項目加入計畫',
      '现在不会删除文件。此步骤加入计划后，必须在“待执行操作计划”中再次确认，才会使用 git rm 或 git clean 执行。':
          '現在不會刪除檔案。此步驟加入計畫後，必須在「待執行操作計畫」中再次確認，才會使用 git rm 或 git clean 執行。',
      '以及其他 {count} 项': '以及其他 {count} 項',
      '加入删除计划': '加入刪除計畫',
      '将推送 {branch} 加入计划': '將推送 {branch} 加入計畫',
      '现在不会联网推送。执行计划时，已配置 upstream 会运行 git push；否则优先使用 origin 并设置当前分支的 upstream。': '現在不會連線推送。執行計畫時，已設定 upstream 會執行 git push；否則優先使用 origin 並設定目前分支的 upstream。',
      '加入推送计划': '加入推送計畫',
      '此操作只会加入待执行计划。确认并执行计划后，软件才会运行 git mv。':
          '此操作只會加入待執行計畫。確認並執行計畫後，軟體才會執行 git mv。',
      '新名称': '新名稱',
      '加入执行计划': '加入執行計畫',
    },
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale.languageCode == 'en' || locale.languageCode == 'zh';
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
