import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_client.dart';
import '../data/user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.read(supabaseProvider));
});

final currentProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.read(userRepositoryProvider).getProfile();
});

final currentVisitorProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.read(userRepositoryProvider).getVisitorByUser();
});
