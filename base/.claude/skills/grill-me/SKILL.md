---
name: grill-me
description: Use when requirements, goals, scope, business rules, or acceptance criteria contain unresolved decisions that materially affect implementation, or when the user explicitly requests grilling or a requirements interview. 不明确的需求、方案取舍、验收标准需要澄清时使用；明确的小改动和已有完整规格的任务直接处理。
license: MIT
---

# 需求澄清与方案追问

通过逐轮追问形成可实施、可验证的共同理解。先查事实，再问需要用户决定的取舍；不把每个任务都变成访谈。

## 触发与输入

- 自动触发：目标、范围、业务规则或验收标准存在会改变实现的关键歧义，例如“做个审批功能”“优化导出体验”，且项目资料和当前对话无法消除歧义。
- 手动触发：用户要求 `grill-me`、需求访谈、反复追问或检验方案。
- 已明确的局部修改、有完整 OpenSpec change 的实施、事实查询和普通故障排查直接沿用相应流程；排查中出现真正的业务决策缺口时再进入澄清。

读取根 `AGENTS.md`、相关实现及已有 OpenSpec change。把问题区分为已知事实、已确定决策、待决问题；对已由用户回答或规格确定的内容直接复用。

## 逐轮追问

1. 将待决问题按依赖关系组织：先目标和范围，再关键行为、边界与验收。只讨论当前任务相关分支。
2. 每轮优先询问当前可以独立回答的 1–3 个关键问题；依赖尚未回答问题的选项留到下一轮。每个问题说明影响，并在有依据时给出推荐答案及取舍。推荐必须标为建议，不能当成用户已经选择。
3. 项目中能查到的框架、接口、现状和约束自行调查；用户决定业务目标与取舍。必要时按根入口约束委派事实调查，普通读取直接完成。
4. 等待本轮回答后更新待决问题，再追问被解锁的问题。等待期间可以继续不依赖答案的调查，相关实施等待答案；经过一段时间没有回复不代表同意。

示例：用户说“导出不好用”。先检查当前实现；如果已知只有 CSV 导出，就问“最需要解决的是导出内容不全，还是下载操作麻烦？这会决定改数据查询还是交互。根据当前操作路径，我建议先简化下载步骤。”明确问题后，再讨论它所需的行为与验收，不提前假设需要 Excel、异步任务或邮件通知。

## 收敛与 OpenSpec 衔接

- 当目标、范围、关键行为和可验证的验收标准足以指导当前任务时结束追问。实现细节可按项目惯例决定，不为穷尽所有可能性增加问题。
- 汇总已确定的需求、非目标、验收标准和仍待决定的事项。只有尚未获得认可的需求取舍需要确认；用户已明确回答或认可的结论不再重复确认。
- 用户明确授权自行决定的部分，说明采用的假设后按授权推进；仍需用户回答的关键业务问题保持待决。
- 结论衔接当前 OpenSpec 流程，复用已有 proposal、specs、design、tasks；没有 change 时依用户任务进入原生流程。Skill 本身不另建规划体系，也不自动创建或归档 change。
- 实施中若发现新歧义，只重开受影响的分支。Git 操作、外部发布和授权边界遵守根入口。

## 来源与适配

改编自 Matt Pocock 的 [grill-me](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/grill-me/SKILL.md) 与 [grilling](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/grilling/SKILL.md)，固定上游 commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`，许可证见 [LICENSE](LICENSE)。

本地将入口和追问正文合并为独立 Skill，启用自动匹配，限制每轮问题数量，并适配 OpenSpec、按需调查和已有授权的复用。无需安装完整插件或另一个 `grilling` Skill。
