import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';

class WorkerProfileModel {
  const WorkerProfileModel({
    required this.id,
    required this.userId,
    required this.rating,
    required this.available,
    required this.shelterCertified,
    this.skills = const [],
    this.name,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String userId;
  final double rating;
  final bool available;
  final bool shelterCertified;
  final List<String> skills;
  final String? name;
  final String? email;
  final String? avatarUrl;

  factory WorkerProfileModel.fromJson(Map<String, dynamic> json) =>
      WorkerProfileModel(
        id: json['id'] as String,
        userId: json['userId'] as String? ?? '',
        rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
        available: json['available'] as bool? ?? true,
        shelterCertified: json['shelterCertified'] as bool? ?? false,
        skills: (json['skills'] as List<dynamic>? ?? [])
            .map((s) => s.toString())
            .toList(),
        name: json['user']?['name'] as String?,
        email: json['user']?['email'] as String?,
        avatarUrl: json['user']?['avatarUrl'] as String?,
      );

  WorkerProfileModel copyWith({
    bool? available,
    List<String>? skills,
    String? avatarUrl,
  }) =>
      WorkerProfileModel(
        id: id,
        userId: userId,
        rating: rating,
        available: available ?? this.available,
        shelterCertified: shelterCertified,
        skills: skills ?? this.skills,
        name: name,
        email: email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
      );
}

final workerProfileProvider = FutureProvider<WorkerProfileModel?>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get(ApiEndpoints.workerMe);
    return WorkerProfileModel.fromJson(res.data as Map<String, dynamic>);
  } catch (_) {
    return null;
  }
});

class WorkerProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> toggleAvailability(bool available) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.patch(
        ApiEndpoints.workerMe,
        data: {'available': available},
      );
      ref.invalidate(workerProfileProvider);
    });
  }

  Future<void> updateSkills(List<String> skills) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(apiClientProvider);
      await api.dio.patch(
        ApiEndpoints.workerMe,
        data: {'skills': skills},
      );
      ref.invalidate(workerProfileProvider);
    });
  }
}

final workerProfileNotifierProvider =
    AsyncNotifierProvider<WorkerProfileNotifier, void>(WorkerProfileNotifier.new);

class PredefinedSkill {
  const PredefinedSkill({required this.id, required this.name, required this.label});
  final String id;
  final String name;
  final String label;

  factory PredefinedSkill.fromJson(Map<String, dynamic> json) => PredefinedSkill(
        id: json['id'] as String,
        name: json['name'] as String,
        label: json['label'] as String,
      );
}

final predefinedSkillsProvider =
    FutureProvider<List<PredefinedSkill>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.dio.get(ApiEndpoints.skills);
    final list = res.data as List<dynamic>;
    return list.map((e) => PredefinedSkill.fromJson(e as Map<String, dynamic>)).toList();
  } catch (_) {
    return [];
  }
});
