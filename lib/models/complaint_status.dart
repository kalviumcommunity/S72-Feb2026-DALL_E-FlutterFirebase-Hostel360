enum ComplaintStatus {
  pending('Pending'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String displayName;
  const ComplaintStatus(this.displayName);

  static ComplaintStatus fromString(String status) {
    switch (status) {
      case 'Pending':
        return ComplaintStatus.pending;
      case 'In Progress':
        return ComplaintStatus.inProgress;
      case 'Resolved':
        return ComplaintStatus.resolved;
      default:
        throw ArgumentError('Invalid status: $status');
    }
  }
}
