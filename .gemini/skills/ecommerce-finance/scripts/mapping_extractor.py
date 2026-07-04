# -*- coding: utf-8 -*-
"""
映射关系解构脚本 (Mapping Extractor)
自动分析 input CSV → output Excel 之间的字段映射、计算规则、分组聚合关系

本质: 两个向量空间的确定性变换
- Input Vector Space: 支付宝CSV的12维记录 (流水号,业务流水号,商户订单号,商品名称,时间,对方,收入,支出,余额,渠道,类型,备注)
- Output Vector Space: 多Sheet Excel (订单费用明细17维, 产品汇总14维, 费用结构6维, 保证金8维, 划转6维)

映射类型:
1. 直通映射 (pass-through): 字段直接复制
2. 提取映射 (extract): 从备注/商户订单号中用regex提取值
3. 分类映射 (classify): 根据规则将记录分入不同费用类别
4. 聚合映射 (aggregate): 按订单号/商品名 group-by 后 sum
5. 计算映射 (compute): 衍生字段 (费用合计=sum, 费用率=|合计/收入|)
6. 闭环映射 (balance-check): 期初+收入-支出=期末 验证
"""

import json

# ============================================================================
# 映射规则定义 (Mapping Rules Definition)
# 这是整个 skill 的"知识核"—— deepseek只需要按规则执行
# ============================================================================

MAPPING_SCHEMA = {
    "meta": {
        "name": "tmall_alipay_fee_mapping",
        "version": "1.0.0",
        "description": "天猫支付宝账务CSV → 结构化费用Excel 的完整映射定义",
        "input_encoding": "gbk",
        "input_skip_rows": 4,
        "input_skip_footer": 4,
    },

    # ========== 输入向量空间定义 ==========
    "input_schema": {
        "columns": [
            {"name": "账务流水号", "type": "int64", "role": "id"},
            {"name": "业务流水号", "type": "string", "role": "id"},
            {"name": "商户订单号", "type": "string", "role": "key_source"},
            {"name": "商品名称", "type": "string", "role": "content"},
            {"name": "发生时间", "type": "datetime", "role": "timestamp"},
            {"name": "对方账号", "type": "string", "role": "classifier"},
            {"name": "收入金额（+元）", "type": "float64", "role": "amount_in"},
            {"name": "支出金额（-元）", "type": "float64", "role": "amount_out"},
            {"name": "账户余额（元）", "type": "float64", "role": "balance"},
            {"name": "交易渠道", "type": "string", "role": "channel"},
            {"name": "业务类型", "type": "string", "role": "biz_type"},
            {"name": "备注", "type": "string", "role": "classifier"},
        ],
    },

    # ========== 分类规则 (classify mapping) ==========
    # priority: 先匹配的优先
    "classification_rules": [
        # 业务类型直接判定
        {"condition": {"field": "业务类型", "op": "eq", "value": "交易付款"}, "output": "订单收入"},
        {"condition": {"field": "业务类型", "op": "eq", "value": "交易退款"}, "output": "售后退款"},
        {"condition": {"field": "业务类型", "op": "eq", "value": "收费"}, "output": "花呗分期费"},

        # 备注关键词判定 (按优先级排列)
        {"condition": {"field": "备注", "op": "contains", "value": "消费者体验提升计划服务费"}, "output": "体验提升计划"},
        {"condition": {"field": "备注", "op": "contains", "value": "天猫佣金"}, "output": "天猫佣金"},
        {"condition": {"field": "备注", "op": "contains", "value": "代扣返点积分"}, "output": "积分扣款"},
        {"condition": {"field": "备注", "op": "contains", "value": "代扣交易退回积分"}, "output": "积分扣款"},
        {"condition": {"field": "备注", "op": "contains", "value": "基础软件服务费"}, "output": "技术服务费"},
        {"condition": {"field": "备注", "op": "contains", "value": "消费券代付资金扣回"}, "output": "营销消费券"},
        {"condition": {"field": "备注", "op": "contains", "value": "花呗分期免息营销"}, "output": "花呗分期费"},
        {"condition": {"field": "备注", "op": "contains", "value": "淘宝客佣金"}, "output": "淘宝客佣金"},
        {"condition": {"field": "备注", "op": "contains", "value": "淘宝联盟推广佣金返还"}, "output": "淘宝客佣金"},
        {"condition": {"field": "备注", "op": "contains", "value": "淘宝联盟佣金代扣"}, "output": "淘宝客佣金"},
        {"condition": {"field": "备注", "op": "contains", "value": "公益宝贝"}, "output": "公益宝贝"},
        {"condition": {"field": "备注", "op": "contains", "value": "转出到网商银行"}, "output": "转出到网商银行"},
        {"condition": {"field": "备注", "op": "contains", "value": "天猫保证金"}, "output": "保证金"},
        {"condition": {"field": "备注", "op": "contains", "value": "保证金退款"}, "output": "保证金"},
        {"condition": {"field": "备注", "op": "contains", "value": "售后退款"}, "output": "售后退款"},
        {"condition": {"field": "备注", "op": "contains", "value": "余利宝"}, "output": "余利宝转入"},
    ],

    # ========== 订单号提取规则 (extract mapping) ==========
    "order_id_extraction": [
        {"source": "商户订单号", "pattern": "T200P(\\d{16,22})", "group": 1},
        {"source": "备注", "pattern": "订单号(\\d{16,22})", "group": 1},
        {"source": "备注", "pattern": "\\{(\\d{16,22})\\}", "group": 1},
        {"source": "备注", "pattern": "基础软件服务费\\((\\d{16,22})\\)", "group": 1},
        {"source": "备注", "pattern": "代扣返点积分(\\d{16,22})", "group": 1},
        {"source": "备注", "pattern": "淘宝客佣金代扣款\\[(\\d{16,22})\\]", "group": 1},
        {"source": "备注", "pattern": "消费券代付资金扣回\\((\\d{16,22})\\)", "group": 1},
        {"source": "备注", "pattern": "保证金退款.*?T200P(\\d{16,22})", "group": 1},
        {"source": "备注", "pattern": "售后退款.*?T200P(\\d{16,22})", "group": 1},
        {"source": "备注", "pattern": "代扣交易退回积分(\\d{16,22})", "group": 1},
    ],

    # ========== 输出向量空间: Sheet 定义 ==========
    "output_sheets": {
        "订单费用明细": {
            "type": "order_detail",
            "description": "每笔订单的收入与各项费用分摊明细",
            "primary_key": "订单号",
            "base_records": "订单收入",
            "columns": [
                {"name": "序号", "compute": "row_number"},
                {"name": "日期", "source": "发生时间", "transform": "date_only"},
                {"name": "商品名称", "source": "商品名称|备注"},
                {"name": "买家", "source": "对方账号"},
                {"name": "订单号(19位)", "source": "extracted_order_id"},
                {"name": "收入金额", "source": "收入金额（+元）"},
                {"name": "天猫佣金", "aggregate": "sum_by_order", "filter": "天猫佣金"},
                {"name": "技术服务费", "aggregate": "sum_by_order", "filter": "技术服务费"},
                {"name": "积分扣款", "aggregate": "sum_by_order", "filter": "积分扣款"},
                {"name": "体验提升计划", "aggregate": "sum_by_order", "filter": "体验提升计划"},
                {"name": "营销消费券", "aggregate": "sum_by_order", "filter": "营销消费券"},
                {"name": "花呗分期费", "aggregate": "sum_by_order", "filter": "花呗分期费"},
                {"name": "淘宝客佣金", "aggregate": "sum_by_order", "filter": "淘宝客佣金"},
                {"name": "公益宝贝", "aggregate": "sum_by_order", "filter": "公益宝贝"},
                {"name": "费用合计", "compute": "sum(天猫佣金..公益宝贝)"},
                {"name": "实际到账", "compute": "收入金额 + 费用合计"},
                {"name": "费用率", "compute": "|费用合计| / 收入金额"},
            ],
            "append_rows": [
                {"type": "cross_period_summary", "description": "跨期费用汇总(有订单号但不在当期订单中)"},
                {"type": "totals", "description": "合计行"},
            ],
        },

        "产品汇总": {
            "type": "product_summary",
            "description": "按商品名称聚合的费用统计",
            "group_by": "商品名称",
            "aggregation": "sum",
            "columns": ["商品", "销量(count)", "收入", "天猫佣金..公益宝贝", "费用合计", "净到账", "费用率"],
            "sort": "收入 DESC",
        },

        "费用结构与说明": {
            "type": "fee_structure",
            "description": "全局费用分类汇总 + 资金流向 + 闭环校验",
            "sections": [
                {"name": "费用明细", "rows": "8项费用 × (金额/笔数/占比)"},
                {"name": "资金流向", "rows": "转出网商/余利宝/保证金/退款"},
                {"name": "收支对照", "rows": "收入总额/支出合计/各项分解"},
                {"name": "闭环校验", "rows": "期末-期初余额差 ✅/❌"},
            ],
        },

        "保证金明细": {
            "type": "filter_detail",
            "filter": "保证金",
            "columns": ["序号", "日期", "时间", "业务描述", "类型", "收入", "支出", "账户余额"],
            "append": "净保证金现金支出",
        },

        "资金划转明细": {
            "type": "filter_detail",
            "filter": "转出到网商银行",
            "columns": ["序号", "日期", "时间", "类型", "支出金额", "账户余额"],
            "append": "划转合计",
        },
    },

    # ========== 闭环校验规则 (balance-check mapping) ==========
    "balance_checks": [
        {
            "name": "期初期末余额校验",
            "formula": "first_balance - first_transaction_amount == initial_balance",
            "description": "第一条记录的余额 - 该笔交易净额 = 期初余额",
        },
        {
            "name": "收支总额校验",
            "formula": "sum(收入) + sum(支出) == last_balance - initial_balance",
            "description": "所有收入-支出之和 = 期末余额-期初余额",
        },
        {
            "name": "费用覆盖率校验",
            "formula": "classified_count / total_count == 1.0",
            "description": "所有记录必须100%分类，无未分类项",
        },
        {
            "name": "订单费用完整性校验",
            "formula": "sum(订单费用明细.各项费用) == sum(分类后的费用记录)",
            "description": "订单明细的费用合计 + 跨期费用 == 原始费用记录总额",
        },
        {
            "name": "资金守恒校验",
            "formula": "收入总额 + 支出总额(负) == 期末余额 - 期初余额",
            "description": "资金进出必须等于余额变动，不允许凭空消失",
        },
    ],

    # ========== 费用类别元数据 ==========
    "fee_categories": {
        "天猫佣金": {
            "对方标识": "hdtmyj@service.aliyun.com",
            "direction": "expense",
            "备注模式": "天猫佣金（类目系统）{ORDER_ID}扣款",
            "可退款": True,
        },
        "技术服务费": {
            "对方标识": "tmtech@service.aliyun.com",
            "direction": "expense",
            "备注模式": "基础软件服务费(ORDER_ID)扣款",
            "可退款": False,
        },
        "积分扣款": {
            "对方标识": "jifenb2c@taobao.com",
            "direction": "expense",
            "备注模式": "代扣返点积分ORDER_ID",
            "可退款": True,
        },
        "体验提升计划": {
            "对方标识": "byfsrtg3@service.aliyun.com",
            "direction": "expense",
            "备注模式": "消费者体验提升计划服务费_订单号ORDER_ID",
            "可退款": False,
        },
        "营销消费券": {
            "对方标识": "mktxfq@service.aliyun.com",
            "direction": "expense",
            "备注模式": "消费券代付资金扣回(ORDER_ID)扣款",
            "可退款": True,
        },
        "花呗分期费": {
            "对方标识": "z97-revenue2@service.aliyun.com",
            "direction": "expense",
            "备注模式": "技术服务费(花呗分期免息营销)[TRADE_ID]",
            "可退款": False,
        },
        "淘宝客佣金": {
            "对方标识": ["tblmsr@service.aliyun.com", "***********金"],
            "direction": "expense",
            "备注模式": "淘宝客佣金代扣款[ORDER_ID]",
            "可退款": False,
        },
        "公益宝贝": {
            "对方标识": ["gongyibaobei@fupin.org.cn", "gongyibaobei@onefoundation.cn"],
            "direction": "expense",
            "备注模式": "公益宝贝捐赠=PROJECT=STORE",
            "可退款": False,
        },
    },

    # ========== 非费用类别 ==========
    "non_fee_categories": {
        "转出到网商银行": {"type": "fund_transfer", "direction": "out"},
        "余利宝转入": {"type": "fund_transfer", "direction": "out"},
        "保证金": {"type": "deposit", "direction": "both"},
        "售后退款": {"type": "refund", "direction": "expense"},
        "订单收入": {"type": "revenue", "direction": "income"},
    },
}


def export_mapping_schema(output_path="mapping_schema.json"):
    """导出映射规则为JSON文件"""
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(MAPPING_SCHEMA, f, ensure_ascii=False, indent=2)
    print(f"映射规则已导出: {output_path}")


if __name__ == '__main__':
    export_mapping_schema()
    print("\n=== 映射关系摘要 ===")
    print(f"输入维度: {len(MAPPING_SCHEMA['input_schema']['columns'])} 列")
    print(f"分类规则: {len(MAPPING_SCHEMA['classification_rules'])} 条")
    print(f"提取规则: {len(MAPPING_SCHEMA['order_id_extraction'])} 条")
    print(f"输出Sheet: {len(MAPPING_SCHEMA['output_sheets'])} 个")
    print(f"闭环校验: {len(MAPPING_SCHEMA['balance_checks'])} 项")
    print(f"费用类别: {len(MAPPING_SCHEMA['fee_categories'])} 种")

    print("\n=== 向量变换概览 ===")
    print("Input: 12维 × N条记录 (支付宝CSV)")
    print("  ↓ classify (备注+业务类型 → 费用分类)")
    print("  ↓ extract (备注/商户订单号 → 19位订单号)")
    print("  ↓ group_by (订单号)")
    print("  ↓ aggregate (sum per fee_category)")
    print("  ↓ compute (费用合计, 实际到账, 费用率)")
    print("Output: 5个Sheet × 不同维度")
    print("  - 订单费用明细: 17维 × 订单数")
    print("  - 产品汇总: 14维 × 商品种类数")
    print("  - 费用结构: 6维 × 20+行(含闭环校验)")
    print("  - 保证金明细: 8维 × 保证金记录数")
    print("  - 资金划转: 6维 × 划转笔数")
