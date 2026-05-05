import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/domain_cache_invalidation.dart';

/// Listens for Supabase Realtime **broadcast** events on `app-sync-{userId}`.
/// Backend should publish `{ "event": "invalidate", "payload": { "scopes": ["notifications"] } }`
/// (or `scope` as a single string). Optional until the server publishes.
class RealtimeSyncListener extends ConsumerStatefulWidget {
  const RealtimeSyncListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<RealtimeSyncListener> createState() =>
      _RealtimeSyncListenerState();
}

class _RealtimeSyncListenerState extends ConsumerState<RealtimeSyncListener> {
  RealtimeChannel? _channel;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      _bindChannel(data.session?.user.id);
    });
    _bindChannel(Supabase.instance.client.auth.currentSession?.user.id);
  }

  @override
  void dispose() {
    _detachChannel();
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> _detachChannel() async {
    final c = _channel;
    _channel = null;
    if (c != null) {
      await Supabase.instance.client.removeChannel(c);
    }
  }

  Future<void> _bindChannel(String? userId) async {
    await _detachChannel();
    if (userId == null) return;

    final client = Supabase.instance.client;
    final ch = client.channel('app-sync-$userId');

    ch.onBroadcast(
      event: 'invalidate',
      callback: (payload) {
        if (!mounted) return;
        final scopes = _parseScopes(payload);
        if (scopes.isEmpty) return;
        applyClientRealtimeScopes(ref, scopes);
      },
    );

    ch.subscribe();
    _channel = ch;
  }

  static Set<String> _parseScopes(Map<String, dynamic> payload) {
    final out = <String>{};
    final direct = payload['scope'];
    if (direct is String) out.add(direct);
    final list = payload['scopes'];
    if (list is List) {
      for (final e in list) {
        if (e is String) out.add(e);
      }
    }
    final nested = payload['payload'];
    if (nested is Map<String, dynamic>) {
      out.addAll(_parseScopes(nested));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
