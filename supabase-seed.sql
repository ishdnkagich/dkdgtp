-- 创建用户表（用于存储用户信息）
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    username TEXT,
    role TEXT NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建投票表
CREATE TABLE IF NOT EXISTS votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    deadline TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建投票选项表
CREATE TABLE IF NOT EXISTS vote_options (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    vote_id UUID REFERENCES votes(id) ON DELETE CASCADE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建用户投票记录表
CREATE TABLE IF NOT EXISTS user_votes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    vote_id UUID REFERENCES votes(id) ON DELETE CASCADE NOT NULL,
    option_id UUID REFERENCES vote_options(id) ON DELETE CASCADE NOT NULL,
    voted_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT unique_user_vote UNIQUE (user_id, vote_id)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_active_votes ON votes(is_active);
CREATE INDEX IF NOT EXISTS idx_vote_options ON vote_options(vote_id);
CREATE INDEX IF NOT EXISTS idx_user_votes ON user_votes(user_id, vote_id);

-- 创建管理员用户（仅当不存在时）
INSERT INTO users (id, email, username, role)
SELECT '00000000-0000-0000-0000-000000000000', 'admin@dakunempire.com', 'admin', 'admin'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE id = '00000000-0000-0000-0000-000000000000'
);

-- 创建示例投票（仅当不存在时）
INSERT INTO votes (id, title, description, deadline, is_active, created_by)
SELECT '00000000-0000-0000-0000-000000000001', '帝国首都选址投票', '请为帝国新首都选择最佳位置', NOW() + INTERVAL '7 days', true, '00000000-0000-0000-0000-000000000000'
WHERE NOT EXISTS (
    SELECT 1 FROM votes WHERE id = '00000000-0000-0000-0000-000000000001'
);

-- 创建投票选项（仅当投票存在且选项不存在时）
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM votes WHERE id = '00000000-0000-0000-0000-000000000001') THEN
        INSERT INTO vote_options (id, vote_id, name, description)
        SELECT 
            gen_random_uuid(), 
            '00000000-0000-0000-0000-000000000001', 
            '北京', 
            '历史悠久的古都'
        WHERE NOT EXISTS (
            SELECT 1 FROM vote_options 
            WHERE vote_id = '00000000-0000-0000-0000-000000000001' AND name = '北京'
        );
        
        INSERT INTO vote_options (id, vote_id, name, description)
        SELECT 
            gen_random_uuid(), 
            '00000000-0000-0000-0000-000000000001', 
            '上海', 
            '现代化国际大都市'
        WHERE NOT EXISTS (
            SELECT 1 FROM vote_options 
            WHERE vote_id = '00000000-0000-0000-0000-000000000001' AND name = '上海'
        );
        
        INSERT INTO vote_options (id, vote_id, name, description)
        SELECT 
            gen_random_uuid(), 
            '00000000-0000-0000-0000-000000000001', 
            '西安', 
            '中华文明发源地'
        WHERE NOT EXISTS (
            SELECT 1 FROM vote_options 
            WHERE vote_id = '00000000-0000-0000-0000-000000000001' AND name = '西安'
        );
    END IF;
END $$;