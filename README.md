# fuelConsumption

fuelConsumption 是一个离线优先的 Flutter 能耗记录应用，用于管理多辆车的加油、充电和插混补能记录。应用当前以 Android 验证为主，数据保存在本机 SQLite 数据库中，并支持 JSON 手动导入导出备份。

## 当前功能

- 车辆档案：支持燃油车、电车、插混和摩托车。
- 补能记录：支持加油、充电、油电混合记录。
- 统计概览：展示平均能耗、最近能耗、总费用、每公里成本和累计里程。
- 趋势展示：通过图表展示费用趋势。
- 本地存储：使用 Drift + SQLite 保存车辆、补能记录和维修记录。
- 手动备份：支持 JSON 导出和粘贴 JSON 导入。
- 维修记录：可从新增入口记录保养、维修等非能源费用。
- 燃油优惠：加油表单支持优惠金额和实付金额。

## 技术栈

- Flutter / Dart
- Material 3
- flutter_riverpod
- drift / sqlite3_flutter_libs
- fl_chart
- build_runner / drift_dev

## 代码结构

```text
lib/
├─ main.dart                  # 应用入口和真实 repository 组装
└─ src/
   ├─ app.dart                # 根 UI、仪表盘编排、补能类型选择、导入导出入口
   ├─ widgets/                # 已拆出的弹窗、补能表单、车辆表单、最近记录、统计卡片等组件
   ├─ domain/
   │  ├─ models.dart          # 车辆、补能记录、备份等领域模型
   │  ├─ statistics.dart      # 能耗和费用统计
   │  └─ validation.dart      # 补能记录校验
   └─ data/
      ├─ app_repository.dart  # 数据访问抽象
      ├─ fuel_repository.dart # repository 实现和导入校验
      ├─ app_database.dart    # Drift 表和数据库操作
      ├─ app_database.g.dart  # Drift 生成代码
      └─ backup_codec.dart    # JSON 备份编码/解码
```

更完整的架构说明见 [docs/架构.md](docs/架构.md)。

## 本地运行

先安装依赖：

```powershell
flutter pub get
```

运行到已连接的 Android 设备或模拟器：

```powershell
flutter run
```

构建 debug APK：

```powershell
flutter build apk --debug
```

## 验证

Windows 本地测试建议串行执行，避免 native asset 文件复制冲突：

```powershell
flutter analyze
flutter test --concurrency 1
```

当前测试覆盖：

- 领域统计：燃油、电车和少量记录场景。
- 记录校验：负数输入、里程顺序、维修费用。
- 备份编码：JSON 往返、旧备份兼容和 schema version 拒绝。
- Repository：燃油折扣字段和维修记录的导出/导入 round-trip。
- 数据库迁移：v1 SQLite 文件升级到 v2 后保留旧补能记录并创建维修记录表。
- Widget smoke：空状态、新增第一辆车、车辆表单组件、补能表单组件、维修表单组件、备份弹窗、最近记录、燃油优惠、JSON 导出和 JSON 导入流程。

## CI

GitHub Actions 使用 Flutter stable `3.41.8`，与当前项目创建版本保持一致。CI 覆盖最小质量门禁：

```powershell
flutter pub get
flutter analyze
flutter test --concurrency 1
```

CI 不执行 release 构建和应用签名；当前不需要配置 GitHub Secrets。

## 数据和备份

运行数据保存在应用文档目录下的 `fuel_consumption.sqlite`。数据库 schema version 当前为 `2`，包含车辆表、补能记录表和维修记录表。JSON 备份格式由 `BackupCodec` 维护，当前 schema version 为 `1`，并兼容不含 `maintenanceRecords` 的旧备份。

导入备份时会校验：

- 记录引用的车辆必须存在。
- 维修记录引用的车辆必须存在。
- 同一车辆记录的里程需要按日期递增。
- 能源数量、金额和单价不能为负数。
- 维修里程和维修费用不能为负数。

## 后续计划

- 扩充测试：补充充电/插混补能表单、多车型切换和统计边界流程。
- 继续拆分 `lib/src/app.dart` 中的页面编排和补能类型选择逻辑。
- 产品化 Android identity：正式 applicationId、应用名、图标、release 签名。
