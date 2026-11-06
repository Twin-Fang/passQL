package com.passql.submission.service;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.TreeMap;
import java.util.UUID;

/**
 * 자동 구성 문제 고르기 (순수): 최근 회차에 안 쓴 문제 우선 > 난이도 묶음을 번갈아 뽑기 (묶음 안 무작위)
 * 한 토픽이 쉬운 문제로만 채워지지 않게
 */
public final class MockExamQuestionPicker {

    private MockExamQuestionPicker() {
    }

    /** 후보 문제 (difficulty 는 question.difficulty) */
    public record Candidate(UUID questionUuid, int difficulty, boolean isRecentlyUsed) {
    }

    /** 후보 > 최대 count 개 (후보가 모자라면 있는 만큼) */
    public static List<UUID> pick(List<Candidate> candidates, int count, Random random) {
        List<Candidate> freshCandidates = candidates.stream().filter(candidate -> !candidate.isRecentlyUsed()).toList();
        List<Candidate> recentCandidates = candidates.stream().filter(Candidate::isRecentlyUsed).toList();

        List<UUID> pickedQuestionUuids = new ArrayList<>();
        for (UUID questionUuid : interleaveByDifficulty(freshCandidates, random)) {
            if (pickedQuestionUuids.size() >= count) {
                return pickedQuestionUuids;
            }
            pickedQuestionUuids.add(questionUuid);
        }
        // 모자라면 최근 회차 문제로 채움
        for (UUID questionUuid : interleaveByDifficulty(recentCandidates, random)) {
            if (pickedQuestionUuids.size() >= count) {
                break;
            }
            pickedQuestionUuids.add(questionUuid);
        }
        return pickedQuestionUuids;
    }

    /** 난이도별 묶음 섞기 > 쉬운 묶음부터 한 개씩 번갈아 */
    private static List<UUID> interleaveByDifficulty(List<Candidate> candidates, Random random) {
        Map<Integer, List<UUID>> questionUuidsByDifficulty = new TreeMap<>();
        for (Candidate candidate : candidates) {
            questionUuidsByDifficulty.computeIfAbsent(candidate.difficulty(), difficulty -> new ArrayList<>())
                .add(candidate.questionUuid());
        }
        List<List<UUID>> shuffledGroups = new ArrayList<>();
        for (List<UUID> group : questionUuidsByDifficulty.values()) {
            Collections.shuffle(group, random);
            shuffledGroups.add(group);
        }

        List<UUID> interleaved = new ArrayList<>();
        for (int position = 0; interleaved.size() < candidates.size(); position++) {
            for (List<UUID> group : shuffledGroups) {
                if (position < group.size()) {
                    interleaved.add(group.get(position));
                }
            }
        }
        return interleaved;
    }
}
