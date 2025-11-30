import 'package:flutter_test/flutter_test.dart';
import 'package:tarot_africain/data/datasources/game_local_datasource.dart';
import 'package:tarot_africain/data/repositories/game_repository_impl.dart';
import 'package:tarot_africain/domain/entities/player.dart';
import 'package:tarot_africain/domain/entities/game_state.dart';
import 'package:tarot_africain/domain/entities/card.dart';

void main() {
  test(
    'calculateScores updates player scores according to Tarot Africain rules',
    () async {
      final repo = GameRepositoryImpl(GameLocalDataSource());

      // Créer des cartes ordinaires pour tester les points
      final ordinaryCards = [
        Card(suit: CardSuit.clubs, rank: CardRank.king, value: 14), // 4 points
        Card(suit: CardSuit.clubs, rank: CardRank.queen, value: 13), // 3 points
        Card(
          suit: CardSuit.clubs,
          rank: CardRank.knight,
          value: 12,
        ), // 2 points
        Card(suit: CardSuit.clubs, rank: CardRank.jack, value: 11), // 1 point
      ];

      final players = [
        Player(
          id: 'p1',
          name: 'A',
          type: PlayerType.human,
          score: 0,
          currentBid: 2,
          tricksWon: 2,
          ordinaryCards: ordinaryCards,
        ),
        Player(
          id: 'p2',
          name: 'B',
          type: PlayerType.bot,
          score: 0,
          currentBid: 1,
          tricksWon: 3,
          ordinaryCards: [],
        ),
        Player(
          id: 'p3',
          name: 'C',
          type: PlayerType.bot,
          score: 0,
          currentBid: 0,
          tricksWon: 0,
          ordinaryCards: [],
        ),
      ];

      final state = GameState(
        players: players,
        dealerIndex: 0,
        currentPlayerIndex: 0,
        phase: GamePhase.scoring,
        currentRound: 1,
        bids: [2, 1, 0],
        currentTrick: [],
        isLastCardBlind: false,
      );

      final newState = await repo.calculateScores(state) as GameState;

      // Joueur 1: annonce réussie (2==2) -> bonus 10 + (2*2) = 14, + cartes 4+3+2+1 = 10, total = 24
      expect(newState.players[0].score, 24);
      // Joueur 2: annonce ratée (3!=1) -> pénalité -(2*5) = -10
      expect(newState.players[1].score, -10);
      // Joueur 3: annonce réussie (0==0) -> bonus 10 + (0*2) = 10
      expect(newState.players[2].score, 10);
    },
  );
}
