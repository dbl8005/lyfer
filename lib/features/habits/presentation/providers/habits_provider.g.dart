// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$habitsStreamHash() => r'6f87c25e4c47de72918184579f5a1e3621ef2ddb';

/// See also [habitsStream].
@ProviderFor(habitsStream)
final habitsStreamProvider =
    AutoDisposeStreamProvider<List<HabitModel>>.internal(
  habitsStream,
  name: r'habitsStreamProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$habitsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HabitsStreamRef = AutoDisposeStreamProviderRef<List<HabitModel>>;
String _$habitsRepositoryHash() => r'2b69d680a460fa34b332e59b0c2d3d6f9838f90f';

/// See also [HabitsRepository].
@ProviderFor(HabitsRepository)
final habitsRepositoryProvider =
    AutoDisposeNotifierProvider<HabitsRepository, HabitRepository>.internal(
  HabitsRepository.new,
  name: r'habitsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$habitsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$HabitsRepository = AutoDisposeNotifier<HabitRepository>;
String _$selectedDateHash() => r'8b2edf535e845e65028edfc4481edc051efec67a';

/// See also [SelectedDate].
@ProviderFor(SelectedDate)
final selectedDateProvider =
    AutoDisposeNotifierProvider<SelectedDate, DateTime>.internal(
  SelectedDate.new,
  name: r'selectedDateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$selectedDateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SelectedDate = AutoDisposeNotifier<DateTime>;
String _$currentSectionHash() => r'2e41b48d63a8ed2dc8972547cec51a1eb4f6c0c2';

/// See also [CurrentSection].
@ProviderFor(CurrentSection)
final currentSectionProvider =
    AutoDisposeNotifierProvider<CurrentSection, DaySection>.internal(
  CurrentSection.new,
  name: r'currentSectionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentSectionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$CurrentSection = AutoDisposeNotifier<DaySection>;
String _$groupedHabitsHash() => r'e3cf18053327dded747e6e7d86d5971d6e45853e';

/// See also [GroupedHabits].
@ProviderFor(GroupedHabits)
final groupedHabitsProvider = AutoDisposeNotifierProvider<GroupedHabits,
    Map<DaySection, List<HabitModel>>>.internal(
  GroupedHabits.new,
  name: r'groupedHabitsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupedHabitsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GroupedHabits
    = AutoDisposeNotifier<Map<DaySection, List<HabitModel>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
