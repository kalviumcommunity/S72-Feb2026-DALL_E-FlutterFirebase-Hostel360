enum ComplaintStatus {
  pending('Pending'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String displayName;
  const ComplaintStatus(this.displayName);

  static ComplaintStatus fromString(String value) {
    return ComplaintStatus.values.firstWhere(
      (status) => status.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => ComplaintStatus.pending,
    );
  }
}
