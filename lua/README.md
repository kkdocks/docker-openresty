# 配置文件说明

### blacklist

- refresh_at 共享内存中的黑名单列表同步redis的时间(默认10分钟)

- expire_at  缓存在redis中的黑名单的失效时间(默认7天, 失效后该ip将变成白名单)

### ip404count

- expire_at 404统计ip计数失效时间(默认60秒)

- trigger_forbidden_count 404的次数触发黑名单封禁的次数(默认60秒内404次数达到10次直接拉黑)
