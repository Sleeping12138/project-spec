使用方式：

```bash
cd /Users/donson/Desktop/project-spec

bash ./init-project.sh /你的业务项目绝对路径
```

技术栈支持输入编号，多个编号用空格分隔；“跳过”只能单独选择。输入为空、编号无效或格式错误时，会提示重新选择当前项，不会保留本次输入中的部分选择。y/n 确认输入无效时也会重新询问。

Skills 固定使用“复制两份”，不再询问入口处理方式。完整流程正文分别保存在 `.agents/skills/` 和 `.claude/skills/`；重新初始化时，原有的目录符号链接或引用入口会转换为完整副本。

模板内置项目适配版 `grill-me`，随初始化脚本分发到业务项目，无需安装完整上游插件。需求目标、范围、业务规则或验收标准存在影响实施的关键歧义时，Agent 按 `AGENTS.md` 和 Skill 描述自动选择：先读项目与现有 OpenSpec，再逐轮提问，每轮优先解决 1–3 个关键问题。目标、关键行为和验收标准明确后，继续当前 OpenSpec 流程。明确的小改动和已有完整规格的任务直接处理。

例如“做一个审批功能”通常需要先澄清；“把保存按钮改成提交”或“按这个已确定的 change 实施”不需要重新访谈。也可以手动调用：Codex 使用 `$grill-me`，Claude Code 使用 `/grill-me`。自动选择由 Agent 根据上下文判断，并非固定关键词开关。

Skill 源文件位于 `base/.agents/skills/grill-me/`，`base/.claude/skills/grill-me/` 保持完整副本。这里的 `base/` 是分发模板，并不会仅因文件存在就让当前模板仓库会话加载 Skill；业务项目需运行上面的初始化命令，已有项目更新时注意脚本会覆盖模板配置并核对已有自定义内容。若新 Skill 未出现在工具的技能列表中，刷新或重启会话。上游版本、适配说明和 MIT 许可证随 Skill 一起分发；升级应审查固定版本差异。

已有 `openspec/config.yaml` 时，初始化的“合并示例配置”请选择 `n`，再把示例中新增的 `grill-me` context 和 apply guidance 手动合入原有对应位置。现有脚本采用整份追加，可能产生重复顶层键；不要直接追加整个示例。

脚本不再询问“生成合并的规则快速参考”和“简化重复的 Git 约束描述”，两项固定为 n：不生成快速参考，保留完整 Git 约束。

运行回归测试（需要 Python 3）：

```bash
python3 -m unittest discover -s tests -v
```
