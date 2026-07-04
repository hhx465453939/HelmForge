# 功能扩展模板

## 当会计老师需要新增处理功能时，请按此模板描述：

---

### 【功能名称】
> 例: 月度费用趋势分析 / 直通车费用识别 / 微信支付对账

### 【输入数据】
> 什么格式？哪些字段？从哪里来？
> 例: "多个月份的输出Excel" 或 "新的CSV格式包含XX列"

### 【期望输出】
> 想要什么格式的结果？
> 例: "在Excel中新增一个Sheet" 或 "单独输出一个对比表"

### 【计算逻辑/分类规则】
> 核心计算公式 或 分类判断条件
> 例: "备注中包含'直通车'的记录归入'直通车推广费'类别"

### 【示例数据】
> 给1-2行输入样例和对应的期望输出
```
输入: 对方=XX公司, 备注="直通车推广扣费-计划XXX", 支出=-150.00
期望: 归入"直通车推广费", 关联到对应商品
```

---

## AI处理规范

收到上述需求后，AI应按以下步骤实现：

1. **分析需求** → 确定这是"新分类规则" / "新输出Sheet" / "新计算逻辑"
2. **定位修改点**:
   - 新分类: 修改 `FEE_RULES` 列表 + `mapping_schema.json`
   - 新Sheet: 添加 `build_xxx()` 函数 + ExcelWriter输出
   - 新计算: 在现有Sheet中追加列 或 新建Sheet
3. **编码实现** → 遵循现有代码风格 (函数命名 `build_xxx`, 返回 DataFrame)
4. **闭环验证** → 新功能不能破坏已有8项闭环校验
5. **测试运行** → 用现有数据运行一次确认无报错

## 已有函数清单 (可复用)

| 函数 | 位置 | 作用 |
|------|------|------|
| `classify_fee(remark, biz_type)` | process_alipay.py | 根据备注分类 |
| `extract_order_id(remark, merchant_no)` | process_alipay.py | 提取订单号 |
| `build_order_detail(df_processed)` | process_alipay.py | 构建订单明细 |
| `build_product_summary(detail_df)` | process_alipay.py | 产品汇总 |
| `build_fee_structure(...)` | process_alipay.py | 费用结构 |
| `build_deposit_detail(df_processed)` | process_alipay.py | 保证金明细 |
| `build_transfer_detail(df_processed)` | process_alipay.py | 资金划转 |
| `run_balance_checks(df, df_processed)` | balance_checker.py | 闭环校验 |
