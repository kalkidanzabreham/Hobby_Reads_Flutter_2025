import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hobby_reads_flutter/data/model/connection_model.dart';
import 'package:hobby_reads_flutter/data/repository/connection_repository.dart';
import 'package:hobby_reads_flutter/providers/api_providers.dart';
import 'package:hobby_reads_flutter/providers/auth_providers.dart';

// My Connections State
class MyConnectionsState {
  final List<ConnectionModel> connections;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const MyConnectionsState({
    this.connections = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  MyConnectionsState copyWith({
    List<ConnectionModel>? connections,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return MyConnectionsState(
      connections: connections ?? this.connections,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class MyConnectionsNotifier extends StateNotifier<MyConnectionsState> {
  final ConnectionRepository _connectionRepository;
  final Ref _ref;

  MyConnectionsNotifier(this._connectionRepository, this._ref) : super(const MyConnectionsState()) {
    // Listen to auth state changes and reload data when user changes
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        if (next.isAuthenticated) {
          loadConnections();
        } else {
          state = const MyConnectionsState();
        }
      }
    });
  }

  Future<void> loadConnections() async {
    // Only load if user is authenticated
    if (!_ref.read(isAuthenticatedProvider)) {
      state = const MyConnectionsState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final connections = await _connectionRepository.getConnections();
      state = MyConnectionsState(
        connections: connections,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> removeConnection(String connectionId) async {
    try {
      await _connectionRepository.removeConnection(connectionId);
      
      // Remove the connection from the local state
      final updatedConnections = state.connections
          .where((conn) => conn.id != connectionId)
          .toList();
      
      state = state.copyWith(
        connections: updatedConnections,
        successMessage: 'Connection removed successfully',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Pending Requests State
class PendingRequestsState {
  final List<ConnectionModel> requests;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const PendingRequestsState({
    this.requests = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  PendingRequestsState copyWith({
    List<ConnectionModel>? requests,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return PendingRequestsState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

class PendingRequestsNotifier extends StateNotifier<PendingRequestsState> {
  final ConnectionRepository _connectionRepository;
  final Ref _ref;

  PendingRequestsNotifier(this._connectionRepository, this._ref) : super(const PendingRequestsState()) {
    // Listen to auth state changes and reload data when user changes
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        if (next.isAuthenticated) {
          loadPendingRequests();
        } else {
          state = const PendingRequestsState();
        }
      }
    });
  }

  Future<void> loadPendingRequests() async {
    // Only load if user is authenticated
    if (!_ref.read(isAuthenticatedProvider)) {
      state = const PendingRequestsState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final requests = await _connectionRepository.getPendingRequests();
      state = PendingRequestsState(
        requests: requests,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      await _connectionRepository.respondToRequest(
        requestId: requestId,
        accept: true,
      );
      
      // Remove the request from pending list
      final updatedRequests = state.requests
          .where((req) => req.id != requestId)
          .toList();
      
      state = state.copyWith(
        requests: updatedRequests,
        successMessage: 'Connection request accepted',
      );
      
      // Refresh the connections list to show the new connection
      _ref.read(myConnectionsProvider.notifier).loadConnections();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rejectRequest(String requestId) async {
    try {
      await _connectionRepository.respondToRequest(
        requestId: requestId,
        accept: false,
      );
      
      // Remove the request from pending list
      final updatedRequests = state.requests
          .where((req) => req.id != requestId)
          .toList();
      
      state = state.copyWith(
        requests: updatedRequests,
        successMessage: 'Connection request rejected',
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Suggested Connections State
class SuggestedConnectionsState {
  final List<ConnectionModel> suggestions;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final Map<String, bool> connectingStates; // Track loading states per user

  const SuggestedConnectionsState({
    this.suggestions = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.connectingStates = const {},
  });

  SuggestedConnectionsState copyWith({
    List<ConnectionModel>? suggestions,
    bool? isLoading,
    String? error,
    String? successMessage,
    Map<String, bool>? connectingStates,
  }) {
    return SuggestedConnectionsState(
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
      connectingStates: connectingStates ?? this.connectingStates,
    );
  }
}

class SuggestedConnectionsNotifier extends StateNotifier<SuggestedConnectionsState> {
  final ConnectionRepository _connectionRepository;
  final Ref _ref;

  SuggestedConnectionsNotifier(this._connectionRepository, this._ref) : super(const SuggestedConnectionsState()) {
    // Listen to auth state changes and reload data when user changes
    _ref.listen(authProvider, (previous, next) {
      if (previous?.user?.id != next.user?.id) {
        if (next.isAuthenticated) {
          loadSuggestions();
        } else {
          state = const SuggestedConnectionsState();
        }
      }
    });
  }

  Future<void> loadSuggestions() async {
    // Only load if user is authenticated
    if (!_ref.read(isAuthenticatedProvider)) {
      state = const SuggestedConnectionsState();
      return;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);

    try {
      final suggestions = await _connectionRepository.getConnectionSuggestions();
      state = SuggestedConnectionsState(
        suggestions: suggestions,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> sendConnectionRequest(String userId) async {
    // Set loading state for this specific user
    final updatedStates = Map<String, bool>.from(state.connectingStates);
    updatedStates[userId] = true;
    state = state.copyWith(connectingStates: updatedStates);

    try {
      await _connectionRepository.sendConnectionRequest(userId);
      
      // Remove the user from suggestions after sending request
      final updatedSuggestions = state.suggestions
          .where((suggestion) => suggestion.userId != userId)
          .toList();
      
      // Remove loading state
      updatedStates.remove(userId);
      
      state = state.copyWith(
        suggestions: updatedSuggestions,
        connectingStates: updatedStates,
        successMessage: 'Connection request sent successfully',
      );
    } catch (e) {
      // Remove loading state on error
      updatedStates.remove(userId);
      state = state.copyWith(
        connectingStates: updatedStates,
        error: e.toString(),
      );
    }
  }

  bool isConnecting(String userId) {
    return state.connectingStates[userId] ?? false;
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}

// Providers with auth dependency
final myConnectionsProvider = StateNotifierProvider<MyConnectionsNotifier, MyConnectionsState>((ref) {
  final connectionRepository = ref.watch(connectionRepositoryProvider);
  final notifier = MyConnectionsNotifier(connectionRepository, ref);
  
  // Auto-load when provider is first created and user is authenticated
  if (ref.read(isAuthenticatedProvider)) {
    notifier.loadConnections();
  }
  
  return notifier;
});

final pendingRequestsProvider = StateNotifierProvider<PendingRequestsNotifier, PendingRequestsState>((ref) {
  final connectionRepository = ref.watch(connectionRepositoryProvider);
  final notifier = PendingRequestsNotifier(connectionRepository, ref);
  
  // Auto-load when provider is first created and user is authenticated
  if (ref.read(isAuthenticatedProvider)) {
    notifier.loadPendingRequests();
  }
  
  return notifier;
});

final suggestedConnectionsProvider = StateNotifierProvider<SuggestedConnectionsNotifier, SuggestedConnectionsState>((ref) {
  final connectionRepository = ref.watch(connectionRepositoryProvider);
  final notifier = SuggestedConnectionsNotifier(connectionRepository, ref);
  
  // Auto-load when provider is first created and user is authenticated
  if (ref.read(isAuthenticatedProvider)) {
    notifier.loadSuggestions();
  }
  
  return notifier;
});

// Simple providers for quick access
final connectionsCountProvider = Provider<int>((ref) {
  final connectionsState = ref.watch(myConnectionsProvider);
  return connectionsState.connections.length;
});

final pendingRequestsCountProvider = Provider<int>((ref) {
  final pendingState = ref.watch(pendingRequestsProvider);
  return pendingState.requests.length;
});

// Connection status provider
final connectionStatusProvider = FutureProvider.family<String, String>((ref, userId) async {
  final connectionRepository = ref.watch(connectionRepositoryProvider);
  return await connectionRepository.getConnectionStatus(userId);
});

// Check if connected provider
final isConnectedProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final connectionRepository = ref.watch(connectionRepositoryProvider);
  return await connectionRepository.isConnected(userId);
});

// Global refresh function provider
final connectionRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(myConnectionsProvider);
    ref.invalidate(pendingRequestsProvider);
    ref.invalidate(suggestedConnectionsProvider);
  };
}); 