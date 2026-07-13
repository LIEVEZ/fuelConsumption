# fuelConsumption

fuelConsumption 是一个离线优先的 Flutter 能耗记录应用，用于管理多辆车的加油、充电和插混补能记录。应用当前以 Android 验证为主，数据保存在本机 SQLite 数据库中，并支持 JSON 手动导入导出备份。

## 当前功能

- 车辆档案：支持燃油车、电车、插混和摩托车。
- 补能记录：按车辆类型进入加油、充电或油电混合表单。
- 统计概览：展示平均能耗、最近能耗、总费用、每公里成本和累计里程。
- 费用页：汇总补能费用、保养费用和年度支出，并展示明细。
- 趋势展示：通过图表展示能耗和费用趋势。
- 我的中心：管理车辆、本地备份导入导出、使用帮助和隐私说明。
- 本地存储：使用 Drift + SQLite 保存车辆、补能记录和保养记录。
- 手动备份：支持 JSON 导出和粘贴 JSON 导入。
- 保养记录：可从新增入口记录保养、维修等非能源费用。
- 燃油优惠：加油表单结构化保存机显金额、实付金额和优惠金额。

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
   ├─ app.dart                # 根 UI 和主题
   ├─ application/            # Dashboard 查询、记录/车辆命令、备份协议和 ports
   ├─ presentation/           # Riverpod provider 接线
   ├─ screens/                # 页面编排和表单控制器
   ├─ widgets/                # 底部导航、首页/费用/我的/补能组件、创建弹层和弹窗
   ├─ domain/
   │  ├─ models.dart          # 车辆、补能记录、保养记录等领域模型
   │  ├─ statistics.dart      # 能耗统计快照
   │  ├─ consumption_statistics.dart
   │  ├─ energy_record_assembler.dart
   │  ├─ expense_statistics.dart
   │  ├─ fuel_grades.dart
   │  ├─ legacy_refuel_note_parser.dart
   │  ├─ record_amounts.dart
   │  ├─ refuel_amount_calculator.dart
   │  ├─ refuel_record_assembler.dart
   │  └─ validation.dart      # 补能记录校验
   └─ data/
      ├─ repository_provider.dart # Riverpod repository 生命周期管理
      ├─ fuel_repository.dart # repository 实现
      ├─ app_database.dart    # Drift 数据库 API
      ├─ app_database_*       # 连接、表定义、迁移、DAO 和 row/domain 映射
      ├─ app_database.g.dart  # Drift 生成代码
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

当前测试覆盖 32 个测试文件、113 个用例：

- 架构边界：锁定 domain/application 无 Flutter/Riverpod/data 反向依赖、UI 层不直连 data、widgets 不依赖 screens，并防止 data mapper 复用备份 JSON serializer。
- 领域统计：燃油、电车、插混、少量记录、月度/年度趋势和费用概览。
- 费用统计：能源费用、保养费用、年度费用和费用明细聚合。
- 记录校验：能源数量、里程顺序、保养费用、仓储保存和备份语义校验。
- 备份编码：可读错误提示、必填字段校验、多能源 round-trip、旧备份兼容和导入 action。
- Dashboard 数据流和命令：车辆选择回退、空/错误/已加载状态、记录排序、统计组装、presentation provider 接线、车辆/补能/保养/备份命令，以及 `DashboardCommandService` 到 `RecordCommandService` 的保存委派。
- 燃油优惠：结构化保存机显金额、实付金额和优惠金额，旧备注仅用于迁移和旧备份兼容。
- 补能表单：加油金额联动、充电记录、油电混合记录、`RefuelRecordInput` / `ChargeRecordInput` / `HybridRecordInput` 表单提交、领域组装、结构化金额字段和错误文案。
- Repository：备份重复 ID、车辆引用、多能源记录导入导出、导入替换事务回滚和保养记录校验。
- Widget：导入预览、车辆弹窗、记一笔弹层、燃油/摩托车/电车/插混 Dashboard 补能路由、费用明细、我的中心组件、加油页、充电页、油电页和保养页基础流程。

## CI

GitHub Actions 使用 Flutter stable `3.41.8`，与当前项目创建版本保持一致。CI 覆盖最小质量门禁：

```powershell
flutter pub get
flutter analyze
flutter test --concurrency 1
```

CI 不执行 release 构建和应用签名；当前不需要配置 GitHub Secrets。

## Android 发布配置

Android 包名和 namespace 已配置为 `com.fuelconsumption.app`，应用显示名为“油耗”，启动图标位于 `android/app/src/main/res/mipmap-*`。

Release 签名从本机 `android/key.properties` 读取。仓库只提交 `android/key.properties.example`，真实 `key.properties`、`.jks` 和 `.keystore` 会被忽略，不应提交到 Git。执行 release 构建时如果缺少真实签名配置会直接失败；配置完成后可执行：

```powershell
flutter build apk --release
```

## 数据和备份

运行数据保存在应用文档目录下的 `fuel_consumption.sqlite`。数据库 schema version 当前为 `4`，包含车辆表、补能记录表、保养记录表和燃油优惠结构化字段。升级到 v4 时会从历史备注中回填机显金额、实付金额和优惠金额。JSON 备份格式由 application 层的 `BackupCodec` 维护，当前 schema version 为 `1`，并兼容不含 `maintenanceRecords` 或燃油优惠结构化字段的旧备份；旧备份中的历史备注金额会在解码时派生为结构化字段。

导入备份时会校验：

- 记录引用的车辆必须存在。
- 保养记录引用的车辆必须存在。
- 同一车辆记录的里程需要按日期递增。
- 能源数量、金额和单价不能为负数。
- 保养费用必须大于 0。

## 后续计划

- 发布收口：配置正式上传密钥、版本号策略和 release 渠道检查清单。
- 体验增强：后续可接入系统分享、更多导入冲突处理策略和费用图表筛选。
