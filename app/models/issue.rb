# Issues are things admins need to take a look at and resolve them.
# For example: Missing emails, implausible postal addresses etc.
# 
# ## Usage
# 
#     Issue.scan            # Perform an overall scan for issues.
#     Issue.scan(object)    # Scan a specific object for issues.
#     Issue.scan(objects)   # Scan multiple objects.
#
#     Issue.unresolved      # Scope that detects only unresolved issues.
# 
#     issues = Issue.scan
#     issue = issues.first
#     issue.resecan         # Rescan a specific issue.
#
class Issue < ActiveRecord::Base
  attr_accessible :title, :description, :resolved_at, :responsible_admin_id
  
  belongs_to :reference, polymorphic: true
  belongs_to :responsible_admin, class_name: 'User'
  
  scope :unresolved, -> { where(resolved_at: nil) }
  scope :by_admin, ->(admin) { where(responsible_admin_id: admin.id) }
  
  def self.scan(object_or_objects = nil)
    if object_or_objects && object_or_objects.respond_to?(:to_a)
      self.scan_objects(object_or_objects)
    elsif object_or_objects.present?
      self.scan_object(object_or_objects)
    else
      self.scan_all
    end
  end
  def self.scan_objects(objects)
    objects.collect { |obj| self.scan_object(obj) }.flatten - [nil]
  end
  def self.scan_object(object)
    return self.scan_address_field(object) if object.kind_of?(ProfileFieldTypes::Address)
  end
  def self.scan_all
    self.scan_objects(ProfileFieldTypes::Address.all)
  end
  
  def self.scan_address_field(address_field)
    address_field.issues.destroy_all
    if address_field.postal_or_first_address?
      if address_field.value.to_s.split("\n").count < 2
        address_field.issues.create title: 'issues.address_has_too_few_lines', description: 'issues.address_needs_between_2_and_4_lines', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      elsif address_field.value.to_s.split("\n").count > 4
        address_field.issues.create title: 'issues.address_has_too_many_lines', description: 'issues.address_needs_between_2_and_4_lines', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      end
      if address_field.country_code == "A" and not (address_field.value.include?("Österreich") or address_field.value.include?("Austria"))
        address_field.issues.create title: 'issues.destination_country_is_missing', description: 'issues.the_destination_country_has_to_be_the_last_line', responsible_admin_id: address_field.profileable.try(:responsible_admin_id)
      end
    end
    return address_field.issues(true)
  end
  
  
  # TODO 
  # - als ungültig markierte e-mail-adresse
  
  def reference_content
    return reference.value if reference.kind_of?(ProfileField)
  end
  
end
