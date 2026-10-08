-- ========================================================
-- 노인일자리 활동일지 스마트 관리 도구 - Supabase 테이블 스키마
-- Supabase 대시보드 > SQL Editor 에서 아래 쿼리를 실행하세요.
-- ========================================================

-- 1. 활동일지 테이블 생성
CREATE TABLE IF NOT EXISTS public.activity_logs (
    id TEXT PRIMARY KEY,                          -- 예: 2026-09-29-공원환경관리-김영희
    date DATE NOT NULL DEFAULT CURRENT_DATE,      -- 활동 일자 (YYYY-MM-DD)
    program_type TEXT NOT NULL DEFAULT '공익활동형', -- 사업 구분 (공익활동형 / 역량활동형)
    group_name TEXT NOT NULL,                     -- 사업단명 (공원환경관리, 학교급식 등)
    name TEXT NOT NULL,                           -- 참여 어르신 성함
    status TEXT NOT NULL DEFAULT '담당자 확인 중',  -- 상태 ('담당자 확인 중' 또는 '확인 완료')
    hours NUMERIC NOT NULL DEFAULT 3,             -- 인정 시간 (기본 3시간)
    time_range TEXT DEFAULT '09:00 ~ 12:00',      -- 활동 시간대
    activity_items JSONB DEFAULT '[]'::jsonb,     -- 활동 체크 항목 배열
    health_condition TEXT DEFAULT '양호',         -- 건강 상태 ('양호', '보통', '불편/피로')
    note TEXT DEFAULT '',                         -- 특이사항 및 메모
    reviewer TEXT DEFAULT '',                     -- 확인 담당자 이름
    reviewed_at TEXT DEFAULT '',                  -- 확인 완료 일시
    created_at TIMESTAMPTZ DEFAULT NOW(),         -- 작성 일시
    updated_at TIMESTAMPTZ DEFAULT NOW()          -- 수정 일시
);

-- 2. 검색 및 필터링 성능을 위한 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_activity_logs_date ON public.activity_logs (date DESC);
CREATE INDEX IF NOT EXISTS idx_activity_logs_group ON public.activity_logs (group_name);
CREATE INDEX IF NOT EXISTS idx_activity_logs_status ON public.activity_logs (status);
CREATE INDEX IF NOT EXISTS idx_activity_logs_name ON public.activity_logs (name);

-- 3. Row Level Security (RLS) 활성화 및 누구나 읽고 쓸 수 있는 공개 정책 부여 (익명 작성/관리용)
ALTER TABLE public.activity_logs ENABLE ROW LEVEL SECURITY;

-- 모든 사용자(어르신 및 담당자)가 일지를 조회할 수 있도록 허용
CREATE POLICY "Allow public select on activity_logs" 
ON public.activity_logs 
FOR SELECT 
USING (true);

-- 모든 사용자(어르신)가 일지를 등록/작성할 수 있도록 허용
CREATE POLICY "Allow public insert on activity_logs" 
ON public.activity_logs 
FOR INSERT 
WITH CHECK (true);

-- 모든 사용자(담당자)가 일지를 수정할 수 있도록 허용
CREATE POLICY "Allow public update on activity_logs" 
ON public.activity_logs 
FOR UPDATE 
USING (true);

-- 모든 사용자(담당자)가 일지를 삭제할 수 있도록 허용
CREATE POLICY "Allow public delete on activity_logs" 
ON public.activity_logs 
FOR DELETE 
USING (true);

-- 4. 실시간 동기화(Realtime) 활성화
ALTER PUBLICATION supabase_realtime ADD TABLE public.activity_logs;
