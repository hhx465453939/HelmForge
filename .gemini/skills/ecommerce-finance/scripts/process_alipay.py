# -*- coding: utf-8 -*-
"""
天猫支付宝账务明细处理脚本
将支付宝导出的CSV账务明细转换为结构化的多Sheet Excel报表

输入: 支付宝导出的账务明细CSV(GBK编码) + 汇总CSV
输出: 多Sheet Excel文件，包含订单费用明细、产品汇总、费用结构等

用法:
    python process_alipay.py --input 明细.csv --summary 汇总.csv --output 输出.xlsx [--store 店铺名] [--period 账期]
"""

import pandas as pd
import re
import sys
import os
import argparse
from collections import defaultdict
from datetime import datetime

# ============================================================================
# 费用分类规则引擎
# ============================================================================

# 费用分类定义: (匹配关键词, 费用类型名, 金额方向)
FEE_RULES = [
    # 规则优先级从高到低
    ('消费者体验提升计划服务费', '体验提升计划', None),
    ('天猫佣金', '天猫佣金', None),
    ('代扣返点积分', '积分扣款', None),
    ('代扣交易退回积分', '积分扣款', None),  # 退款返还
    ('基础软件服务费', '技术服务费', None),
    ('消费券代付资金扣回', '营销消费券', None),
    ('花呗分期免息营销', '花呗分期费', None),
    ('淘宝客佣金', '淘宝客佣金', None),
    ('淘宝联盟推广佣金返还', '淘宝客佣金', None),  # 返还(收入)
    ('淘宝联盟佣金代扣', '淘宝客佣金', None),
    ('公益宝贝', '公益宝贝', None),
    ('转出到网商银行', '转出到网商银行', None),
    ('天猫保证金', '保证金', None),
    ('保证金退款', '保证金', None),
    ('售后退款', '售后退款', None),
    ('支付宝转账小额打款', '小额打款', None),
    ('余利宝', '余利宝转入', None),
]


def classify_fee(remark, biz_type):
    """根据备注和业务类型分类费用"""
    remark = str(remark)

    # 交易付款 = 订单收入
    if biz_type == '交易付款':
        return '订单收入'

    # 交易退款
    if biz_type == '交易退款':
        return '售后退款'

    # 收费类型
    if biz_type == '收费':
        return '花呗分期费'

    # 按关键词匹配
    for keyword, fee_type, _ in FEE_RULES:
        if keyword in remark:
            return fee_type

    # 其它类别中的特殊处理
    if '转出到网商银行' in remark:
        return '转出到网商银行'

    return '未分类'


def extract_order_id(remark, merchant_order_no=''):
    """从备注和商户订单号中提取19位订单号"""
    remark = str(remark)
    merchant_order_no = str(merchant_order_no).strip()

    # 从商户订单号提取: T200P3299194706518006493 → 3299194706518006493
    m = re.search(r'T200P(\d{16,22})', merchant_order_no)
    if m:
        return m.group(1)

    # 从备注提取订单号 - 多种格式
    patterns = [
        r'订单号(\d{16,22})',                    # 消费者体验提升计划
        r'\{(\d{16,22})\}',                       # 天猫佣金{xxx}
        r'基础软件服务费\((\d{16,22})\)',          # 技术服务费(xxx)
        r'代扣返点积分(\d{16,22})',               # 积分扣款
        r'淘宝客佣金代扣款\[(\d{16,22})\]',       # 淘宝客佣金
        r'消费券代付资金扣回\((\d{16,22})\)',      # 营销消费券
        r'保证金退款.*?T200P(\d{16,22})',          # 保证金退款
        r'售后退款.*?T200P(\d{16,22})',            # 售后退款
    ]
    for pattern in patterns:
        m = re.search(pattern, remark)
        if m:
            return m.group(1)

    return ''


def extract_order_id_from_merchant_no(merchant_order_no):
    """从商户订单号提取订单号(用于收入记录)"""
    s = str(merchant_order_no).strip()
    # T200P3299194706518006493 格式
    m = re.search(r'T200P(\d{16,22})', s)
    if m:
        return m.group(1)
    return ''


# ============================================================================
# 数据处理核心
# ============================================================================

def read_input(csv_path, summary_path=None):
    """读取支付宝CSV输入文件"""
    df = pd.read_csv(csv_path, encoding='gbk', skiprows=4, skipfooter=4, engine='python')
    df.columns = df.columns.str.strip()
    for col in df.select_dtypes(include='object').columns:
        df[col] = df[col].str.strip()

    # 读取汇总
    summary_lines = []
    if summary_path and os.path.exists(summary_path):
        with open(summary_path, encoding='gbk') as f:
            summary_lines = f.readlines()

    return df, summary_lines


def process_transactions(df):
    """处理所有交易记录，分类并提取订单号"""
    records = []

    for i, row in df.iterrows():
        remark = str(row['备注'])
        biz_type = str(row['业务类型'])
        income = float(row['收入金额（+元）'])
        expense = float(row['支出金额（-元）'])
        amount = income if income > 0 else expense
        merchant_no = str(row['商户订单号'])

        fee_type = classify_fee(remark, biz_type)
        order_id = extract_order_id(remark, merchant_no)

        record = {
            '账务流水号': row['账务流水号'],
            '业务流水号': str(row['业务流水号']),
            '商户订单号': merchant_no,
            '商品名称': str(row.get('商品名称', '')),
            '发生时间': str(row['发生时间']),
            '对方账号': str(row['对方账号']),
            '收入金额': income,
            '支出金额': expense,
            '账户余额': float(row['账户余额（元）']),
            '交易渠道': str(row['交易渠道']),
            '业务类型': biz_type,
            '备注': remark,
            '费用分类': fee_type,
            '订单号': order_id,
            '金额': amount,
        }
        records.append(record)

    return pd.DataFrame(records)


def build_order_detail(df_processed):
    """构建订单费用明细表"""
    # 1. 收集所有订单收入记录
    income_df = df_processed[df_processed['费用分类'] == '订单收入'].copy()

    # 2. 收集所有费用记录(按订单号分组)
    fee_categories = ['天猫佣金', '技术服务费', '积分扣款', '体验提升计划',
                      '营销消费券', '花呗分期费', '淘宝客佣金', '公益宝贝']

    orders = {}

    # 先建立订单基础信息(从收入记录)
    for _, row in income_df.iterrows():
        oid = row['订单号']
        if not oid:
            # 尝试从商户订单号提取
            oid = extract_order_id_from_merchant_no(row['商户订单号'])
        if not oid:
            continue

        if oid not in orders:
            orders[oid] = {
                '日期': row['发生时间'][:10],
                '商品名称': row['商品名称'] or row['备注'],
                '买家': row['对方账号'],
                '订单号': oid,
                '收入金额': row['收入金额'],
                '天猫佣金': 0,
                '技术服务费': 0,
                '积分扣款': 0,
                '体验提升计划': 0,
                '营销消费券': 0,
                '花呗分期费': 0,
                '淘宝客佣金': 0,
                '公益宝贝': 0,
            }
        else:
            orders[oid]['收入金额'] += row['收入金额']

    # 3. 匹配费用到订单
    cross_period_fees = defaultdict(float)  # 跨期费用(无法匹配到当期订单)

    for _, row in df_processed.iterrows():
        fee_type = row['费用分类']
        if fee_type not in fee_categories:
            continue

        oid = row['订单号']
        amount = row['金额']  # 负数为扣款，正数为返还

        if oid and oid in orders:
            orders[oid][fee_type] += amount
        elif oid:
            # 有订单号但不在当期收入中 → 跨期费用
            cross_period_fees[fee_type] += amount
        else:
            # 无订单号 → 也归入跨期
            cross_period_fees[fee_type] += amount

    # 4. 构建订单明细DataFrame
    order_rows = []
    seq = 1
    for oid in sorted(orders.keys(), key=lambda x: orders[x]['日期']):
        o = orders[oid]
        fee_total = sum(o.get(ft, 0) for ft in fee_categories)
        net_amount = o['收入金额'] + fee_total  # fee_total是负数
        fee_rate = abs(fee_total / o['收入金额']) if o['收入金额'] > 0 else 0

        row = {
            '序号': seq,
            '日期': o['日期'],
            '商品名称': o['商品名称'],
            '买家': o['买家'],
            '订单号(19位)': oid,
            '收入金额': o['收入金额'],
            '天猫佣金': o['天猫佣金'] if o['天猫佣金'] != 0 else None,
            '技术服务费': o['技术服务费'] if o['技术服务费'] != 0 else None,
            '积分扣款': o['积分扣款'] if o['积分扣款'] != 0 else None,
            '体验提升计划': o['体验提升计划'] if o['体验提升计划'] != 0 else None,
            '营销消费券': o['营销消费券'] if o['营销消费券'] != 0 else None,
            '花呗分期费': o['花呗分期费'] if o['花呗分期费'] != 0 else None,
            '淘宝客佣金': o['淘宝客佣金'] if o['淘宝客佣金'] != 0 else None,
            '公益宝贝': o['公益宝贝'] if o['公益宝贝'] != 0 else None,
            '费用合计': round(fee_total, 2),
            '实际到账': round(net_amount, 2),
            '费用率': round(fee_rate, 6),
        }
        order_rows.append(row)
        seq += 1

    detail_df = pd.DataFrame(order_rows)

    # 5. 添加跨期费用汇总行
    seq_num = len(order_rows)
    for ft in fee_categories:
        if cross_period_fees.get(ft, 0) != 0:
            seq_num += 1
            detail_df = pd.concat([detail_df, pd.DataFrame([{
                '序号': seq_num,
                '日期': '--',
                '商品名称': f'(跨期费用汇总-{ft})',
                '买家': None,
                '订单号(19位)': f'AGG_{ft}',
                '收入金额': 0,
                '天猫佣金': None,
                '技术服务费': None,
                '积分扣款': None,
                '体验提升计划': None,
                '营销消费券': None,
                '花呗分期费': None,
                '淘宝客佣金': None,
                '公益宝贝': None,
                ft: round(cross_period_fees[ft], 2),
                '费用合计': round(cross_period_fees[ft], 2),
                '实际到账': round(cross_period_fees[ft], 2),
                '费用率': 0,
            }])], ignore_index=True)

    # 6. 添加合计行
    totals = {
        '序号': '合计',
        '日期': None,
        '商品名称': None,
        '买家': f'{len(order_rows)}笔',
        '订单号(19位)': None,
    }
    for col in ['收入金额'] + fee_categories + ['费用合计', '实际到账']:
        vals = detail_df[col].dropna()
        totals[col] = round(vals.sum(), 2) if len(vals) > 0 else 0
    totals['费用率'] = round(abs(totals['费用合计'] / totals['收入金额']), 8) if totals['收入金额'] > 0 else 0
    detail_df = pd.concat([detail_df, pd.DataFrame([totals])], ignore_index=True)

    return detail_df, orders, cross_period_fees


def build_product_summary(detail_df):
    """构建产品汇总表"""
    # 排除合计和跨期汇总行
    data = detail_df[detail_df['序号'].apply(lambda x: isinstance(x, int))].copy()

    fee_categories = ['天猫佣金', '技术服务费', '积分扣款', '体验提升计划',
                      '营销消费券', '花呗分期费', '淘宝客佣金', '公益宝贝']

    product_rows = []
    for name, group in data.groupby('商品名称', sort=False):
        row = {'商品': name}
        row['销量'] = len(group)
        row['收入'] = round(group['收入金额'].sum(), 2)
        for ft in fee_categories:
            vals = group[ft].dropna()
            row[ft] = round(vals.sum(), 2) if len(vals) > 0 else 0
        row['费用合计'] = round(sum(row.get(ft, 0) for ft in fee_categories), 2)
        row['净到账'] = round(row['收入'] + row['费用合计'], 2)
        row['费用率'] = round(abs(row['费用合计'] / row['收入']), 6) if row['收入'] > 0 else 0
        product_rows.append(row)

    pdf = pd.DataFrame(product_rows)

    # 按收入降序排列
    pdf = pdf.sort_values('收入', ascending=False).reset_index(drop=True)

    # 添加合计行
    if len(pdf) > 0:
        totals = {'商品': '合计'}
        totals['销量'] = pdf['销量'].sum()
        totals['收入'] = round(pdf['收入'].sum(), 2)
        for ft in fee_categories:
            totals[ft] = round(pdf[ft].sum(), 2)
        totals['费用合计'] = round(pdf['费用合计'].sum(), 2)
        totals['净到账'] = round(pdf['净到账'].sum(), 2)
        totals['费用率'] = round(abs(totals['费用合计'] / totals['收入']), 6) if totals['收入'] > 0 else 0
        pdf = pd.concat([pdf, pd.DataFrame([totals])], ignore_index=True)

    return pdf


def build_fee_structure(detail_df, df_processed, orders, cross_period_fees):
    """构建费用结构说明表"""
    fee_categories = ['天猫佣金', '技术服务费', '积分扣款', '体验提升计划',
                      '营销消费券', '花呗分期费', '淘宝客佣金', '公益宝贝']

    # 计算各费用总额
    data = detail_df[detail_df['序号'].apply(lambda x: isinstance(x, int))]
    total_income = data['收入金额'].sum()

    fee_rows = []
    for ft in fee_categories:
        # 从处理后的数据中统计笔数
        fee_records = df_processed[df_processed['费用分类'] == ft]
        count = len(fee_records[fee_records['金额'] < 0])  # 只统计扣款笔数
        amount = round(data[ft].dropna().sum(), 2) if ft in data.columns else 0

        # 加上跨期费用
        cross_amount = cross_period_fees.get(ft, 0)
        total_amount = round(amount + cross_amount, 2)

        fee_rows.append({
            '项目': ft,
            '金额(Sheet1)': round(amount, 2),
            '金额(全局)': total_amount,
            '笔数': count,
            '占收入比': round(abs(total_amount / total_income), 6) if total_income > 0 else 0,
            '说明': None,
        })

    fsf = pd.DataFrame(fee_rows)

    # 添加分隔行和汇总信息
    total_fees = sum(r['金额(全局)'] for r in fee_rows)

    # 转出到网商银行总额
    transfer_records = df_processed[df_processed['费用分类'] == '转出到网商银行']
    transfer_total = transfer_records['支出金额'].sum()
    # 余利宝转入
    yulibao_records = df_processed[df_processed['费用分类'] == '余利宝转入']
    yulibao_total = yulibao_records['支出金额'].sum()
    # 保证金净额
    deposit_records = df_processed[df_processed['费用分类'] == '保证金']
    deposit_total = deposit_records['支出金额'].sum() + deposit_records['收入金额'].sum()
    # 退款总额
    refund_records = df_processed[df_processed['费用分类'] == '售后退款']
    refund_total = refund_records['支出金额'].sum()
    # 原始支出合计
    total_expense = df_processed['支出金额'].sum()
    # 原始收入合计
    total_income_raw = df_processed['收入金额'].sum()
    # 其他/差异
    other_diff = round(total_expense - total_fees - transfer_total - yulibao_total - deposit_records['支出金额'].sum() - refund_total, 2)

    summary_rows = pd.DataFrame([
        {'项目': None, '金额(Sheet1)': None, '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '📌 转出网商银行', '金额(Sheet1)': round(transfer_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': f'{len(transfer_records)}笔'},
        {'项目': '📌 余利宝转入', '金额(Sheet1)': round(yulibao_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': f'{len(yulibao_records)}笔'},
        {'项目': '📌 天猫保证金', '金额(Sheet1)': round(deposit_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '📌 售后退款', '金额(Sheet1)': round(refund_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': None, '金额(Sheet1)': None, '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '收入总额', '金额(Sheet1)': round(total_income_raw, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '原始支出合计', '金额(Sheet1)': round(total_expense, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 各项费用', '金额(Sheet1)': round(total_fees, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 资金划转(网商)', '金额(Sheet1)': round(transfer_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 资金划转(余利宝)', '金额(Sheet1)': round(yulibao_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 保证金', '金额(Sheet1)': round(deposit_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 售后退款', '金额(Sheet1)': round(refund_total, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': '= 其他/差异', '金额(Sheet1)': round(other_diff, 2), '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': None, '金额(Sheet1)': None, '金额(全局)': None, '笔数': None, '占收入比': None, '说明': None},
        {'项目': None, '金额(Sheet1)': f'→ ¥{round(total_income_raw + total_expense, 2)}', '金额(全局)': None, '笔数': None, '占收入比': None, '说明': '期末-期初余额差'},
    ])

    return pd.concat([fsf, summary_rows], ignore_index=True)


def build_deposit_detail(df_processed):
    """构建保证金明细表"""
    deposit_df = df_processed[df_processed['费用分类'] == '保证金'].copy()

    rows = []
    seq = 1
    for _, row in deposit_df.iterrows():
        dep_type = '未知'
        remark = str(row['备注'])

        if '充值' in remark and '解冻' not in remark:
            if '延迟' in remark or '承诺未履约' in remark:
                dep_type = '扣款(延迟)'
            else:
                dep_type = '缴存(支出)'
        elif '解冻' in remark:
            dep_type = '解冻(收入)'
        elif '退款' in remark:
            dep_type = '退款(支出)'

        rows.append({
            '序号': seq,
            '日期': row['发生时间'][:10],
            '时间': row['发生时间'][11:],
            '业务描述': remark,
            '类型': dep_type,
            '收入': row['收入金额'],
            '支出': row['支出金额'],
            '账户余额': row['账户余额'],
        })
        seq += 1

    result = pd.DataFrame(rows)

    # 添加净保证金现金支出
    if len(result) > 0:
        net_deposit = round(result['支出'].sum() + result['收入'].sum(), 2)
        result = pd.concat([result, pd.DataFrame([
            {'序号': None, '日期': None, '时间': None, '业务描述': None, '类型': None, '收入': None, '支出': None, '账户余额': None},
            {'序号': None, '日期': None, '时间': None, '业务描述': '净保证金现金支出', '类型': None, '收入': None, '支出': net_deposit, '账户余额': None},
        ])], ignore_index=True)

    return result


def build_transfer_detail(df_processed):
    """构建资金划转明细表"""
    transfer_df = df_processed[df_processed['费用分类'] == '转出到网商银行'].copy()

    rows = []
    seq = 1
    for _, row in transfer_df.iterrows():
        time_str = str(row['发生时间'])
        rows.append({
            '序号': seq,
            '日期': time_str[:10],
            '时间': time_str[11:16] if len(time_str) > 16 else '',
            '类型': '转出到网商银行',
            '支出金额': row['支出金额'],
            '账户余额': row['账户余额'],
        })
        seq += 1

    result = pd.DataFrame(rows)

    # 添加汇总行
    if len(result) > 0:
        total_transfer = round(result['支出金额'].sum(), 2)
        result = pd.concat([result, pd.DataFrame([
            {'序号': None, '日期': None, '时间': None, '类型': None, '支出金额': None, '账户余额': None},
            {'序号': None, '日期': None, '时间': None, '类型': '转出到网商银行合计', '支出金额': total_transfer, '账户余额': f'{len(rows)}笔'},
            {'序号': None, '日期': None, '时间': None, '类型': '资金划转总计', '支出金额': total_transfer, '账户余额': f'{len(rows)}笔'},
        ])], ignore_index=True)

    return result


def build_raw_order_reconciliation(df_processed):
    """构建原始订单对账表(Sheet1)"""
    income_df = df_processed[df_processed['费用分类'] == '订单收入'].copy()

    rows = []
    for _, row in income_df.iterrows():
        oid = row['订单号'] or extract_order_id_from_merchant_no(row['商户订单号'])
        if oid:
            rows.append({
                '订单号(19位)': oid,
                '收入金额': row['收入金额'],
            })

    return pd.DataFrame(rows)


# ============================================================================
# 主流程
# ============================================================================

def main(csv_path, summary_path, output_path, store_name='', period=''):
    """主处理流程"""
    print(f'读取输入文件: {csv_path}')
    df, summary_lines = read_input(csv_path, summary_path)
    print(f'共 {len(df)} 条交易记录')

    # 处理交易记录
    df_processed = process_transactions(df)

    # 统计分类结果
    print('\n=== 费用分类统计 ===')
    for ft, count in df_processed['费用分类'].value_counts().items():
        subset = df_processed[df_processed['费用分类'] == ft]
        income = subset['收入金额'].sum()
        expense = subset['支出金额'].sum()
        print(f'  {ft}: {count}条, 收入={income:.2f}, 支出={expense:.2f}')

    # 构建各Sheet
    print('\n构建订单费用明细...')
    detail_df, orders, cross_period_fees = build_order_detail(df_processed)
    print(f'  订单数: {len(orders)}, 跨期费用类别: {len(cross_period_fees)}')

    print('构建产品汇总...')
    product_df = build_product_summary(detail_df)

    print('构建费用结构说明...')
    fee_structure_df = build_fee_structure(detail_df, df_processed, orders, cross_period_fees)

    print('构建保证金明细...')
    deposit_df = build_deposit_detail(df_processed)

    print('构建资金划转明细...')
    transfer_df = build_transfer_detail(df_processed)

    print('构建原始对账表...')
    reconciliation_df = build_raw_order_reconciliation(df_processed)

    # 提取账期信息
    if not period:
        dates = df_processed['发生时间'].sort_values()
        if len(dates) > 0:
            first_date = str(dates.iloc[0])[:7].replace('-', '.')
            period = first_date

    if not store_name:
        # 从对方账号中推断店铺名
        email = ''
        for _, row in df_processed.iterrows():
            if 'yoiwo' in str(row['对方账号']).lower() or 'yoiwo' in str(row['备注']).lower():
                store_name = 'yoiwo'
                break
            elif 'eporas' in str(row['对方账号']).lower() or 'eporas' in str(row['备注']).lower():
                store_name = 'eporas'
                break
        if not store_name:
            store_name = 'unknown'

    # 写入Excel
    print(f'\n写入输出文件: {output_path}')
    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        # Sheet1: 账单汇总
        summary_data = []
        for line in summary_lines:
            line = line.strip()
            if line:
                parts = [p.strip().strip('\t') for p in line.split(',')]
                if len(parts) >= 2:
                    summary_data.append(parts)

        if summary_data:
            summary_df = pd.DataFrame(summary_data)
            summary_df.to_excel(writer, sheet_name='账单汇总', index=False, header=False)

        # Sheet2: 账单明细(原始数据带分类)
        detail_raw = df_processed[[
            '账务流水号', '业务流水号', '商户订单号', '商品名称', '发生时间',
            '对方账号', '收入金额', '支出金额', '账户余额', '交易渠道',
            '业务类型', '备注', '费用分类', '订单号'
        ]].copy()
        detail_raw.to_excel(writer, sheet_name='账单明细', index=False)

        # Sheet3: 订单费用明细
        detail_df.to_excel(writer, sheet_name='订单费用明细', index=False)

        # Sheet4: 产品汇总
        product_df.to_excel(writer, sheet_name='产品汇总', index=False)

        # Sheet5: 费用结构与说明
        fee_structure_df.to_excel(writer, sheet_name='费用结构与说明', index=False)

        # Sheet6: 保证金明细
        deposit_df.to_excel(writer, sheet_name='保证金明细', index=False)

        # Sheet7: 资金划转明细
        transfer_df.to_excel(writer, sheet_name='资金划转明细', index=False)

        # Sheet8: 原始对账表
        reconciliation_df.to_excel(writer, sheet_name='Sheet1', index=False)

        # Sheet9: 闭环校验报告
        from balance_checker import run_balance_checks
        report = run_balance_checks(df, df_processed, store=store_name, period=period)

        check_rows = []
        for c in report.checks:
            check_rows.append({
                '校验项': c.name,
                '结果': '✅ 通过' if c.passed else ('❌ 错误' if c.severity == 'ERROR' else '⚠️ 警告'),
                '期望值': c.expected,
                '实际值': c.actual,
                '差异': c.diff,
                '说明': c.detail,
                '严重级别': c.severity,
            })
        check_rows.append({})  # 空行分隔
        for k, v in report.summary.items():
            check_rows.append({'校验项': f'📊 {k}', '结果': v})

        check_df = pd.DataFrame(check_rows)
        check_df.to_excel(writer, sheet_name='闭环校验', index=False)

    print(f'\n✅ 完成! 输出文件: {output_path}')

    # 打印关键统计
    total_income = df_processed[df_processed['费用分类'] == '订单收入']['收入金额'].sum()
    print(f'\n=== 关键统计 ===')
    print(f'店铺: {store_name}')
    print(f'账期: {period}')
    print(f'订单收入总额: {total_income:.2f}')
    print(f'订单数量: {len(orders)}')
    print(f'跨期费用: {dict(cross_period_fees)}')

    # 闭环校验报告
    print('\n')
    report.print_report()
    return output_path


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='天猫支付宝账务明细处理')
    parser.add_argument('--input', required=True, help='账务明细CSV路径')
    parser.add_argument('--summary', default=None, help='账务汇总CSV路径')
    parser.add_argument('--output', required=True, help='输出Excel路径')
    parser.add_argument('--store', default='', help='店铺名称')
    parser.add_argument('--period', default='', help='账期(如2026.05)')
    args = parser.parse_args()

    main(args.input, args.summary, args.output, args.store, args.period)
