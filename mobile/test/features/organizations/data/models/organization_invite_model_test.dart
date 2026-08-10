import 'package:flutter_test/flutter_test.dart';
import 'package:lms/features/organizations/data/models/organization_invite_model.dart';

void main() {
  test('parses invite preview organization details and joined state', () {
    final invite = OrganizationInviteModel.fromJson({
      'id': 7,
      'role': 'STUDENT',
      'status': 'PENDING',
      'token': 'ec29dc09-e1ba-4411-958f-032a9ef59e26',
      'alreadyJoined': true,
      'organization': {
        'id': 11,
        'name': 'LMS Center',
        'slug': 'lms-center',
        'description': 'Learning organization',
        'imageUrl': 'https://example.com/logo.png',
        'visibility': 'PRIVATE',
        'owner': {'name': 'Owner Name'},
      },
      'overview': {
        'membersCount': 12,
        'studentsCount': 10,
        'coursesCount': 4,
        'publishedCoursesCount': 3,
      },
      'invitedByName': 'Owner Name',
      'maxUses': 50,
      'usedCount': 12,
    });

    expect(invite.alreadyJoined, isTrue);
    expect(invite.organization.name, 'LMS Center');
    expect(invite.organization.slug, 'lms-center');
    expect(invite.organization.ownerName, 'Owner Name');
    expect(invite.overview?.membersCount, 12);
    expect(invite.overview?.publishedCoursesCount, 3);
    expect(invite.usedCount, 12);
  });
}
