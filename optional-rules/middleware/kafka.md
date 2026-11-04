# Kafka 可选规则

## 适用范围

- 仅在项目使用 Apache Kafka 时启用；先确认 Kafka 版本、客户端版本和部署方式。

## 约束

- Producer 配置 acks、retries、幂等性，确保消息可靠投递。
- Consumer 配置合适的 group.id、auto.offset.reset、enable.auto.commit。
- 消息处理需要考虑幂等性，避免重复消费导致副作用。
- 分区策略明确，key 的选择影响消息顺序和分布。
- 错误处理区分可重试和不可重试错误，使用死信队列处理失败消息。
- 监控消费者 lag、生产者指标和 broker 健康状态。

## 验证

- 验证消息投递、消费、重试和死信队列场景。
- 测试 consumer rebalance 和故障恢复。
