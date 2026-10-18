import 'dart:math';

class CombatLogicService {
  static InitiativeOutcome currentIntiative =
      InitiativeOutcome.playerHasInitiative;
  static CombatOutcome determineCombatOutcome({
    required double playerAttackStrength,
    required double playerDefenseStrength,
    required double enemyAttackStrength,
    required double enemyDefenseStrength,
    required Random random,
  }) {
    // Step 1: Determine initiative with probability
    currentIntiative = _decideInitiative(
      playerStrength: playerAttackStrength,
      enemyStrength: enemyAttackStrength,
      random: random,
    );

    // Step 2: Resolve the attack outcome based on initiative
    if (currentIntiative == InitiativeOutcome.playerHasInitiative) {
      print("Player has initiative.");

      return _resolveAttack(
        attackerStrength: playerAttackStrength,
        defenderStrength: enemyDefenseStrength,
        random: random,
      );
    } else if (currentIntiative == InitiativeOutcome.enemyHasInitiative) {
      print("Enemy has initiative.");
      return _resolveAttack(
        attackerStrength: enemyAttackStrength,
        defenderStrength: playerDefenseStrength,
        random: random,
      );
    } else {
      print("uNknown state wtf initiative.");
      return CombatOutcome.uNknown;
    }
  }

  /// Decides initiative using a probability weighted by player and enemy attack strengths.
  static InitiativeOutcome _decideInitiative({
    required double playerStrength,
    required double enemyStrength,
    required Random random,
  }) {
    double totalStrength = playerStrength + enemyStrength;

    // Avoid division by zero
    if (totalStrength == 0) {
      return random.nextBool()
          ? InitiativeOutcome.playerHasInitiative
          : InitiativeOutcome
              .enemyHasInitiative; // Equal chance if both strengths are zero
    }

    double playerInitiativeProbability = playerStrength / totalStrength;

    // Generate a random number to determine initiative
    return random.nextDouble() < playerInitiativeProbability
        ? InitiativeOutcome.playerHasInitiative
        : InitiativeOutcome.enemyHasInitiative;
  }

  /// Resolves an attack based on attacker and defender strengths.
  static CombatOutcome _resolveAttack({
    required double attackerStrength,
    required double defenderStrength,
    required Random random,
  }) {
    double attackSuccessProbability =
        attackerStrength / (attackerStrength + defenderStrength);

    double randomValue = random.nextDouble();
    return randomValue < attackSuccessProbability
        ? CombatOutcome.attackSuccess
        : CombatOutcome.attackFail;
  }

  static const double baseCriticalChance = 0.05; // 5% minimum critical chance
  static const double maxCriticalBonus =
      0.50; // Additional 50% chance at full energy

  static bool isCriticalHit({
    required int currentEnergy,
    required int maxEnergy,
    required Random random,
  }) {
    // Calculate the critical hit chance
    double energyRatio = currentEnergy / maxEnergy;
    double criticalHitChance =
        baseCriticalChance + (energyRatio * maxCriticalBonus);

    // Generate a random value between 0 and 1
    double roll = random.nextDouble();

    // Check if the roll is within the critical hit chance
    return roll < criticalHitChance;
  }
}

enum CombatOutcome { attackSuccess, attackFail, uNknown }

enum InitiativeOutcome { playerHasInitiative, enemyHasInitiative }

void main() {
  Random random = Random();
  final Map<String, int> outcomes = {
    'attackSuccess': 0,
    'attackFail': 0,
  };

  for (int trial = 0; trial < 100; trial++) {
    CombatOutcome outcome = CombatLogicService.determineCombatOutcome(
      playerAttackStrength: 35,
      playerDefenseStrength: 15,
      enemyAttackStrength: 20,
      enemyDefenseStrength: 20,
      random: random,
    );
    print('Trial $trial: $outcome');

    switch (outcome) {
      case CombatOutcome.attackSuccess:
        outcomes['attackSuccess'] = outcomes['attackSuccess']! + 1;
        break;
      case CombatOutcome.attackFail:
        outcomes['attackFail'] = outcomes['attackFail']! + 1;
        break;
      default:
        print("Unknown state wtf");
        break;
    }
  }

  print('Trial Results: $outcomes');
}
