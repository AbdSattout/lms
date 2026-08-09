import 'package:flutter_test/flutter_test.dart';
import 'package:lms/core/services/external_url_launcher.dart';

void main() {
  group('ExternalUrlLauncher invite parsing', () {
    const token = 'ec29dc09-e1ba-4411-958f-032a9ef59e26';

    test('extracts the token from public invite URLs', () {
      expect(
        ExternalUrlLauncher.inviteTokenFromInput(
          'https://lmscenter.vercel.app/invite/$token',
        ),
        token,
      );
    });

    test('extracts the token from mobile invite URLs and app links', () {
      expect(
        ExternalUrlLauncher.inviteTokenFromInput(
          'https://lmscenter.vercel.app/mobile/invite/$token',
        ),
        token,
      );
      expect(
        ExternalUrlLauncher.inviteTokenFromInput('lms://invite/$token'),
        token,
      );
    });

    test('normalizes bare tokens to the public invite URL', () {
      expect(
        ExternalUrlLauncher.publicInviteUrlFromInput(token),
        'https://lmscenter.vercel.app/invite/$token',
      );
    });

    test('accepts invite paths without requiring the browser URL', () {
      expect(ExternalUrlLauncher.inviteTokenFromInput('/invite/$token'), token);
      expect(ExternalUrlLauncher.inviteTokenFromInput('invite/$token'), token);
    });

    test('rejects unrelated URLs and invalid token text', () {
      expect(
        ExternalUrlLauncher.inviteTokenFromInput(
          'https://example.com/invite/$token',
        ),
        isNull,
      );
      expect(ExternalUrlLauncher.inviteTokenFromInput('not a token'), isNull);
    });
  });
}
