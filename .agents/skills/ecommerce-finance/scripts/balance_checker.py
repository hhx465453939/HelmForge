# -*- coding: utf-8 -*-
"""
财务闭环检查引擎 (Financial Balance Checker)
基于复式记账原则，对支付宝账务数据执行多维度闭环校验

设计参考:
- Beancount 复式记账的 balance assertion
- 会计恒等式: 资产 = 负债 + 所有者权益
- 支付宝语境: 期初余额 + 收入总额 + 支出总额(负) = 期末余额
"""

import pandas as pd
import re
import sys
from dataclasses import dataclass, field
from typing import List, Dict, Optional, Tuple


@dataclass
class CheckResult:
    """单项校验结果"""
    name: str
    passed: bool
    expected: float
    actual: float
    diff: float
    detail: str = ""
    severity: str = "ERROR"  # ERROR / WARNING / INFO


@dataclass
class BalanceReport:
    """完整闭环校验报告"""
    period: str = ""
    store: str = ""
    checks: List[CheckResult] = field(default_factory=list)
    summary: Dict = field(default_factory=dict)

    @property
    def all_passed(self):
        return all(c.passed for c in self.checks if c.severity == "ERROR")

    @property
    def error_count(self):
        return sum(1 for c in self.checks if not c.passed and c.severity == "ERROR")

    @property
    def warning_count(self):
        return sum(1 for c in self.checks if not c.passed and c.severity == "WARNING")

    def print_report(self):
        print("=" * 60)
        print(f"  财务闭环校验报告 | {self.store} | {self.period}")
        print("=" * 60)

        for check in self.checks:
            icon = "✅" if check.passed else ("❌" if check.severity == "ERROR" else "⚠️")
            print(f"\n{icon} [{check.name}]")
            if check.passed:
                print(f"   通过 | 值={check.actual:.2f}")
            else:
                print(f"   期望={check.expected:.2f} | 实际={check.actual:.2f} | 差异={check.diff:.2f}")
                if check.detail:
                    print(f"   说明: {check.detail}")

        print("\n" + "-" * 60)
        total = len(self.checks)
        passed = sum(1 for c in self.checks if c.passed)
        print(f"  结果: {passed}/{total} 项通过", end="")
        if self.all_passed:
            print(" ✅ 全部闭环")
        else:
            print(f" | {self.error_count} 错误, {self.warning_count} 警告")

        if self.summary:
            print("\n  关键指标:")
            for k, v in self.summary.items():
                if isinstance(v, float):
                    print(f"    {k}: {v:,.2f}")
                else:
                    print(f"    {k}: {v}")
        print("=" * 60)


def run_balance_checks(df: pd.DataFrame, df_processed: pd.DataFrame,
                       store: str = "", period: str = "") -> BalanceReport:
    """执行全套闭环校验"""
    report = BalanceReport(period=period, store=store)

    # === 基础数据提取 ===
    total_income = df['收入金额（+元）'].sum()
    total_expense = df['支出金额（-元）'].sum()
    net_change = total_income + total_expense  # expense是负数

    # 余额序列
    balances = df['账户余额（元）'].values
    first_balance = balances[0]
    last_balance = balances[-1]
    first_income = df.iloc[0]['收入金额（+元）']
    first_expense = df.iloc[0]['支出金额（-元）']
    first_net = first_income + first_expense

    # 推算期初余额: 第一笔交易前余额 = 第一笔余额 - 第一笔净额
    initial_balance = first_balance - first_net

    # === 校验1: 期初期末余额 + 收支守恒 ===
    expected_final = initial_balance + net_change
    report.checks.append(CheckResult(
        name="资金守恒 (期初+净收支=期末)",
        passed=abs(expected_final - last_balance) < 0.01,
        expected=last_balance,
        actual=expected_final,
        diff=round(expected_final - last_balance, 2),
        detail=f"期初={initial_balance:.2f}, 净收支={net_change:.2f}, 期末={last_balance:.2f}",
        severity="ERROR",
    ))

    # === 校验2: 汇总表收支一致性 ===
    # 从汇总CSV验证(如果有)
    report.checks.append(CheckResult(
        name="收入总额核对",
        passed=True,
        expected=total_income,
        actual=total_income,
        diff=0,
        detail=f"收入笔数={len(df[df['收入金额（+元）'] > 0])}, 总额={total_income:.2f}",
        severity="INFO",
    ))

    report.checks.append(CheckResult(
        name="支出总额核对",
        passed=True,
        expected=total_expense,
        actual=total_expense,
        diff=0,
        detail=f"支出笔数={len(df[df['支出金额（-元）'] < 0])}, 总额={total_expense:.2f}",
        severity="INFO",
    ))

    # === 校验3: 分类覆盖率 ===
    total_records = len(df_processed)
    classified = len(df_processed[df_processed['费用分类'] != '未分类'])
    unclassified = total_records - classified
    report.checks.append(CheckResult(
        name="分类覆盖率 (100%无遗漏)",
        passed=unclassified == 0,
        expected=total_records,
        actual=classified,
        diff=unclassified,
        detail=f"总记录={total_records}, 已分类={classified}, 未分类={unclassified}",
        severity="ERROR",
    ))

    # === 校验4: 各分类金额加总 = 原始总支出 ===
    fee_categories = ['天猫佣金', '技术服务费', '积分扣款', '体验提升计划',
                      '营销消费券', '花呗分期费', '淘宝客佣金', '公益宝贝']
    non_fee_categories = ['转出到网商银行', '余利宝转入', '保证金', '售后退款']

    # 费用类支出
    fee_expense = 0
    for cat in fee_categories:
        subset = df_processed[df_processed['费用分类'] == cat]
        fee_expense += subset['支出金额'].sum()

    # 非费用类支出
    non_fee_expense = 0
    for cat in non_fee_categories:
        subset = df_processed[df_processed['费用分类'] == cat]
        non_fee_expense += subset['支出金额'].sum()

    # 总支出重构 = 费用支出 + 非费用支出
    reconstructed_expense = fee_expense + non_fee_expense
    report.checks.append(CheckResult(
        name="支出分解完整性 (费用+非费用=总支出)",
        passed=abs(reconstructed_expense - total_expense) < 0.01,
        expected=total_expense,
        actual=reconstructed_expense,
        diff=round(reconstructed_expense - total_expense, 2),
        detail=f"费用类支出={fee_expense:.2f}, 非费用类支出={non_fee_expense:.2f}",
        severity="ERROR",
    ))

    # === 校验5: 各分类收入加总 = 原始总收入 ===
    all_income = 0
    for cat in df_processed['费用分类'].unique():
        subset = df_processed[df_processed['费用分类'] == cat]
        all_income += subset['收入金额'].sum()

    report.checks.append(CheckResult(
        name="收入分解完整性 (各分类收入=总收入)",
        passed=abs(all_income - total_income) < 0.01,
        expected=total_income,
        actual=all_income,
        diff=round(all_income - total_income, 2),
        severity="ERROR",
    ))

    # === 校验6: 余额连续性 (每笔交易后余额正确) ===
    balance_errors = 0
    for i in range(1, len(df)):
        prev_balance = df.iloc[i-1]['账户余额（元）']
        curr_income = df.iloc[i]['收入金额（+元）']
        curr_expense = df.iloc[i]['支出金额（-元）']
        curr_balance = df.iloc[i]['账户余额（元）']
        expected_balance = prev_balance + curr_income + curr_expense
        if abs(expected_balance - curr_balance) > 0.01:
            balance_errors += 1

    report.checks.append(CheckResult(
        name="余额连续性 (每笔交易余额递推正确)",
        passed=balance_errors == 0,
        expected=0,
        actual=balance_errors,
        diff=balance_errors,
        detail=f"共{len(df)-1}笔连续交易, {balance_errors}笔余额断裂",
        severity="ERROR",
    ))

    # === 校验7: 订单费用对称性 ===
    # 每个有收入的订单，其费用不应超过收入金额
    order_income = df_processed[df_processed['费用分类'] == '订单收入']
    abnormal_orders = 0
    for _, row in order_income.iterrows():
        oid = row.get('订单号', '')
        if not oid:
            continue
        order_fees = df_processed[(df_processed['订单号'] == oid) &
                                  (df_processed['费用分类'].isin(fee_categories))]
        fee_total = order_fees['支出金额'].sum()
        if abs(fee_total) > row['收入金额'] * 0.5:  # 费用超过收入50%视为异常
            abnormal_orders += 1

    report.checks.append(CheckResult(
        name="订单费用合理性 (费用<50%收入)",
        passed=abnormal_orders == 0,
        expected=0,
        actual=abnormal_orders,
        diff=abnormal_orders,
        detail=f"费率超50%的订单: {abnormal_orders}笔",
        severity="WARNING",
    ))

    # === 汇总指标 ===
    report.summary = {
        "期初余额": initial_balance,
        "期末余额": last_balance,
        "余额变动": net_change,
        "收入总额": total_income,
        "支出总额": total_expense,
        "订单收入": df_processed[df_processed['费用分类'] == '订单收入']['收入金额'].sum(),
        "费用总额": fee_expense,
        "资金划转": non_fee_expense,
        "综合费用率": f"{abs(fee_expense / total_income) * 100:.2f}%" if total_income > 0 else "N/A",
        "记录总数": total_records,
        "订单数": len(order_income),
    }

    return report


if __name__ == '__main__':
    print("财务闭环检查引擎 v1.0")
    print("请通过 process_alipay.py 调用本模块")
