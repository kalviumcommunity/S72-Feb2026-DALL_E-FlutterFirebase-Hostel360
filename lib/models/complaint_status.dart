enum ComplaintStatus {
  pending('Pending'),
  inProgress('In Progress'),
  resolved('Resolved');

  final String displayName;
  const ComplaintStatus(this.displayName);
}
