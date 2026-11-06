使用方式：

```bash
cd /Users/donson/Desktop/project-spec

bash ./init-project.sh /你的业务项目绝对路径
```

技术栈支持输入编号，多个编号用空格分隔；“跳过”只能单独选择。输入为空、编号无效或格式错误时，会提示重新选择当前项，不会保留本次输入中的部分选择。y/n 确认输入无效时也会重新询问。

Skills 固定使用“复制两份”，不再询问入口处理方式。完整流程正文分别保存在 `.agents/skills/` 和 `.claude/skills/`；重新初始化时，原有的目录符号链接或引用入口会转换为完整副本。

模板内置 Matt Pocock 上游原版 `grill-me` 和 `grilling`，随初始化脚本分发到业务项目，无需安装完整上游插件。两个 Skill 的 `SKILL.md` 保持上游原文；项目的自动触发条件与 OpenSpec 衔接统一放在 `AGENTS.md`。需求目标、范围、业务规则或验收标准存在影响实施的关键歧义，且无法从项目资料自行消除时，Agent 按入口规则自动调用 `grilling`，依照上游流程逐轮澄清。

日常使用流程：提出需求 → 自动触发澄清 → 确认共同理解 → 用户手动发起 OpenSpec proposal，复用已确认的结论。独立澄清会话不会自动创建或修改 OpenSpec 变更，也不会自动开始实施。如果已在用户发起的 OpenSpec 流程中，遇到歧义时澄清并确认后继续当前流程，无需再次发起 proposal。明确的小改动和已有完整规格的任务直接处理。

例如“做一个审批功能”通常需要先澄清；“把保存按钮改成提交”或“按这个已确定的 change 实施”不需要重新访谈。也可以手动调用：Codex 使用 `$grill-me`，Claude Code 使用 `/grill-me`，该入口会调用 `grilling`。自动选择由 Agent 根据上下文判断，并非固定关键词开关。

Skill 源文件位于 `base/.agents/skills/grill-me/` 和 `base/.agents/skills/grilling/`，`base/.claude/skills/` 下同名目录保持完整副本。固定上游 commit `4ae2317ddb22b046e26455e4f9c9b3aaaf62212d`：[grill-me 原文](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/grill-me/SKILL.md)、[grilling 原文](https://github.com/mattpocock/skills/blob/4ae2317ddb22b046e26455e4f9c9b3aaaf62212d/skills/productivity/grilling/SKILL.md)。每个 Skill 目录附带上游 MIT 许可证；升级应审查固定版本差异。

这里的 `base/` 是分发模板，并不会仅因文件存在就让当前模板仓库会话加载 Skill；业务项目需运行上面的初始化命令，已有项目更新时注意脚本会覆盖模板配置并核对已有自定义内容。若新 Skill 未出现在工具的技能列表中，刷新或重启会话。

模板同时内置前端 Skill `frontend-design`，在 `base/.agents/skills/` 和 `base/.claude/skills/` 保存完整副本，随初始化脚本分发，`SKILL.md` 保持上游原文：

| Skill | 自动触发条件 | 固定上游版本 |
| --- | --- | --- |
| `frontend-design` | 创建或重新设计页面、组件、布局及视觉样式 | [anthropics/skills · ca45fc4](https://github.com/anthropics/skills/tree/ca45fc496a3436251f191354091d557da31c15b5/skills/frontend-design) |

`frontend-design` 附带上游 `LICENSE.txt`。项目触发条件统一维护在 `base/AGENTS.md`；前端设计遵循业务项目已有设计系统和已确认需求。升级时审查上游差异，并同步更新两份副本及此处版本链接。

已有 `openspec/config.yaml` 时，初始化的“合并示例配置”请选择 `n`，再把示例中新增的 `grilling` context 和 apply guidance 手动合入原有对应位置。现有脚本采用整份追加，可能产生重复顶层键；不要直接追加整个示例。

脚本不再询问“生成合并的规则快速参考”和“简化重复的 Git 约束描述”，两项固定为 n：不生成快速参考，保留完整 Git 约束。

运行回归测试（需要 Python 3）：

```bash
python3 -m unittest discover -s tests -v
```
