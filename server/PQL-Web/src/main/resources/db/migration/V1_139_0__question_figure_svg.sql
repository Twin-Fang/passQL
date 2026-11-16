-- =============================================================================
-- V1_139_0: 문제 그림 (#1132)
-- figure_svg: 지문 아래 그림 SVG 원문 (ERD 등, 없으면 NULL). 검사는 QuestionFigureSvgRule
-- =============================================================================
ALTER TABLE question ADD COLUMN IF NOT EXISTS figure_svg TEXT;
