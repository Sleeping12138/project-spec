# Claude Code 项目入口

共享项目规范如下，请先读取并遵守：

@AGENTS.md

按其中的规则导航和触发条件读取具体文档。`.agents/skills/` 与 `.claude/skills/` 均保存 Skill 副本，包括上游原版 `grill-me`、`grilling` 和实施支持 `project-*`。需求存在影响实施的关键歧义时按共享入口自动使用 `grilling`；`grill-me` 保留为手动入口。独立澄清结束后等待用户手动发起 OpenSpec proposal；OpenSpec 命令继续使用初始化生成的入口。
