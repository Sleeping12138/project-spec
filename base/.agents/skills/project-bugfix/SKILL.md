---
name: project-bugfix
description: Use when a bug, exception, failing test, build failure, or unexpected behavior needs investigation in the current project.
---

# Bug 排查与修复

## 输入与边界

读取根 `AGENTS.md`、适用规则、错误证据和相关实现；存在 OpenSpec change 时复用其规格、设计、任务。只有新事实影响需求时才更新相应变更内容。

## 流程

1. 取得失败证据：复现步骤、输入、预期、实际结果和环境。不能复现时保留不确定性，先缩小条件，不直接猜改代码。
2. 从失败入口追踪调用者、边界和近期相关差异，提出有证据的根因假设。检查隔离、夹具和模拟是否符合真实契约。
3. 选择最小有效复现或回归测试；适合自动化的重要行为先验证失败。纯文案/样式等低风险问题采用相应验证方式。
4. 修复根因并保持范围集中。确认测试错误时用证据修正测试；不要削弱正确断言或吞掉错误来消除失败。
5. 运行相关回归检查，再按风险覆盖受影响调用者。将安全与质量审查交给 `project-code-review`，完成证据交给 `project-verification`。
6. 行为、配置或操作说明受影响时使用 `project-docs-update`，避免将临时调试笔记写入长期规范。

## 输出

- 根因及文件/调用链证据；根因未确认时给出当前假设。
- 修复范围、复现与回归结果，以及待验证事项。
- 与当前 OpenSpec change 的关联和发现的规格差异。

Git、子代理和外部环境操作遵守根入口；该流程不包含暂存或提交步骤。
