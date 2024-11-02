part of 'test_cubit.dart';

@immutable
sealed class TestState {}

final class TestLoading extends TestState {}

final class TestData extends TestState {
  TestData();
}
