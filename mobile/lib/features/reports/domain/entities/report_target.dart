enum ReportTargetType {
  user,
  post,
  comment,
  course,
  organization;

  String get apiValue {
    return switch (this) {
      ReportTargetType.user => 'USER',
      ReportTargetType.post => 'POST',
      ReportTargetType.comment => 'COMMENT',
      ReportTargetType.course => 'COURSE',
      ReportTargetType.organization => 'ORGANIZATION',
    };
  }

  String get arabicLabel {
    return switch (this) {
      ReportTargetType.user => 'مستخدم',
      ReportTargetType.post => 'منشور',
      ReportTargetType.comment => 'تعليق',
      ReportTargetType.course => 'كورس',
      ReportTargetType.organization => 'منظمة',
    };
  }
}

class ReportTarget {
  final ReportTargetType type;
  final String title;
  final int? userId;
  final int? organizationId;
  final int? courseId;
  final int? postId;
  final int? commentId;

  const ReportTarget._({
    required this.type,
    required this.title,
    this.userId,
    this.organizationId,
    this.courseId,
    this.postId,
    this.commentId,
  });

  const ReportTarget.user({required int userId, required String title})
    : this._(type: ReportTargetType.user, title: title, userId: userId);

  const ReportTarget.post({
    required int postId,
    required int organizationId,
    required int userId,
    required String title,
  }) : this._(
         type: ReportTargetType.post,
         title: title,
         postId: postId,
         organizationId: organizationId,
         userId: userId,
       );

  const ReportTarget.comment({
    required int commentId,
    required int postId,
    required int organizationId,
    required int userId,
    required String title,
  }) : this._(
         type: ReportTargetType.comment,
         title: title,
         commentId: commentId,
         postId: postId,
         organizationId: organizationId,
         userId: userId,
       );

  const ReportTarget.course({
    required int courseId,
    required int organizationId,
    required String title,
  }) : this._(
         type: ReportTargetType.course,
         title: title,
         courseId: courseId,
         organizationId: organizationId,
       );

  const ReportTarget.organization({
    required int organizationId,
    required String title,
    int? ownerUserId,
  }) : this._(
         type: ReportTargetType.organization,
         title: title,
         organizationId: organizationId,
         userId: ownerUserId,
       );

  String get displayTitle {
    final trimmed = title.trim();
    return trimmed.isEmpty ? type.arabicLabel : trimmed;
  }

  Map<String, dynamic> toPayload(String reason) {
    final payload = <String, dynamic>{
      'targetType': type.apiValue,
      'reason': reason,
    };

    void put(String key, int? value) {
      if (value != null) payload[key] = value;
    }

    switch (type) {
      case ReportTargetType.user:
        put('userId', userId);
        break;
      case ReportTargetType.post:
        put('userId', userId);
        put('organizationId', organizationId);
        put('postId', postId);
        break;
      case ReportTargetType.comment:
        put('userId', userId);
        put('organizationId', organizationId);
        put('postId', postId);
        put('commentId', commentId);
        break;
      case ReportTargetType.course:
        put('organizationId', organizationId);
        put('courseId', courseId);
        break;
      case ReportTargetType.organization:
        put('organizationId', organizationId);
        put('userId', userId);
        break;
    }

    return payload;
  }
}
