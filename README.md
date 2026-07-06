# fuelConsumption

fuelConsumption 是一个离线优先的 Flutter 能耗记录应用，用于管理多辆车的加油、充电和插混补能记录。应用当前以 Android 验证为主，数据保存在本机 SQLite 数据库中，并支持 JSON 手动导入导出备份。

## 当前功能

- 车辆档案：支持燃油车、电车、插混和摩托车。
- 补能记录：支持加油、充电、油电混合记录。
- 统计概览：展示平均能耗、最近能耗、总费用、每公里成本和累计里程。
- 费用页：汇总加油、保养和年度费用，并展示明细。
- 趋势展示：通过图表展示能耗和费用趋势。
- 我的中心：管理车辆、本地备份导入导出、使用帮助和隐私说明。
- 本地存储：使用 Drift + SQLite 保存车辆、补能记录和保养记录。
- 手动备份：支持 JSON 导出和粘贴 JSON 导入。
- 保养记录：可从新增入口记录保养、维修等非能源费用。
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
   ├─ app.dart                # 根 UI、主题和 ProviderScope
   ├─ application/            # Dashboard 查询、导入备份、车辆创建等应用编排服务
   ├─ screens/                # 页面编排和表单控制器
   ├─ widgets/                # 底部导航、首页/费用/我的/加油组件、创建弹层和弹窗
   ├─ domain/
   │  ├─ models.dart          # 车辆、补能记录、备份等领域模型
   │  ├─ statistics.dart      # 能耗统计快照
   │  ├─ consumption_statistics.dart
   │  ├─ expense_statistics.dart
   │  ├─ fuel_grades.dart
   │  ├─ record_amounts.dart
   │  ├─ refuel_amount_calculator.dart
   │  ├─ refuel_record_assembler.dart
   │  └─ validation.dart      # 补能记录校验
   └─ data/
      ├─ app_repository.dart  # 数据访问抽象
      ├─ repository_provider.dart # Riverpod repository 生命周期管理
      ├─ fuel_repository.dart # repository 实现
      ├─ app_database.dart    # Drift 数据库 API
      ├─ app_database_*       # 连接、表定义、迁移、DAO 和 row/domain 映射
      ├─ app_database.g.dart  # Drift 生成代码
      ├─ backup_codec.dart    # JSON 备份编码/解码
      ├─ backup_schema.dart   # 备份格式版本
      └─ backup_validator.dart # 备份语义校验
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
- 费用统计：能源费用、保养费用、年度费用和费用明细聚合。
- 记录校验：能源数量、里程顺序、保养费用、仓储保存和备份语义校验。
- 备份编码：可读错误提示、必填字段校验、round-trip、旧备份兼容和导入 action。
- Dashboard 数据流：车辆选择回退、空/错误/已加载状态、记录排序和统计组装。
- 燃油优惠：结构化保存机显金额、实付金额和优惠金额，并兼容旧备注解析。
- 加油表单：金额联动控制器、保存组装、note 协议和错误文案。
- Repository：备份重复 ID、车辆引用和保养记录校验。
- Widget：导入预览、记一笔弹层、我的中心、加油页和保养页基础流程。

## CI

GitHub Actions 使用 Flutter stable `3.41.8`，与当前项目创建版本保持一致。CI 覆盖最小质量门禁：

```powershell
flutter pub get
flutter analyze
flutter test --concurrency 1
```

CI 不执行 release 构建和应用签名；当前不需要配置 GitHub Secrets。

## 数据和备份

运行数据保存在应用文档目录下的 `fuel_consumption.sqlite`。数据库 schema version 当前为 `4`，包含车辆表、补能记录表、保养记录表和燃油优惠结构化字段。JSON 备份格式由 `BackupCodec` 维护，当前 schema version 为 `1`，并兼容不含 `maintenanceRecords` 或燃油优惠结构化字段的旧备份。

导入备份时会校验：

- 记录引用的车辆必须存在。
- 保养记录引用的车辆必须存在。
- 同一车辆记录的里程需要按日期递增。
- 能源数量、金额和单价不能为负数。
- 保养费用必须大于 0。

## 后续计划

- 扩充测试：补充充电/插混补能表单、多车型切换、数据库迁移和 repository 导入导出 round-trip。
- 产品化 Android identity：正式 applicationId、应用名、图标、release 签名。
