import 'dart:convert';
import 'lib/features/wallet/data/wallet_models.dart';
void main() {
  const jsonStr = """
{
    "message": "Wallet retrieved",
    "data": {
        "range": "today",
        "cash": {
            "total_customer_funds_kobo": 6370000,
            "funds_added_kobo": { "value": 3955000, "change_percent": null },
            "funds_spent_kobo": { "value": 2585000, "change_percent": null },
            "reversals_kobo": { "value": 0, "change_percent": null },
            "wallets_holding_cash": 5,
            "pending_deposits_kobo": 0,
            "failed_payments": 0,
            "funds_withdrawn_kobo": null,
            "pending_withdrawals_kobo": null,
            "refunds_kobo": null,
            "all_time": { "funds_added_kobo": 82195000, "funds_spent_kobo": 75825000, "withdrawn_kobo": null }
        },
        "coins": {
            "coins_in_circulation": 517109,
            "bonus_in_circulation": 4,
            "coins_earned": { "value": 502160, "change_percent": 44655.8 },
            "coins_spent": { "value": 510, "change_percent": 0 },
            "coin_reversals": { "value": 0, "change_percent": null },
            "wallets_holding_coins": 14,
            "pending_redemptions": 25,
            "rewards_claimed": { "value": 0, "change_percent": null },
            "coins_expired": { "value": 0, "change_percent": null },
            "failed_transactions": null,
            "all_time": { "coins_earned": 527279 }
        },
        "charts": {
            "coins_by_source": [
                { "label": "Admin", "coins": 502000, "percent": 100 },
                { "label": "Games", "coins": 151, "percent": 0 },
                { "label": "streak_bonus", "coins": 9, "percent": 0 }
            ],
            "coins_by_sink": [
                { "label": "Tournament entries", "coins": 500, "percent": 98 },
                { "label": "Boosters", "coins": 10, "percent": 2 }
            ],
            "cash_balance_trend": [
                { "day": "2026-08-19", "value": 0 },
                { "day": "2026-09-01", "value": 6370000 }
            ],
            "top_games_by_coins": [
                { "name": "XOXO", "coins": 86, "players": 1, "average_per_player": 86 },
                { "name": "Trivia", "coins": 44, "players": 2, "average_per_player": 22 },
                { "name": "Picture Puzzle", "coins": 30, "players": 1, "average_per_player": 30 }
            ]
        },
        "recent_cash": [
            { "id": "701c8dc4-3afe-4728-a490-8e30fb0c2fc5", "username": "Rutex", "reason": "cash_adjustment", "amount": 120000, "balance_after": 1120000, "created_at": "2026-09-01T19:59:18.345Z" }
        ],
        "recent_coins": [
            { "id": "526a2715-4983-4d1b-8cc8-805493719663", "username": "Rutex", "reason": "admin_adjustment", "amount": 2000, "balance_after": 509640, "created_at": "2026-09-01T19:59:43.907Z" }
        ],
        "pending_redemptions": [
            { "id": "011c9a30-ee74-4252-9847-65b4e441410c", "username": "kimotest01", "reward_name": "BoomAir Bass", "coin_cost": 0, "paid_kobo": 2500000, "created_at": "2026-09-01T08:09:49.942Z" }
        ]
    }
}
""";
  try {
    final parsed = jsonDecode(jsonStr);
    final data = WalletData.fromJson(parsed['data']);
    print('Success! Top games count: ${data.charts.topGames.length}, Recent cash: ${data.recent.cashTransactions.length}');
  } catch(e, st) {
    print('Error: $e');
    print(st);
  }
}
