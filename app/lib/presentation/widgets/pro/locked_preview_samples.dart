import 'package:flutter/material.dart';

import '../../design/design.dart';

/// 잠금 자리별 가운데 한 줄 (스펙 4-1, 화면은 이 상수만 씀)
abstract final class LockedPreviewCaptions {
  static const String explanation = '보기별 해설 · 함정 · 시험 팁';
  static const String executionResult = '보기 SQL을 직접 실행해 결과 비교';
  static const String practiceModes = '토픽 골라 풀기 · 실전 모드 · 약점 추천';
  static const String examTrend = '최근 기출 토픽 비중 · 이번 회차 예상';
  static const String realModeSetting = '실전 모드';
  static const String conceptTopics = '3단원부터 모든 개념과 확인 문제';
}

// 가짜 미리보기: 서버의 잠긴 내용이 아니라 모양만 그럴듯한 고정 예시 (통신을 가로채도 얻을 것이 없게)

/// 선택지 해설 묶음: 정답 근거, 핵심 개념, 헷갈리는 지점, 시험 팁
class ExplanationLockedSample extends StatelessWidget {
  const ExplanationLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(
          title: '정답 근거',
          body: 'GROUP BY 절에 없는 컬럼은 집계 함수 없이 SELECT 에 쓸 수 없어요.',
        ),
        _SampleSection(
          title: '핵심 개념',
          body: 'WHERE 는 그룹으로 묶기 전에, HAVING 은 묶은 뒤에 조건을 걸어요.',
        ),
        _SampleSection(
          title: '헷갈리는 지점',
          body: 'COUNT(*) 는 NULL 도 세고, COUNT(컬럼) 은 NULL 을 빼고 세요.',
        ),
        _SampleSection(title: '시험 팁', body: '보기마다 실행 순서를 한 줄씩 적어 보면 함정이 보여요.'),
      ],
    );
  }
}

/// SQL 실행 결과 표 자리
class ExecutionResultLockedSample extends StatelessWidget {
  const ExecutionResultLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(title: '실행 결과', body: '3개 행이 조회됐어요.'),
        _SampleTable(
          header: ['EMP_NO', 'ENAME', 'SAL'],
          rows: [
            ['7369', 'SMITH', '800'],
            ['7499', 'ALLEN', '1600'],
            ['7521', 'WARD', '1250'],
          ],
        ),
      ],
    );
  }
}

/// 풀기 방식 3종: 토픽 골라 풀기, 실전 모드, 약점 추천
class PracticeModesLockedSample extends StatelessWidget {
  const PracticeModesLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(title: '토픽 골라 풀기', body: '약한 토픽만 골라서 집중해서 풀어요.'),
        _SampleSection(title: '실전 모드', body: '시험처럼 매번 새로운 함정 선택지가 나와요.'),
        _SampleSection(title: '약점 추천', body: '많이 틀린 개념의 문제를 먼저 보여 줘요.'),
      ],
    );
  }
}

/// 출제 경향 본문 전체
class ExamTrendLockedSample extends StatelessWidget {
  const ExamTrendLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(
          title: '최근 기출 토픽 비중',
          body: 'SQL 기본 및 활용 42% · SQL 최적화 기본 원리 18% · 관리 구문 14%',
        ),
        _SampleSection(
          title: '이번 회차 예상',
          body: '윈도우 함수와 계층형 질의가 자주 나올 가능성이 높아요.',
        ),
        _SampleSection(
          title: '자주 나온 개념',
          body: 'GROUP BY 확장, 서브쿼리, 집합 연산자, 트랜잭션',
        ),
      ],
    );
  }
}

/// 개념 학습 잠긴 단원 목록 자리 (#577)
class ConceptTopicsLockedSample extends StatelessWidget {
  const ConceptTopicsLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(title: '3. DDL / DML / TCL', body: '개념 7개 · 데이터 타입, 제약조건, MERGE'),
        _SampleSection(title: '4. SQL 함수', body: '개념 6개 · 문자, 숫자, 날짜, NULL 함수'),
        _SampleSection(title: '5. 조인', body: '개념 6개 · INNER, OUTER, SELF 조인'),
      ],
    );
  }
}

/// 설정의 실전 모드 선택 자리
class RealModeSettingLockedSample extends StatelessWidget {
  const RealModeSettingLockedSample({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SampleCard(
      children: [
        _SampleSection(title: '실전 모드', body: '매번 새로운 함정 선택지로 시험처럼 풀어요.'),
      ],
    );
  }
}

/// 미리보기 바탕 카드
class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PassqlCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) const SizedBox(height: PassqlSpacing.sm),
            children[index],
          ],
        ],
      ),
    );
  }
}

/// 제목 한 줄 + 본문 문단
class _SampleSection extends StatelessWidget {
  const _SampleSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: PassqlTypography.subheadlineSemibold.copyWith(
            color: colors.label,
          ),
        ),
        const SizedBox(height: PassqlSpacing.xxs),
        Text(
          body,
          style: PassqlTypography.subheadline.copyWith(
            color: colors.secondaryLabel,
          ),
        ),
      ],
    );
  }
}

/// 실행 결과 모양의 작은 표
class _SampleTable extends StatelessWidget {
  const _SampleTable({required this.header, required this.rows});

  final List<String> header;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.passqlColors;
    Widget buildRow(List<String> cells, {required bool isHeader}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: PassqlSpacing.xxs),
      child: Row(
        children: [
          for (final cell in cells)
            Expanded(
              child: Text(
                cell,
                style:
                    (isHeader
                            ? PassqlTypography.codeEmphasis
                            : PassqlTypography.codeCompact)
                        .copyWith(color: colors.label),
              ),
            ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.all(PassqlSpacing.xs),
      decoration: BoxDecoration(
        color: colors.fill,
        borderRadius: BorderRadius.circular(PassqlRadius.sm),
      ),
      child: Column(
        children: [
          buildRow(header, isHeader: true),
          for (final row in rows) buildRow(row, isHeader: false),
        ],
      ),
    );
  }
}
