使用方式：

```bash
cd /Users/donson/Desktop/project-spec

bash ./init-project.sh /你的业务项目绝对路径
```

技术栈支持输入编号，多个编号用空格分隔；“跳过”只能单独选择。输入为空、编号无效或格式错误时，会提示重新选择当前项，不会保留本次输入中的部分选择。y/n 确认输入无效时也会重新询问。

Skills 固定使用“复制两份”，不再询问入口处理方式。完整流程正文分别保存在 `.agents/skills/` 和 `.claude/skills/`；重新初始化时，原有的目录符号链接或引用入口会转换为完整副本。

脚本不再询问“生成合并的规则快速参考”和“简化重复的 Git 约束描述”，两项固定为 n：不生成快速参考，保留完整 Git 约束。

运行回归测试（需要 Python 3）：

```bash
python3 -m unittest discover -s tests -v
```
