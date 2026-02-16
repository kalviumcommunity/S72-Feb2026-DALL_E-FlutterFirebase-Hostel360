enum ComplaintCategory {
  mess('Mess'),
  maintenance('Maintenance'),
  facilities('Facilities');

  final String displayName;
  const ComplaintCategory(this.displayName);

  static ComplaintCategory fromString(String value) {
    return ComplaintCategory.values.firstWhere(
      (category) => category.displayName.toLowerCase() == value.toLowerCase(),
      orElse: () => ComplaintCategory.mess,
    );
  }
}
