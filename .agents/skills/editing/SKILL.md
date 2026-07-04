---
name: editing
description: "PPT 模板编辑指南 — 用于以现有演示文稿为模板进行内容替换和布局优化。当用户需要编辑/修改已有 PPTX 时触发。"
---

# Editing Presentations

## Overview

Template-based workflow for editing existing presentations.

## Workflow

1. Analyze existing slides with thumbnail.py and markitdown
2. Plan slide mapping — for each content section choose a template slide
3. Use varied layouts (multi-column, image+text, quote slides)
4. Execute edits and verify output

## Output Contract

- Modified PPTX file with varied layouts

## 关联 Skill（网络调度协议）

| 关系 | Skill | 场景 |
|------|-------|------|
| 被调用 | office-docs | 文档编辑链路中需编辑 PPT |
| 被调用 | executive-consultant | 需要修改现有演示文稿 |
