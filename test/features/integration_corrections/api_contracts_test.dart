import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:joyn_front/core/network/api_client.dart';
import 'package:joyn_front/features/onboarding/data/api_cv_repository.dart';
import 'package:joyn_front/features/onboarding/data/cv_repository.dart';
import 'package:joyn_front/features/onboarding/domain/cv_extraction.dart';
import 'package:joyn_front/features/profile/data/api_profile_repository.dart';
import 'package:joyn_front/features/profile/domain/student_profile.dart';
import 'package:joyn_front/features/recruiter_workspace/data/recruiter_workspace_repository.dart';
import 'package:joyn_front/features/admin_companies/data/api_admin_company_repository.dart';

void main() {
  test(
    'CV: envoi multipart file, JWT et données réellement extraites',
    () async {
      final api = ApiClient(
        baseUrl: 'https://joyn.test',
        tokenProvider: () async => 'test-token',
        httpClient: MockClient((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/api/v1/resumes/parse');
          expect(request.headers['authorization'], 'Bearer test-token');
          expect(request.body, contains('name="file"'));
          expect(request.body, contains('filename="cv.pdf"'));
          return http.Response(
            jsonEncode({
              'contactInfo': {
                'firstName': 'Léa',
                'lastName': 'Michel',
                'city': 'Rouen',
              },
              'education': [],
              'experiences': [],
              'skills': ['SQL'],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
      final result = await ApiCvRepository(api).analyze(
        PickedCv(
          name: 'cv.pdf',
          sizeInBytes: 4,
          bytes: Uint8List.fromList([37, 80, 68, 70]),
        ),
      );
      expect(result.fullName, 'Léa Michel');
      expect(result.skills, ['SQL']);
      expect(result.isSample, isFalse);
    },
  );
  test('CV: panne serveur ne produit jamais de faux résultat', () async {
    final api = ApiClient(
      baseUrl: 'https://joyn.test',
      httpClient: MockClient((_) async => http.Response('{}', 502)),
    );
    expect(
      () => ApiCvRepository(api).analyze(
        PickedCv(
          name: 'cv.pdf',
          sizeInBytes: 1,
          bytes: Uint8List.fromList([1]),
        ),
      ),
      throwsA(isA<CvImportException>()),
    );
  });
  test('profil candidat: photo réseau, PATCH et upload séparé sans réécrire les diplômes', () async {
    final calls = <String>[];
    final api = ApiClient(
      baseUrl: 'https://joyn.test',
      httpClient: MockClient((request) async {
        calls.add('${request.method} ${request.url.path}');
        if (request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'first_name': 'Léa',
              'last_name': 'Michel',
              'email': 'lea@example.test',
              'photo_url': 'https://joyn.test/photo.webp',
              'skills': ['SQL'],
              'educations': [
                {
                  'field_of_study': 'Informatique',
                  'school_name': 'Université',
                  'degree': 'MASTERS',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }
        if (request.method == 'PATCH') {
          final body = jsonDecode(request.body) as Map;
          expect(body.containsKey('email'), false);
          expect(body.containsKey('educations'), false);
          expect(body['first_name'], 'Léa');
        }
        if (request.method == 'PUT') {
          expect(request.body, contains('name="file"'));
        }
        return http.Response('{}', 200);
      }),
    );
    final repo = ApiProfileRepository(api);
    final profile = await repo.fetchProfile();
    expect(profile.photo!.url, 'https://joyn.test/photo.webp');
    await repo.saveProfile(
      profile.copyWith(
        photo: ProfilePhoto(
          bytes: Uint8List.fromList([1]),
          fileName: 'photo.png',
        ),
      ),
    );
    expect(calls, [
      'GET /api/v1/candidates/profile',
      'PATCH /api/v1/candidates/profile',
      'PUT /api/v1/users/profile-picture',
      'GET /api/v1/candidates/profile',
    ]);
  });
  test(
    'logo et suppression entreprise: routes réelles, pas de corps inventé',
    () async {
      final calls = <String>[];
      final api = ApiClient(
        baseUrl: 'https://joyn.test',
        httpClient: MockClient((request) async {
          calls.add('${request.method} ${request.url.path}');
          if (request.method == 'PUT') {
            expect(request.body, contains('name="file"'));
          }
          return http.Response('', 204);
        }),
      );
      final repo = ApiRecruiterWorkspaceRepository(api);
      await repo.uploadLogo(12, Uint8List.fromList([1]), 'logo.png');
      await repo.deleteLogo(12);
      await ApiAdminCompanyRepository(api).deleteCompany('12');
      expect(calls, [
        'PUT /api/v1/companies/12/logo',
        'DELETE /api/v1/companies/12/logo',
        'DELETE /api/v1/companies/12',
      ]);
    },
  );
}
