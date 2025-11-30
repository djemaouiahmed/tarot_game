import '../../domain/entities/card.dart' as game_card;
import '../../domain/entities/bot_difficulty.dart';

abstract class GameEvent {}

class StartGameEvent extends GameEvent {
  final int numberOfPlayers;
  final BotDifficulty difficulty;
  final int initialCards;

  StartGameEvent(
    this.numberOfPlayers, {
    this.difficulty = BotDifficulty.medium,
    this.initialCards = 5,
  });
}

class ReviewHandEvent extends GameEvent {}

class StartBiddingEvent extends GameEvent {}

class MakeBidEvent extends GameEvent {
  final int bid;
  MakeBidEvent(this.bid);
}

class PlayCardEvent extends GameEvent {
  final game_card.Card card;
  PlayCardEvent(this.card);
}

class NextRoundEvent extends GameEvent {}

class RestartGameEvent extends GameEvent {}

class BotTurnEvent extends GameEvent {}

class AnimationCompleteEvent extends GameEvent {}

class ClearTrickEvent extends GameEvent {}

class BotTurnWithDelayEvent extends GameEvent {
  final String action;
  final Duration delay;

  BotTurnWithDelayEvent({
    required this.action,
    this.delay = const Duration(seconds: 2),
  });
}
