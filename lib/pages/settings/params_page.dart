import 'package:flutter/material.dart';

import '../../components/dialog.dart';
import '../../components/settings/item_title.dart';
import '../../utils/app_theme.dart';
import '../../utils/request_identity.dart';
import '../../utils/storage_util.dart';
import '../../utils/utils.dart';

class ParamsPage extends StatefulWidget {
  const ParamsPage({super.key});

  @override
  State<ParamsPage> createState() => _ParamsPageState();
}

class _ParamsPageState extends State<ParamsPage> {
  void _reload() {
    setState(() {});
  }

  Future<void> _pickIdentity() async {
    final RequestIdentity? selected = await showDialog<RequestIdentity>(
      context: context,
      builder: (context) {
        final RequestIdentity current = GStorage.requestIdentity;
        return SimpleDialog(
          title: const Text('请求身份'),
          children: RequestIdentity.values.map((identity) {
            final bool isSelected = identity == current;
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, identity),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Text(identity.label),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
    if (selected == null) {
      return;
    }
    GStorage.setRequestIdentity(selected);
    if (mounted) {
      _reload();
    }
  }

  Future<void> _regenerate() async {
    await GStorage.regenerateCurrentRequestParams();
    if (mounted) {
      _reload();
    }
  }

  void _save(RequestProfile profile, RequestIdentity identity) {
    GStorage.saveRequestProfile(identity, profile);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.gradientAppBar(
        context: context,
        title: const Text('参数'),
        leading: const BackButton(),
      ),
      body: _buildList(),
    );
  }

  Widget _buildList() {
    final RequestIdentity identity = GStorage.requestIdentity;
    final RequestProfile profile = GStorage.currentRequestProfile;
    final List<Widget> items = <Widget>[
      ListTile(
        title: const Text('请求身份'),
        subtitle: Text(identity.label),
        trailing: const Icon(Icons.chevron_right),
        onTap: _pickIdentity,
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Text(
          '切换后新请求立即生效（无需重启）',
          style: TextStyle(fontSize: 12),
        ),
      ),
      ItemTitle(title: '${identity.label} 参数'),
      if (profile.isIos)
        ..._buildIosItems(profile, identity)
      else
        ..._buildAndroidItems(profile, identity),
      ListTile(
        title: const Text('用户代理'),
        subtitle: Text(profile.userAgent),
        onTap: () => Utils.copyText(profile.userAgent),
      ),
      ListTile(
        title: const Text('X-App设备'),
        subtitle: Text(profile.appDevice),
        onTap: () => Utils.copyText(profile.appDevice),
      ),
      ListTile(
        title: Text(
          identity == RequestIdentity.device ? '重新获取真实设备参数' : '生成随机参数',
        ),
        onTap: _regenerate,
      ),
    ];

    final brightness = Theme.of(context).brightness;
    final cardDeco = AppTheme.cardDecoration(brightness);
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, index) =>
          Container(decoration: cardDeco, child: items[index]),
    );
  }

  List<Widget> _buildAndroidItems(
    RequestProfile profile,
    RequestIdentity identity,
  ) {
    final AndroidParams params = profile.android!;
    return [
      _ParamEdittextItem(
        title: '版本号',
        value: params.versionName,
        onChanged: (value) {
          params.versionName = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: 'Api版本',
        value: params.apiVersion,
        onChanged: (value) {
          params.apiVersion = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '版本代码',
        value: params.versionCode,
        onChanged: (value) {
          params.versionCode = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '制作商',
        value: params.manufacturer,
        onChanged: (value) {
          params.manufacturer = value;
          params.rebuildAppDevice();
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '品牌',
        value: params.brand,
        onChanged: (value) {
          params.brand = value;
          params.rebuildAppDevice();
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '机型',
        value: params.model,
        onChanged: (value) {
          params.model = value;
          params.rebuildAppDevice();
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '构建号',
        value: params.buildNumber,
        onChanged: (value) {
          params.buildNumber = value;
          params.rebuildAppDevice();
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: 'SDK版本',
        value: params.sdkInt,
        onChanged: (value) {
          params.sdkInt = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '安卓版本',
        value: params.androidVersion,
        onChanged: (value) {
          params.androidVersion = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '数字联盟ID',
        value: params.szlmId,
        onChanged: (value) {
          params.szlmId = value;
          params.rebuildAppDevice();
          _save(profile, identity);
        },
      ),
    ];
  }

  List<Widget> _buildIosItems(
    RequestProfile profile,
    RequestIdentity identity,
  ) {
    final IosParams params = profile.ios!;
    return [
      _ParamEdittextItem(
        title: '设备ID',
        value: params.id,
        onChanged: (value) {
          params.id = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '机型',
        value: params.model,
        onChanged: (value) {
          params.model = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '硬件ID',
        value: params.hardwareId,
        onChanged: (value) {
          params.hardwareId = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '销售型号',
        value: params.salesModel,
        onChanged: (value) {
          params.salesModel = value;
          _save(profile, identity);
        },
      ),
      _ParamEdittextItem(
        title: '系统版本',
        value: params.systemVersion,
        onChanged: (value) {
          params.systemVersion = value;
          _save(profile, identity);
        },
      ),
    ];
  }
}

class _ParamEdittextItem extends StatelessWidget {
  const _ParamEdittextItem({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: value.isNotEmpty ? Text(value) : null,
      onTap: () => showDialog<void>(
        context: context,
        builder: (context) {
          return EditTextDialog(
            title: title,
            defaultText: value,
            setData: onChanged,
          );
        },
      ),
    );
  }
}
