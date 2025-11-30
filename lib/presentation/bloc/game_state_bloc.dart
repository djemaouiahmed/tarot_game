import 'package:equatable/equatable.dart';
import '../../domain/entities/game_state.dart';

abstract class GameBlocState extends Equatable {
  const GameBlocState();

  @override
  List<Object?> get props => [];
}

class GameInitial extends GameBlocState {
  const GameInitial();
}

class GameLoading extends GameBlocState {
  const GameLoading();
}

class GameLoaded extends GameBlocState {
  final GameState gameState;

  const GameLoaded(this.gameState);

  @override
  List<Object?> get props => [gameState];
}

class GameError extends GameBlocState {
  final String message;

  const GameError(this.message);

  @override
  List<Object> get props => [message];
}

class BotTurnState extends GameBlocState {
  final GameState gameState;
  final String action;
  final Duration delay;

  const BotTurnState({
    required this.gameState,
    required this.action,
    required this.delay,
  });

  @override
  List<Object> get props => [gameState, action, delay];
}
