import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/auth/data/secure_credential_cache.dart';

final secureCredentialCacheProvider = Provider<SecureCredentialCache>(
  (_) => SecureCredentialCache(),
);
