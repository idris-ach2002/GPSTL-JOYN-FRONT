import 'package:flutter_test/flutter_test.dart';
import 'package:joyn_front/features/admin_users/domain/user_query.dart';

void main() {
  test('les valeurs par défaut ne polluent pas l’URL', () {
    expect(const UserQuery().toQueryParameters(), isEmpty);
  });

  test('aller-retour URL → requête → URL', () {
    const query = UserQuery(
      page: 3,
      search: 'emma',
      role: UserRoleFilter.recruiter,
      status: UserStatusFilter.suspended,
      sort: UserSort.nameAsc,
    );
    final params = query.toQueryParameters();
    expect(params, {
      'page': '3',
      'q': 'emma',
      'role': 'recruiter',
      'status': 'suspended',
      'sort': 'name.asc',
    });
    expect(UserQuery.fromQueryParameters(params), query);
  });

  test('les paramètres inconnus ou invalides sont ignorés', () {
    final query = UserQuery.fromQueryParameters({
      'page': '-4',
      'role': 'pirate',
      'status': '???',
      'sort': 'n_importe_quoi',
    });
    expect(query, const UserQuery());
  });

  test('hasFilters ignore le tri et la page', () {
    expect(const UserQuery(page: 4, sort: UserSort.oldest).hasFilters, isFalse);
    expect(const UserQuery(search: 'léa').hasFilters, isTrue);
  });
}
